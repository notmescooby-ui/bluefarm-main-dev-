import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_shell.dart';
import 'buyer_shell.dart';
import 'admin_shell.dart';
import 'pending_approval_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CONFIG — replace with your actual Anthropic API key
// ─────────────────────────────────────────────────────────────────────────────
const _kAnthropicKey = 'YOUR_ANTHROPIC_API_KEY';
const _kAnthropicUrl = 'https://api.anthropic.com/v1/messages';

// ─────────────────────────────────────────────────────────────────────────────
//  DROPDOWNS
// ─────────────────────────────────────────────────────────────────────────────
const _farmingTypes = [
  'Earthen Pond', 'Concrete Tank', 'RAS (Recirculating Aquaculture System)',
  'Cage Culture', 'Raceway', 'Biofloc', 'Paddy-cum-Fish', 'Other',
];
const _fishSpecies = [
  'Rohu', 'Catla', 'Mrigal', 'Tilapia', 'Pangasius', 'Shrimp (Vannamei)',
  'Shrimp (Tiger)', 'Catfish', 'Carp', 'Hilsa', 'Salmon', 'Other',
];
const _buyerTypes = [
  'Wholesale Trader', 'Retail Trader', 'Export Company',
  'Processing Unit', 'Hotel / Restaurant', 'Individual Buyer', 'Other',
];

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class FarmerInfoScreen extends StatefulWidget {
  final String phone;
  final String? email;

  const FarmerInfoScreen({super.key, required this.phone, this.email});

  @override
  State<FarmerInfoScreen> createState() => _FarmerInfoScreenState();
}

class _FarmerInfoScreenState extends State<FarmerInfoScreen>
    with TickerProviderStateMixin {

  // ── role ──────────────────────────────────────────────────────────────────
  String? _role;

  // ── controllers ───────────────────────────────────────────────────────────
  final _nameCtrl      = TextEditingController();
  final _aadhaarCtrl   = TextEditingController();
  final _farmNameCtrl  = TextEditingController();
  final _pincodeCtrl   = TextEditingController();
  final _farmSizeCtrl  = TextEditingController();
  final _secondaryCtrl = TextEditingController();
  final _companyCtrl   = TextEditingController();
  final _gstCtrl       = TextEditingController();
  final _devIdCtrl     = TextEditingController();
  final _devRoleCtrl   = TextEditingController();

  // ── dropdowns ─────────────────────────────────────────────────────────────
  String? _farmingType;
  String? _primarySpecies;
  String? _buyerType;

  // ── aadhaar verification ──────────────────────────────────────────────────
  XFile?  _aadhaarPhoto;
  bool    _aadhaarVerified  = false;
  bool    _aadhaarVerifying = false;
  String? _aadhaarError;
  String? _aadhaarSuccess;

  // ── gst ───────────────────────────────────────────────────────────────────
  bool    _gstValid = false;
  String? _gstError;

  // ── location ──────────────────────────────────────────────────────────────
  String? _region;
  String? _gpsAddress;
  bool    _locLoading = false;

  // ── submit ────────────────────────────────────────────────────────────────
  bool _submitting = false;

  // ── animation ─────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    for (final c in [
      _nameCtrl, _aadhaarCtrl, _farmNameCtrl, _pincodeCtrl,
      _farmSizeCtrl, _secondaryCtrl, _companyCtrl, _gstCtrl,
      _devIdCtrl, _devRoleCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  void _selectRole(String role) {
    setState(() => _role = role);
    _fadeCtrl.forward(from: 0);
  }

  bool get _canSubmit {
    if (!_aadhaarVerified) return false;
    if (_nameCtrl.text.trim().isEmpty) return false;
    switch (_role) {
      case 'farmer':
        return _farmNameCtrl.text.trim().isNotEmpty &&
            _pincodeCtrl.text.trim().length == 6 &&
            _farmSizeCtrl.text.trim().isNotEmpty &&
            _farmingType != null &&
            _primarySpecies != null;
      case 'buyer':
        return _companyCtrl.text.trim().isNotEmpty &&
            _buyerType != null &&
            _gstValid &&
            _pincodeCtrl.text.trim().length == 6;
      case 'developer':
        return _devIdCtrl.text.trim().isNotEmpty &&
            _devRoleCtrl.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  // ── pincode lookup ────────────────────────────────────────────────────────
  Future<void> _lookupPincode(String pin) async {
    if (pin.length != 6) return;
    try {
      final res = await http.get(
        Uri.parse('https://api.postalpincode.in/pincode/$pin'),
      );
      final data = jsonDecode(res.body) as List;
      if (data.isNotEmpty && data[0]['Status'] == 'Success') {
        final po = (data[0]['PostOffice'] as List)[0];
        setState(() {
          _region = '${po['District']}, ${po['State']}, India';
        });
      }
    } catch (_) {}
  }

  // ── GPS location ──────────────────────────────────────────────────────────
  Future<void> _detectLocation() async {
    setState(() => _locLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Location services are disabled.');
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          _showSnack('Location permission denied.');
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _gpsAddress =
            '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      _showSnack('Could not get location: $e');
    } finally {
      setState(() => _locLoading = false);
    }
  }

  // ── pick aadhaar photo ────────────────────────────────────────────────────
  Future<void> _pickAadhaarPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (file == null) return;
    setState(() {
      _aadhaarPhoto    = file;
      _aadhaarVerified = false;
      _aadhaarError    = null;
      _aadhaarSuccess  = null;
    });
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('Upload Aadhaar Photo',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Upload a clear photo of yourself holding your Aadhaar card. '
                  'Ensure the Govt of India emblem and your name are clearly visible.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading:
                    const CircleAvatar(child: Icon(Icons.camera_alt)),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAadhaarPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                    child: Icon(Icons.photo_library)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAadhaarPhoto(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Claude AI Aadhaar verification ────────────────────────────────────────
  Future<void> _verifyAadhaarWithAI() async {
    final name = _nameCtrl.text.trim();
    // Strip ALL non-digit characters before validating
    final aadhaar = _aadhaarCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Update field to show cleaned value
    if (_aadhaarCtrl.text != aadhaar) {
      _aadhaarCtrl.value = TextEditingValue(
        text: aadhaar,
        selection: TextSelection.collapsed(offset: aadhaar.length),
      );
    }

    if (name.isEmpty) {
      _showSnack('Please enter your full name first.');
      return;
    }
    if (_aadhaarPhoto == null) {
      _showSnack('Please upload a photo first.');
      return;
    }
    if (aadhaar.length != 12) {
      setState(() => _aadhaarError =
          'Aadhaar must be 12 digits. You entered ${aadhaar.length} digit(s).');
      return;
    }

    setState(() {
      _aadhaarVerifying = true;
      _aadhaarError     = null;
      _aadhaarSuccess   = null;
    });

    try {
      final bytes     = await _aadhaarPhoto!.readAsBytes();
      final base64Img = base64Encode(bytes);
      final mimeType  = _aadhaarPhoto!.name.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';

      final prompt = '''
You are a KYC verification assistant for an Indian government-regulated aquaculture app.

Carefully examine the uploaded photo and verify ALL of the following:

1. DOCUMENT VISIBLE: Is an Aadhaar card clearly visible in the photo?
2. GOVT EMBLEM: Is the Government of India emblem (Ashoka Pillar / Lion Capital) visible on the Aadhaar card?
3. NAME MATCH: Does the name printed on the Aadhaar card match the registered name: "$name"? Allow minor spacing or case differences but flag clear mismatches.
4. AADHAAR NUMBER: Is the Aadhaar number "$aadhaar" visible on the card? It may be partially masked — if the last 4 digits match or the format is consistent, consider it a match.

Respond ONLY in this exact JSON format with no extra text, preamble, or markdown:
{
  "verified": true or false,
  "checks": {
    "document_visible": true or false,
    "emblem_visible": true or false,
    "name_match": true or false,
    "aadhaar_number_match": true or false
  },
  "failure_reason": "Short plain English reason if verified is false, otherwise null"
}
''';

      final response = await http.post(
        Uri.parse(_kAnthropicUrl),
        headers: {
          'x-api-key': _kAnthropicKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': 'claude-opus-4-5',
          'max_tokens': 300,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': mimeType,
                    'data': base64Img,
                  },
                },
                {
                  'type': 'text',
                  'text': prompt,
                },
              ],
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final text = (body['content'] as List)
            .firstWhere((c) => c['type'] == 'text')['text'] as String;

        final clean =
            text.replaceAll('```json', '').replaceAll('```', '').trim();
        final result = jsonDecode(clean) as Map<String, dynamic>;

        final verified = result['verified'] == true;
        final reason   = result['failure_reason'] as String?;

        // Upload photo to Supabase Storage
        String? docUrl;
        try {
          final userId =
              Supabase.instance.client.auth.currentUser?.id;
          final path =
              'aadhaar/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
          await Supabase.instance.client.storage
              .from('aadhaar-docs')
              .uploadBinary(path, bytes,
                  fileOptions:
                      const FileOptions(upsert: true));
          docUrl = Supabase.instance.client.storage
              .from('aadhaar-docs')
              .getPublicUrl(path);
        } catch (_) {}

        // Save verification status
        try {
          final userId =
              Supabase.instance.client.auth.currentUser?.id;
          if (userId != null) {
            await Supabase.instance.client.from('profiles').upsert({
              'id': userId,
              'aadhaar_status':   verified ? 'verified' : 'failed',
              'aadhaar_verified': verified,
              if (docUrl != null) 'aadhaar_doc_url': docUrl,
            });
          }
        } catch (_) {}

        setState(() {
          _aadhaarVerified = verified;
          _aadhaarError    = verified
              ? null
              : (reason ?? 'Verification failed. Please try again with a clearer photo.');
          _aadhaarSuccess  =
              verified ? 'Identity verified successfully ✓' : null;
        });
      } else {
        setState(() {
          _aadhaarError =
              'Verification service error (${response.statusCode}). Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _aadhaarError = 'Could not connect to verification service. Check your internet connection.';
      });
    } finally {
      setState(() => _aadhaarVerifying = false);
    }
  }

  // ── GST validation ────────────────────────────────────────────────────────
  void _validateGst(String val) {
    final gstRegex = RegExp(
        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    setState(() {
      _gstValid = gstRegex.hasMatch(val.toUpperCase());
      _gstError = val.isEmpty
          ? null
          : (_gstValid ? null : 'Invalid GST format (e.g. 22AAAAA0000A1Z5)');
    });
  }

  // ── submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('profiles').upsert({
        'id':               user.id,
        'full_name':        _nameCtrl.text.trim(),
        'phone':            widget.phone.isNotEmpty ? widget.phone : null,
        'email':            widget.email ?? user.email,
        'role':             _role,
        'aadhaar_verified': true,
        'pincode':          _pincodeCtrl.text.trim(),
        'region':           _region,
        'gps_address':      _gpsAddress,
        'account_status':   _role == 'developer' ? 'pending' : 'active',
        if (_role == 'farmer') ...{
          'farm_name':         _farmNameCtrl.text.trim(),
          'farm_size':         _farmSizeCtrl.text.trim(),
          'farming_type':      _farmingType,
          'fish_species':      _primarySpecies,
          'secondary_species': _secondaryCtrl.text.trim(),
        },
        if (_role == 'buyer') ...{
          'company_name': _companyCtrl.text.trim(),
          'buyer_type':   _buyerType,
          'gst_number':   _gstCtrl.text.trim().toUpperCase(),
          'gst_verified': _gstValid,
        },
        if (_role == 'developer') ...{
          'dev_id':   _devIdCtrl.text.trim(),
          'dev_role': _devRoleCtrl.text.trim(),
        },
      });

      if (!mounted) return;

      Widget destination;
      if (_role == 'buyer') {
        destination = BuyerShell();
      } else if (_role == 'developer') {
        destination = PendingApprovalScreen();
      } else {
        destination = MainShell();
      }

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => destination,
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      _showSnack('Error saving profile: $e');
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: _role == null ? _buildRoleSelection() : _buildForm(),
      ),
    );
  }

  // ── ROLE SELECTION ────────────────────────────────────────────────────────
  Widget _buildRoleSelection() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.water, size: 64, color: Color(0xFF1A6FA8)),
            const SizedBox(height: 20),
            const Text('Welcome to BlueFarm',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D4F7C))),
            const SizedBox(height: 8),
            const Text('Choose your role to get started',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
            const SizedBox(height: 40),
            _roleCard(
              role: 'farmer',
              icon: Icons.grass_rounded,
              label: 'Farmer',
              subtitle:
                  'Manage your fish farm, monitor sensors & sell produce',
              color: const Color(0xFF1A6FA8),
            ),
            const SizedBox(height: 16),
            _roleCard(
              role: 'buyer',
              icon: Icons.storefront_rounded,
              label: 'Buyer / Trader',
              subtitle:
                  'Browse listings, place orders & connect with farmers',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),
            _roleCard(
              role: 'developer',
              icon: Icons.code_rounded,
              label: 'Developer / Admin',
              subtitle:
                  'Access admin dashboard (requires approval)',
              color: const Color(0xFF6A1B9A),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _roleCard({
    required String role,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _selectRole(role),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: color, size: 16),
          ],
        ),
      ),
    );
  }

  // ── FORM ──────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          _buildFormHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Basic Information'),
                  _loginChip(),
                  const SizedBox(height: 12),
                  _field(_nameCtrl, 'Full Name', Icons.person_rounded),
                  const SizedBox(height: 24),
                  _sectionLabel('Identity Verification'),
                  _aadhaarSection(),
                  const SizedBox(height: 24),
                  if (_aadhaarVerified) ...[
                    _roleSpecificFields(),
                    const SizedBox(height: 24),
                    _locationSection(),
                    const SizedBox(height: 32),
                    _submitButton(),
                    const SizedBox(height: 24),
                  ] else ...[
                    _lockedPlaceholder(),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormHeader() {
    final roleLabel = _role == 'farmer'
        ? 'Farmer'
        : _role == 'buyer'
            ? 'Buyer / Trader'
            : 'Developer / Admin';
    final roleColor = _role == 'farmer'
        ? const Color(0xFF1A6FA8)
        : _role == 'buyer'
            ? const Color(0xFF2E7D32)
            : const Color(0xFF6A1B9A);

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: roleColor,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              _role            = null;
              _aadhaarVerified = false;
              _aadhaarPhoto    = null;
              _aadhaarError    = null;
              _aadhaarSuccess  = null;
            }),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Registration',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13)),
                Text(roleLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _aadhaarVerified ? '✓ Verified' : 'Unverified',
              style: const TextStyle(
                  color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginChip() {
    final loginInfo = widget.phone.isNotEmpty
        ? '📱 ${widget.phone}'
        : widget.email != null
            ? '✉️ ${widget.email}'
            : 'Not available';
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_rounded,
              size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(loginInfo,
                style: TextStyle(
                    color: Colors.blue.shade700, fontSize: 13)),
          ),
          Text('Auto-filled',
              style: TextStyle(
                  color: Colors.blue.shade400, fontSize: 11)),
        ],
      ),
    );
  }

  // ── aadhaar section ───────────────────────────────────────────────────────
  Widget _aadhaarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _aadhaarVerified
              ? Colors.green.shade300
              : _aadhaarError != null
                  ? Colors.red.shade300
                  : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aadhaar number
          TextField(
            controller: _aadhaarCtrl,
            keyboardType: TextInputType.number,
            maxLength: 12,
            enabled: !_aadhaarVerified,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              labelText: 'Aadhaar Number (12 digits)',
              prefixIcon:
                  const Icon(Icons.credit_card_rounded),
              counterText: '',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              suffixIcon: _aadhaarVerified
                  ? const Icon(Icons.verified_rounded,
                      color: Colors.green)
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          // Photo upload
          GestureDetector(
            onTap: _aadhaarVerified
                ? null
                : _showPhotoSourceSheet,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                  minHeight: _aadhaarPhoto == null ? 110 : 0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _aadhaarPhoto != null
                      ? Colors.blue.shade300
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: _aadhaarPhoto == null
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_rounded,
                              size: 36,
                              color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Upload photo holding your Aadhaar card',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Govt of India emblem must be visible',
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb
                          ? Container(
                              height: 140,
                              color: Colors.blue.shade50,
                              child: Center(
                                child: Column(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    Icon(Icons.image_rounded,
                                        size: 48,
                                        color: Colors
                                            .blue.shade400),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Photo selected ✓',
                                      style: TextStyle(
                                          color: Colors
                                              .blue.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Image.file(
                              File(_aadhaarPhoto!.path),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
            ),
          ),

          if (_aadhaarPhoto != null && !_aadhaarVerified) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _showPhotoSourceSheet,
              child: Text('Change photo',
                  style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 12,
                      decoration: TextDecoration.underline)),
            ),
          ],

          const SizedBox(height: 12),

          // Verify button
          if (!_aadhaarVerified)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_aadhaarPhoto != null &&
                        !_aadhaarVerifying)
                    ? _verifyAadhaarWithAI
                    : null,
                icon: _aadhaarVerifying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white),
                      )
                    : const Icon(
                        Icons.verified_user_rounded),
                label: Text(_aadhaarVerifying
                    ? 'Verifying with AI...'
                    : 'Verify Identity'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF1A6FA8),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12)),
                ),
              ),
            ),

          // Success
          if (_aadhaarSuccess != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_aadhaarSuccess!,
                        style: const TextStyle(
                            color: Colors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],

          // Error
          if (_aadhaarError != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cancel_rounded,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_aadhaarError!,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── locked placeholder ────────────────────────────────────────────────────
  Widget _lockedPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_rounded,
              size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            'Complete identity verification to unlock registration fields',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── role specific fields ──────────────────────────────────────────────────
  Widget _roleSpecificFields() {
    switch (_role) {
      case 'farmer':
        return _farmerFields();
      case 'buyer':
        return _buyerFields();
      case 'developer':
        return _developerFields();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _farmerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Farm Details'),
        _field(_farmNameCtrl, 'Farm Name',
            Icons.home_work_rounded),
        const SizedBox(height: 12),
        _field(_farmSizeCtrl, 'Farm Size (in acres)',
            Icons.straighten_rounded,
            keyboard: TextInputType.number),
        const SizedBox(height: 12),
        _dropdown(
          label: 'Farming Type',
          icon: Icons.water_rounded,
          value: _farmingType,
          items: _farmingTypes,
          onChanged: (v) => setState(() => _farmingType = v),
        ),
        const SizedBox(height: 12),
        _dropdown(
          label: 'Primary Species',
          icon: Icons.set_meal_rounded,
          value: _primarySpecies,
          items: _fishSpecies,
          onChanged: (v) =>
              setState(() => _primarySpecies = v),
        ),
        const SizedBox(height: 12),
        _field(_secondaryCtrl,
            'Secondary Species (optional, type manually)',
            Icons.more_horiz_rounded),
      ],
    );
  }

  Widget _buyerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Business Details'),
        _field(_companyCtrl, 'Company / Business Name',
            Icons.business_rounded),
        const SizedBox(height: 12),
        _dropdown(
          label: 'Buyer Type',
          icon: Icons.category_rounded,
          value: _buyerType,
          items: _buyerTypes,
          onChanged: (v) => setState(() => _buyerType = v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _gstCtrl,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'GST Number',
            prefixIcon:
                const Icon(Icons.receipt_long_rounded),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: _gstCtrl.text.isNotEmpty
                ? Icon(
                    _gstValid
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color:
                        _gstValid ? Colors.green : Colors.red,
                  )
                : null,
            errorText: _gstError,
          ),
          onChanged: _validateGst,
        ),
      ],
    );
  }

  Widget _developerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: Colors.purple.shade700, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Developer accounts require admin approval before access is granted.',
                  style: TextStyle(
                      color: Colors.purple.shade700,
                      fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionLabel('Developer Details'),
        _field(_devIdCtrl, 'Employee / Developer ID',
            Icons.badge_rounded),
        const SizedBox(height: 12),
        _field(_devRoleCtrl, 'Role / Designation',
            Icons.work_rounded),
      ],
    );
  }

  // ── location section ──────────────────────────────────────────────────────
  Widget _locationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Location'),
        TextField(
          controller: _pincodeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly
          ],
          decoration: InputDecoration(
            labelText: 'PIN Code',
            prefixIcon:
                const Icon(Icons.pin_drop_rounded),
            counterText: '',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (v) {
            if (v.length == 6) _lookupPincode(v);
          },
        ),
        if (_region != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.location_city_rounded,
                    color: Colors.teal.shade700, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_region!,
                      style: TextStyle(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                _locLoading ? null : _detectLocation,
            icon: _locLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2))
                : const Icon(Icons.my_location_rounded),
            label: Text(_locLoading
                ? 'Detecting...'
                : 'Detect Pinpoint Location (GPS)'),
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12)),
            ),
          ),
        ),
        if (_gpsAddress != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.gps_fixed_rounded,
                    color: Colors.blue.shade700, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'GPS: $_gpsAddress',
                    style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── submit button ─────────────────────────────────────────────────────────
  Widget _submitButton() {
    final roleColor = _role == 'farmer'
        ? const Color(0xFF1A6FA8)
        : _role == 'buyer'
            ? const Color(0xFF2E7D32)
            : const Color(0xFF6A1B9A);
    final label = _role == 'developer'
        ? 'Submit for Approval →'
        : 'Enter BlueFarm →';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            (_canSubmit && !_submitting) ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: roleColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding:
              const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: _submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── shared widgets ────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF0D4F7C))),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map((e) =>
              DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
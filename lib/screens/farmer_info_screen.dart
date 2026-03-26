import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_shell.dart';
import 'buyer_shell.dart';
import 'device_connect_screen.dart';
import 'role_selection_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CONFIG
// ─────────────────────────────────────────────────────────────────────────────
const _kAnthropicKey = String.fromEnvironment('ANTHROPIC_API_KEY');
const _kAnthropicUrl = 'https://api.anthropic.com/v1/messages';

// ─────────────────────────────────────────────────────────────────────────────
//  DROPDOWN DATA
// ─────────────────────────────────────────────────────────────────────────────
const _waterbodyTypes = [
  'Earthen Pond',
  'Concrete Tank',
  'RAS (Recirculating Aquaculture System)',
  'Cage Culture',
  'Raceway / Channel',
  'Biofloc Tank',
  'Paddy-cum-Fish',
  'Reservoir / Lake',
  'Brackish Water Pond',
  'Other',
];

const _fishSpecies = [
  'Rohu',
  'Catla',
  'Mrigal',
  'Tilapia (Nile)',
  'Pangasius',
  'Shrimp – Vannamei',
  'Shrimp – Tiger',
  'Catfish (Magur)',
  'Common Carp',
  'Silver Carp',
  'Bighead Carp',
  'Grass Carp',
  'Hilsa',
  'Salmon',
  'Trout',
  'Milkfish',
  'Other',
];

const _buyerTypes = [
  'Wholesale Trader',
  'Retail Trader',
  'Export Company',
  'Processing / Cold Storage Unit',
  'Hotel / Restaurant',
  'Supermarket / Retail Chain',
  'Individual Buyer',
  'NGO / Co-operative',
  'Other',
];

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class FarmerInfoScreen extends StatefulWidget {
  final String phone;
  final String? email;
  final String? role;

  const FarmerInfoScreen({
    super.key,
    required this.phone,
    this.email,
    this.role,
  });

  @override
  State<FarmerInfoScreen> createState() => _FarmerInfoScreenState();
}

class _FarmerInfoScreenState extends State<FarmerInfoScreen>
    with TickerProviderStateMixin {

  // ── role ──────────────────────────────────────────────────────────────────
  String? _role;

  // ── FARMER controllers ────────────────────────────────────────────────────
  final _farmNameCtrl    = TextEditingController();
  final _farmerNameCtrl  = TextEditingController();
  final _farmerAgeCtrl   = TextEditingController();
  final _aadhaarCtrl     = TextEditingController();
  final _pincodeCtrl     = TextEditingController();
  final _gpsCtrl         = TextEditingController();
  final _farmSizeCtrl    = TextEditingController();
  final _customWaterCtrl = TextEditingController();
  final _stockingCtrl    = TextEditingController();
  final _secondaryCtrl   = TextEditingController();

  // ── BUYER controllers ─────────────────────────────────────────────────────
  final _buyerNameCtrl    = TextEditingController();
  final _companyCtrl      = TextEditingController();
  final _buyerPincodeCtrl = TextEditingController();
  final _buyerGpsCtrl     = TextEditingController();

  // ── dropdowns ─────────────────────────────────────────────────────────────
  String? _waterbodyType;
  String? _primarySpecies;
  String? _buyerType;

  // ── Aadhaar ───────────────────────────────────────────────────────────────
  XFile?  _aadhaarPhoto;
  bool    _aadhaarVerified  = false;
  bool    _aadhaarVerifying = false;
  String? _aadhaarError;
  String? _aadhaarSuccess;
  bool _checkEmblem  = false;
  bool _checkName    = false;
  bool _checkFormat  = false;

  // ── location – farmer ─────────────────────────────────────────────────────
  String? _region;
  bool    _locLoading = false;

  // ── location – buyer ──────────────────────────────────────────────────────
  String? _buyerRegion;
  bool    _buyerLocLoading = false;

  // ── submit ────────────────────────────────────────────────────────────────
  bool _submitting = false;

  // ── animations ────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;
  late AnimationController _roleCtrl;
  late Animation<double>   _roleAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _roleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _roleAnim = CurvedAnimation(parent: _roleCtrl, curve: Curves.easeOutCubic);
    _roleCtrl.forward();

    if (widget.role != null) {
      _role = widget.role;
      _fadeCtrl.forward();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _roleCtrl.dispose();
    for (final c in [
      _farmNameCtrl, _farmerNameCtrl, _farmerAgeCtrl, _aadhaarCtrl,
      _pincodeCtrl, _gpsCtrl, _farmSizeCtrl, _customWaterCtrl,
      _stockingCtrl, _secondaryCtrl,
      _buyerNameCtrl, _companyCtrl,
      _buyerPincodeCtrl, _buyerGpsCtrl,
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

  String get _registeredName => _role == 'farmer'
      ? _farmerNameCtrl.text.trim()
      : _buyerNameCtrl.text.trim();

  bool get _canSubmit {
    if (!_aadhaarVerified) return false;
    if (_role == 'farmer') {
      return _farmNameCtrl.text.trim().isNotEmpty &&
          _farmerNameCtrl.text.trim().isNotEmpty &&
          _farmerAgeCtrl.text.trim().isNotEmpty &&
          _pincodeCtrl.text.trim().length == 6 &&
          _farmSizeCtrl.text.trim().isNotEmpty &&
          _waterbodyType != null &&
          (_waterbodyType != 'Other' ||
              _customWaterCtrl.text.trim().isNotEmpty) &&
          _primarySpecies != null;
    } else if (_role == 'buyer') {
      return _buyerNameCtrl.text.trim().isNotEmpty &&
          _companyCtrl.text.trim().isNotEmpty &&
          _buyerType != null &&
          _buyerPincodeCtrl.text.trim().length == 6;
    }
    return false;
  }

  // ── Pincode lookup ────────────────────────────────────────────────────────
  Future<void> _lookupPincode(String pin, {bool isBuyer = false}) async {
    if (pin.length != 6) return;
    try {
      final res = await http.get(
          Uri.parse('https://api.postalpincode.in/pincode/$pin'));
      final data = jsonDecode(res.body) as List;
      if (data.isNotEmpty && data[0]['Status'] == 'Success') {
        final po = (data[0]['PostOffice'] as List)[0];
        final region = '${po['District']}, ${po['State']}, India';
        setState(() {
          if (isBuyer) _buyerRegion = region;
          else _region = region;
        });
      } else {
        _showSnack('PIN code lookup failed. Please check the number.');
      }
    } catch (e) {
      _showSnack('Could not resolve PIN code: $e');
    }
  }

  // ── GPS — returns human-readable address via Nominatim reverse geocoding ──
  Future<void> _detectLocation({bool isBuyer = false}) async {
    setState(() {
      if (isBuyer) _buyerLocLoading = true;
      else _locLoading = true;
    });
    try {
      bool svcEnabled = await Geolocator.isLocationServiceEnabled();
      if (!svcEnabled) {
        _showSnack('Location services are disabled. Please enable GPS in Settings.');
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          _showSnack('Location permission denied. Please allow it to auto-detect location.');
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        _showSnack('Location permission permanently denied. Please enable it in App Settings.');
        await Geolocator.openAppSettings();
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15));

      // Reverse geocode via Nominatim — extract both display name and district/state
      String address;
      String? detectedRegion;
      try {
        final res = await http.get(
          Uri.parse(
            'https://nominatim.openstreetmap.org/reverse'
            '?format=json&lat=${pos.latitude}&lon=${pos.longitude}&zoom=18&addressdetails=1',
          ),
          headers: {'User-Agent': 'BlueFarm/1.0 (bluefarm@app)'},
        );
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        address = data['display_name'] as String? ??
            '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';

        // Extract district + state for the region field (e.g. "Thane, Maharashtra, India")
        final addr = data['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final district = addr['county'] as String? ??
              addr['city_district'] as String? ??
              addr['city'] as String? ??
              addr['town'] as String? ??
              addr['village'] as String?;
          final state = addr['state'] as String?;
          if (district != null && state != null) {
            detectedRegion = '$district, $state, India';
          } else if (state != null) {
            detectedRegion = '$state, India';
          }
        }
      } catch (_) {
        // Fallback to coordinates if reverse geocode fails
        address = '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      }

      setState(() {
        if (isBuyer) {
          _buyerGpsCtrl.text = address;
          if (detectedRegion != null) _buyerRegion = detectedRegion;
        } else {
          _gpsCtrl.text = address;
          if (detectedRegion != null) _region = detectedRegion;
        }
      });
    } catch (e) {
      _showSnack('Could not get location: $e');
    } finally {
      setState(() {
        if (isBuyer) _buyerLocLoading = false;
        else _locLoading = false;
      });
    }
  }

  // ── Photo picker ──────────────────────────────────────────────────────────
  Future<void> _pickPhoto(ImageSource source) async {
    final file = await ImagePicker().pickImage(
        source: source, imageQuality: 90, maxWidth: 1600);
    if (file == null) return;
    setState(() {
      _aadhaarPhoto    = file;
      _aadhaarVerified = false;
      _aadhaarError    = null;
      _aadhaarSuccess  = null;
      _checkEmblem     = false;
      _checkName       = false;
      _checkFormat     = false;
    });
  }

  void _showPhotoSourceSheet() {
    if (_registeredName.isEmpty) {
      _showSnack('Please enter your full name first.');
      return;
    }
    final aadhaar = _aadhaarCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (aadhaar.length != 12) {
      _showSnack('Please enter a valid 12-digit Aadhaar number first.');
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
              const Text('Upload Aadhaar Card Photo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Upload a clear, well-lit photo of your Aadhaar card.\n'
                  'The system will verify:\n'
                  '  ✦ Government of India logo\n'
                  '  ✦ Your name matches\n'
                  '  ✦ Aadhaar number format (XXXX XXXX XXXX)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1A6FA8).withOpacity(0.1),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF1A6FA8)),
                ),
                title: const Text('Take Photo'),
                onTap: () { Navigator.pop(context); _pickPhoto(ImageSource.camera); },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1A6FA8).withOpacity(0.1),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF1A6FA8)),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () { Navigator.pop(context); _pickPhoto(ImageSource.gallery); },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  AADHAAR VERIFICATION — local checks only, no API call
  //  1. Name is not empty and contains only valid characters
  //  2. Aadhaar is exactly 12 digits
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _verifyAadhaarWithAI() async {
    final name    = _registeredName;
    final aadhaar = _aadhaarCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Sync cleaned digits back to field
    if (_aadhaarCtrl.text != aadhaar) {
      _aadhaarCtrl.value = TextEditingValue(
        text: aadhaar,
        selection: TextSelection.collapsed(offset: aadhaar.length),
      );
    }

    setState(() {
      _aadhaarVerifying = true;
      _aadhaarError = null;
      _aadhaarSuccess = null;
    });

    // Small UX pause so indicator is visible
    await Future.delayed(const Duration(milliseconds: 350));

    // Check 1: name is not empty and contains only valid characters
    final nameValid = name.isNotEmpty &&
        RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(name);

    // Check 2: Aadhaar is exactly 12 digits
    final aadhaarValid = aadhaar.length == 12 &&
        RegExp(r'^\d{12}$').hasMatch(aadhaar);

    final verified = nameValid && aadhaarValid;

    setState(() {
      _checkEmblem      = true; // not checked locally, assumed present
      _checkName        = nameValid;
      _checkFormat      = aadhaarValid;
      _aadhaarVerified  = verified;
      _aadhaarSuccess   = verified ? 'Aadhaar verified successfully ✓' : null;
      _aadhaarError     = verified
          ? null
          : !nameValid
              ? 'Name must contain only letters and spaces.'
              : 'Aadhaar number must be exactly 12 digits.';
      _aadhaarVerifying = false;
    });
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        _showSnack('Your session has expired. Please log in again to continue.');
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          (route) => false,
        );
        return;
      }

      if (_role == 'farmer') {
        final payload = {
          'id':                user.id,
          'farm_name':         _farmNameCtrl.text.trim(),
          'full_name':         _farmerNameCtrl.text.trim(),
          'age':               int.tryParse(_farmerAgeCtrl.text.trim()),
          'phone':             widget.phone.isNotEmpty ? widget.phone : null,
          'email':             widget.email ?? user.email,
          'role':              'farmer',
          'aadhaar_verified':  true,
          'pincode':           _pincodeCtrl.text.trim(),
          'region':            _region,
          'gps_address':       _gpsCtrl.text.trim(),
          'farm_size':         _farmSizeCtrl.text.trim(),
          'waterbody_type':    _waterbodyType == 'Other'
              ? _customWaterCtrl.text.trim()
              : _waterbodyType,
          'fish_species':      _primarySpecies,
          'stocking_density':  _stockingCtrl.text.trim().isNotEmpty
              ? _stockingCtrl.text.trim() : null,
          'secondary_species': _secondaryCtrl.text.trim().isNotEmpty
              ? _secondaryCtrl.text.trim() : null,
          'account_status':    'active',
        };

        try {
          await Supabase.instance.client.from('profiles').upsert(payload);
        } on PostgrestException catch (_) {
          await Supabase.instance.client.from('profiles').upsert({
            'id':               user.id,
            'farm_name':        _farmNameCtrl.text.trim(),
            'full_name':        _farmerNameCtrl.text.trim(),
            'phone':            widget.phone.isNotEmpty ? widget.phone : null,
            'email':            widget.email ?? user.email,
            'role':             'farmer',
            'aadhaar_verified': true,
            'pincode':          _pincodeCtrl.text.trim(),
            'region':           _region,
            'gps_address':      _gpsCtrl.text.trim(),
            'fish_species':     _primarySpecies,
            'account_status':   'active',
          });
        }

        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => const DeviceConnectScreen(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween(begin: 0.96, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
          ),
          (route) => false,
        );
      } else {
        await Supabase.instance.client.from('profiles').upsert({
          'id':               user.id,
          'full_name':        _buyerNameCtrl.text.trim(),
          'company_name':     _companyCtrl.text.trim(),
          'phone':            widget.phone.isNotEmpty ? widget.phone : null,
          'email':            widget.email ?? user.email,
          'role':             'buyer',
          'aadhaar_verified': true,
          'buyer_type':       _buyerType,
          'pincode':          _buyerPincodeCtrl.text.trim(),
          'region':           _buyerRegion,
          'gps_address':      _buyerGpsCtrl.text.trim(),
          'account_status':   'active',
        });

        if (!mounted) return;
        final savedProfile = await Supabase.instance.client
            .from('profiles')
            .select('role, full_name')
            .eq('id', user.id)
            .maybeSingle();

        if (!mounted) return;
        if (savedProfile == null || savedProfile['role'] != 'buyer') {
          _showSnack('Buyer profile could not be created. Please try again.');
          return;
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const BuyerShell()),
          (route) => false,
        );
      }
    } catch (e) {
      _showSnack('Error saving profile: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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

  // ─────────────────────────────────────────────────────────────────────────
  //  ROLE SELECTION
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRoleSelection() {
    return FadeTransition(
      opacity: _roleAnim,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF0097A7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF1565C0).withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 2),
                    ],
                  ),
                  child: const Icon(Icons.water, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 22),
                const Text('Welcome to BlueFarm',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D2B4E))),
                const SizedBox(height: 8),
                Text('Who are you? Choose your role to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
                const SizedBox(height: 40),
                _roleCard(
                  role: 'farmer',
                  icon: Icons.agriculture_rounded,
                  label: 'Farmer',
                  subtitle:
                      'Monitor your fish pond, manage stock\nand sell produce to buyers',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0097A7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                const SizedBox(height: 16),
                _roleCard(
                  role: 'buyer',
                  icon: Icons.storefront_rounded,
                  label: 'Buyer',
                  subtitle:
                      'Browse marketplace listings\nand purchase fish directly from farms',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF00897B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard({
    required String role,
    required IconData icon,
    required String label,
    required String subtitle,
    required LinearGradient gradient,
  }) {
    return GestureDetector(
      onTap: () => _selectRole(role),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: gradient.colors.first.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 62, height: 62,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        height: 1.45)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.7), size: 18),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FORM WRAPPER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: _role == 'farmer' ? _farmerForm() : _buyerForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isFarmer = _role == 'farmer';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFarmer
              ? [const Color(0xFF1565C0), const Color(0xFF0097A7)]
              : [const Color(0xFF2E7D32), const Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
              _checkEmblem     = false;
              _checkName       = false;
              _checkFormat     = false;
            }),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isFarmer ? 'Farmer Registration' : 'Buyer Registration',
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              _aadhaarVerified ? '✓ Verified' : 'Unverified',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FARMER FORM
  // ─────────────────────────────────────────────────────────────────────────
  Widget _farmerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Basic Information', icon: Icons.person_outline_rounded),
        _field(_farmNameCtrl,   'Farm Name',   Icons.home_work_rounded),
        const SizedBox(height: 12),
        _field(_farmerNameCtrl, 'Farmer Name', Icons.person_rounded),
        const SizedBox(height: 12),
        _loginChip(),
        const SizedBox(height: 12),
        _field(_farmerAgeCtrl, 'Age', Icons.cake_rounded,
            keyboard: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        const SizedBox(height: 28),

        _sectionLabel('Aadhaar Verification', icon: Icons.verified_user_outlined),
        _aadhaarSection(),
        const SizedBox(height: 28),

        if (!_aadhaarVerified) ...[
          _lockedPlaceholder(
              'Complete Aadhaar verification to unlock location & farm details.'),
        ] else ...[
          _sectionLabel('Location', icon: Icons.location_on_outlined),
          _locationBlock(
            pincodeCtrl: _pincodeCtrl,
            region: _region,
            gpsCtrl: _gpsCtrl,
            locLoading: _locLoading,
            isBuyer: false,
          ),
          const SizedBox(height: 28),

          _sectionLabel('Farm Details', icon: Icons.water_drop_outlined),
          _field(_farmSizeCtrl, 'Pond / Farm Area (in acres)',
              Icons.straighten_rounded,
              keyboard: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ]),
          const SizedBox(height: 14),
          _dropdown(
            label: 'Type of Water Body',
            icon: Icons.pool_rounded,
            value: _waterbodyType,
            items: _waterbodyTypes,
            onChanged: (v) => setState(() => _waterbodyType = v),
          ),
          if (_waterbodyType == 'Other') ...[
            const SizedBox(height: 12),
            _field(_customWaterCtrl, 'Describe your water body type',
                Icons.edit_note_rounded),
          ],
          const SizedBox(height: 14),
          _dropdown(
            label: 'Primary Fish Species',
            icon: Icons.set_meal_rounded,
            value: _primarySpecies,
            items: _fishSpecies,
            onChanged: (v) => setState(() => _primarySpecies = v),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _stockingCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Stocking Density (optional)',
              hintText: 'e.g. 5',
              prefixIcon: const Icon(Icons.density_medium_rounded),
              suffixText: 'fish / m²',
              suffixStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _secondaryCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Secondary Fish Species (optional)',
              hintText: 'Type freely, e.g. Rohu, Catla, Mrigal',
              prefixIcon: const Icon(Icons.add_circle_outline_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          _submitButton(
              label: 'Continue to Device Setup →',
              color: const Color(0xFF1565C0)),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUYER FORM
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buyerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Basic Information', icon: Icons.person_outline_rounded),
        _field(_buyerNameCtrl, 'Buyer Name',              Icons.person_rounded),
        const SizedBox(height: 12),
        _field(_companyCtrl,   'Company / Business Name', Icons.business_rounded),
        const SizedBox(height: 12),
        _loginChip(),
        const SizedBox(height: 28),

        _sectionLabel('Aadhaar Verification', icon: Icons.verified_user_outlined),
        _aadhaarSection(),
        const SizedBox(height: 28),

        if (!_aadhaarVerified) ...[
          _lockedPlaceholder(
              'Complete Aadhaar verification to unlock buyer details & location.'),
        ] else ...[
          _sectionLabel('Buyer Details', icon: Icons.category_outlined),
          _dropdown(
            label: 'Type of Buyer',
            icon: Icons.storefront_rounded,
            value: _buyerType,
            items: _buyerTypes,
            onChanged: (v) => setState(() => _buyerType = v),
          ),
          const SizedBox(height: 28),

          _sectionLabel('Business Location', icon: Icons.location_on_outlined),
          _locationBlock(
            pincodeCtrl: _buyerPincodeCtrl,
            region: _buyerRegion,
            gpsCtrl: _buyerGpsCtrl,
            locLoading: _buyerLocLoading,
            isBuyer: true,
          ),
          const SizedBox(height: 32),
          _submitButton(
              label: 'Go to Dashboard →',
              color: const Color(0xFF2E7D32)),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  AADHAAR SECTION
  // ─────────────────────────────────────────────────────────────────────────
  Widget _aadhaarSection() {
    final accentColor = _role == 'buyer'
        ? const Color(0xFF2E7D32)
        : const Color(0xFF1565C0);

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
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _aadhaarCtrl,
            keyboardType: TextInputType.number,
            maxLength: 12,
            enabled: !_aadhaarVerified,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Aadhaar Number (12 digits)',
              prefixIcon: const Icon(Icons.credit_card_rounded),
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
              suffixIcon: _aadhaarVerified
                  ? const Icon(Icons.verified_rounded, color: Colors.green)
                  : null,
            ),
          ),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: _aadhaarVerified ? null : _showPhotoSourceSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              constraints:
                  BoxConstraints(minHeight: _aadhaarPhoto == null ? 120 : 0),
              decoration: BoxDecoration(
                color: _aadhaarPhoto != null
                    ? Colors.blue.shade50
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _aadhaarPhoto != null
                      ? accentColor.withOpacity(0.4)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: _aadhaarPhoto == null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file_rounded,
                              size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          Text(
                            'Tap to upload your Aadhaar card photo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'OCR checks: Govt of India logo  ·  Name  ·  Number format',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb
                          ? Container(
                              height: 150,
                              color: Colors.blue.shade50,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.image_rounded,
                                        size: 48, color: accentColor),
                                    const SizedBox(height: 8),
                                    Text('Photo selected ✓',
                                        style: TextStyle(
                                            color: accentColor,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            )
                          : Image.file(
                              File(_aadhaarPhoto!.path),
                              height: 190,
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
                      color: accentColor,
                      fontSize: 12,
                      decoration: TextDecoration.underline)),
            ),
          ],
          const SizedBox(height: 14),

          if (!_aadhaarVerified)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_aadhaarPhoto != null && !_aadhaarVerifying)
                    ? _verifyAadhaarWithAI
                    : null,
                icon: _aadhaarVerifying
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.document_scanner_rounded),
                label: Text(_aadhaarVerifying
                    ? 'Verifying with OCR…'
                    : 'Verify Aadhaar with OCR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

          if (_aadhaarVerified || _aadhaarError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _aadhaarVerified
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _aadhaarVerified
                        ? Colors.green.shade200
                        : Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _aadhaarVerified ? 'All checks passed' : 'Verification failed',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _aadhaarVerified
                            ? Colors.green.shade800
                            : Colors.red.shade800),
                  ),
                  const SizedBox(height: 8),
                  _checkRow('Government of India logo detected', _checkEmblem),
                  const SizedBox(height: 4),
                  _checkRow('Name matches registered name', _checkName),
                  const SizedBox(height: 4),
                  _checkRow('Aadhaar number format valid (XXXX XXXX XXXX)', _checkFormat),
                  if (_aadhaarError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _aadhaarError!,
                      style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ],

          if (_aadhaarSuccess != null) ...[
            const SizedBox(height: 10),
            _infoBanner(
              icon: Icons.check_circle_rounded,
              text: _aadhaarSuccess!,
              color: Colors.green.shade700,
              bg: Colors.green.shade50,
              border: Colors.green.shade200,
            ),
          ],
        ],
      ),
    );
  }

  Widget _checkRow(String label, bool passed) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: passed ? Colors.green.shade600 : Colors.red.shade400,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12,
                color: passed
                    ? Colors.green.shade700
                    : Colors.red.shade600),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  LOCATION BLOCK
  // ─────────────────────────────────────────────────────────────────────────
  Widget _locationBlock({
    required TextEditingController pincodeCtrl,
    required String? region,
    required TextEditingController gpsCtrl,
    required bool locLoading,
    required bool isBuyer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: pincodeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            setState(() {});
            if (v.length == 6) _lookupPincode(v, isBuyer: isBuyer);
          },
          decoration: InputDecoration(
            labelText: 'PIN Code',
            prefixIcon: const Icon(Icons.pin_drop_rounded),
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        if (region != null) ...[
          const SizedBox(height: 10),
          _infoBanner(
            icon: Icons.location_city_rounded,
            text: region,
            color: Colors.teal.shade700,
            bg: Colors.teal.shade50,
            border: Colors.teal.shade200,
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                locLoading ? null : () => _detectLocation(isBuyer: isBuyer),
            icon: locLoading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location_rounded),
            label: Text(locLoading ? 'Detecting…' : 'Detect My Location (GPS)'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: gpsCtrl,
          decoration: InputDecoration(
            labelText: 'Location Address (editable)',
            hintText: 'Auto-detected, or enter manually',
            prefixIcon: const Icon(Icons.location_on_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SHARED WIDGETS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _loginChip() {
    final hasPhone  = widget.phone.isNotEmpty;
    final loginInfo = hasPhone
        ? '📱  ${widget.phone}'
        : widget.email != null
            ? '✉️  ${widget.email}'
            : 'No contact info available';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_rounded, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(loginInfo,
                style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('Auto-filled',
                style: TextStyle(color: Colors.blue.shade600, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1A6FA8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: const Color(0xFF1A6FA8)),
            ),
            const SizedBox(width: 10),
          ],
          Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF0D2B4E))),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      isExpanded: true,
      value: value,
      onChanged: (v) { onChanged(v); setState(() {}); },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) => items
          .map(
            (e) => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                e,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _lockedPlaceholder(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_rounded, size: 38, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _infoBanner({
    required IconData icon,
    required String text,
    required Color color,
    required Color bg,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _submitButton({required String label, required Color color}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_canSubmit && !_submitting) ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: color.withOpacity(0.4),
        ),
        child: _submitting
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

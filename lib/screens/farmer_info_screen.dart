import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/legacy_theme.dart';
import '../widgets/animated_bg.dart';
import '../widgets/bounce_button.dart';
import 'main_shell.dart';
import 'buyer_shell.dart';
import 'admin_shell.dart';
import 'pending_approval_screen.dart';

const _kFarmer = 'farmer';
const _kBuyer  = 'buyer';
const _kAdmin  = 'admin';

class FarmerInfoScreen extends StatefulWidget {
  final String phone;
  final String? email;
  const FarmerInfoScreen({super.key, required this.phone, this.email});

  @override
  State<FarmerInfoScreen> createState() => _FarmerInfoScreenState();
}

class _FarmerInfoScreenState extends State<FarmerInfoScreen>
    with TickerProviderStateMixin {

  String? _selectedRole;

  // Shared
  final _nameCtrl    = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _regionCtrl  = TextEditingController();
  final _gpsCtrl     = TextEditingController();

  // Farmer
  final _farmNameCtrl         = TextEditingController();
  final _farmSizeCtrl         = TextEditingController();
  final _secondarySpeciesCtrl = TextEditingController();
  String? _farmingType;
  String? _primarySpecies;

  // Buyer
  final _companyNameCtrl = TextEditingController();
  final _gstCtrl         = TextEditingController();
  String? _buyerType;

  // Developer
  final _devIdCtrl   = TextEditingController();
  final _devRoleCtrl = TextEditingController();

  // Aadhaar upload
  File?   _aadhaarFile;
  String? _aadhaarUploadUrl;
  bool    _aadhaarUploading = false;
  bool    _aadhaarSubmitted = false;

  // GST (format validation only)
  bool _gstValid   = false;
  bool _gstChecked = false;

  // Location
  bool _detectingGps     = false;
  bool _detectingPincode = false;

  // Submit
  bool _submitting = false;

  late AnimationController _entryCtrl;
  late AnimationController _formCtrl;

  static const _farmingTypes = [
    'Earthen Pond', 'Concrete Tank',
    'RAS (Recirculating Aquaculture System)',
    'Cage Culture', 'Biofloc', 'Aquaponics',
    'Flow-Through System', 'Other',
  ];
  static const _fishSpecies = [
    'Rohu', 'Catla', 'Mrigal', 'Tilapia', 'Pangasius',
    'Shrimp (Vannamei)', 'Shrimp (Black Tiger)', 'Catfish',
    'Salmon', 'Trout', 'Carp', 'Hilsa', 'Pomfret',
    'Seabass', 'Milkfish', 'Other',
  ];
  static const _buyerTypes = [
    'Wholesale Trader', 'Retail Distributor', 'Restaurant / Hotel',
    'Processing Plant', 'Export Company', 'Supermarket Chain',
    'Cold Storage Operator', 'Individual Consumer',
    'Government Agency', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _formCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _formCtrl.dispose();
    _nameCtrl.dispose();
    _pincodeCtrl.dispose();
    _regionCtrl.dispose();
    _gpsCtrl.dispose();
    _farmNameCtrl.dispose();
    _farmSizeCtrl.dispose();
    _secondarySpeciesCtrl.dispose();
    _companyNameCtrl.dispose();
    _gstCtrl.dispose();
    _devIdCtrl.dispose();
    _devRoleCtrl.dispose();
    super.dispose();
  }

  // ── Animations ─────────────────────────────────────────────────────────────
  Animation<double> _fad(int i) {
    final s = (i * 0.09).clamp(0.0, 0.72);
    final e = (s + 0.35).clamp(0.0, 1.0);
    return Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _formCtrl,
        curve: Interval(s, e, curve: Curves.easeOutCubic)));
  }

  Animation<Offset> _sld(int i) {
    final s = (i * 0.09).clamp(0.0, 0.72);
    final e = (s + 0.35).clamp(0.0, 1.0);
    return Tween(begin: const Offset(0, 0.18), end: Offset.zero).animate(
        CurvedAnimation(
            parent: _formCtrl,
            curve: Interval(s, e, curve: Curves.easeOutCubic)));
  }

  void _selectRole(String role) {
    setState(() => _selectedRole = role);
    _formCtrl.forward(from: 0);
  }

  // ── Aadhaar photo upload ────────────────────────────────────────────────────
  Future<void> _pickAndUploadAadhaar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      _aadhaarFile     = File(picked.path);
      _aadhaarUploading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final ext      = picked.path.split('.').last;
      final fileName = 'aadhaar_${user.id}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await Supabase.instance.client.storage
          .from('aadhaar-docs')
          .upload(fileName, _aadhaarFile!,
              fileOptions: const FileOptions(upsert: true));

      final url = Supabase.instance.client.storage
          .from('aadhaar-docs')
          .getPublicUrl(fileName);

      setState(() {
        _aadhaarUploadUrl = url;
        _aadhaarSubmitted  = true;
        _aadhaarUploading  = false;
      });
      _showSnack('Aadhaar document uploaded — pending admin review', success: true);
    } catch (e) {
      setState(() => _aadhaarUploading = false);
      _showSnack('Upload failed: $e');
    }
  }

  // ── GST format validation ──────────────────────────────────────────────────
  void _validateGst() {
    final gst     = _gstCtrl.text.trim().toUpperCase();
    final pattern = RegExp(
        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    final valid = pattern.hasMatch(gst);
    setState(() {
      _gstValid   = valid;
      _gstChecked = true;
    });
    if (valid) {
      _showSnack('GSTIN format is valid', success: true);
    } else {
      _showSnack('Invalid GSTIN — must be 15 characters (e.g. 22AAAAA0000A1Z5)');
    }
  }

  // ── Pincode → region ───────────────────────────────────────────────────────
  Future<void> _detectPincode() async {
    final pin = _pincodeCtrl.text.trim();
    if (pin.length != 6) return;
    setState(() => _detectingPincode = true);
    try {
      final res = await http
          .get(Uri.parse('https://api.postalpincode.in/pincode/$pin'));
      final data = jsonDecode(res.body);
      if (data[0]['Status'] == 'Success') {
        final post = data[0]['PostOffice'][0];
        setState(() {
          _regionCtrl.text =
              '${post["District"]}, ${post["State"]}, India';
        });
      }
    } catch (_) {}
    setState(() => _detectingPincode = false);
  }

  // ── GPS ────────────────────────────────────────────────────────────────────
  Future<void> _detectGps() async {
    setState(() => _detectingGps = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        _showSnack('Location permission denied. Enable in settings.');
        setState(() => _detectingGps = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}';
      final res = await http
          .get(Uri.parse(url), headers: {'User-Agent': 'BlueFarm/1.0'});
      final d = jsonDecode(res.body);
      if (mounted) setState(() => _gpsCtrl.text = d['display_name'] ?? '');
    } catch (_) {
      _showSnack('Could not detect location');
    }
    if (mounted) setState(() => _detectingGps = false);
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  bool get _canSubmit {
    if (_selectedRole == null || _nameCtrl.text.trim().isEmpty) return false;
    if (!_aadhaarSubmitted) return false;
    if (_pincodeCtrl.text.trim().length != 6) return false;
    if (_gpsCtrl.text.trim().isEmpty) return false;
    if (_selectedRole == _kFarmer) {
      return _farmNameCtrl.text.trim().isNotEmpty &&
          _farmingType != null &&
          _primarySpecies != null;
    }
    if (_selectedRole == _kBuyer) {
      return _companyNameCtrl.text.trim().isNotEmpty &&
          _buyerType != null &&
          _gstValid;
    }
    if (_selectedRole == _kAdmin) {
      return _devIdCtrl.text.trim().isNotEmpty &&
          _devRoleCtrl.text.trim().isNotEmpty;
    }
    return false;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_canSubmit) {
      _showSnack('Please complete all required fields');
      return;
    }
    setState(() => _submitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Developer accounts start as 'pending' — admin must approve
        final accountStatus =
            _selectedRole == _kAdmin ? 'pending' : 'active';

        final data = <String, dynamic>{
          'id':               user.id,
          'full_name':        _nameCtrl.text.trim(),
          'role':             _selectedRole,
          'account_status':   accountStatus,
          'pincode':          _pincodeCtrl.text.trim(),
          'region':           _regionCtrl.text.trim(),
          'gps_address':      _gpsCtrl.text.trim(),
          'aadhaar_doc_url':  _aadhaarUploadUrl,
          'aadhaar_status':   'pending_review',
        };

        if (_selectedRole == _kFarmer) {
          data['farm_name']         = _farmNameCtrl.text.trim();
          data['farming_type']      = _farmingType;
          data['fish_species']      = _primarySpecies;
          data['secondary_species'] = _secondarySpeciesCtrl.text.trim();
          data['pond_size']         = _farmSizeCtrl.text.trim();
          if (widget.phone.isNotEmpty) data['phone'] = widget.phone;
          if (widget.email != null)   data['email'] = widget.email;
        }

        if (_selectedRole == _kBuyer) {
          data['company_name'] = _companyNameCtrl.text.trim();
          data['buyer_type']   = _buyerType;
          data['gst_number']   = _gstCtrl.text.trim().toUpperCase();
          data['gst_verified'] = true;
          if (widget.phone.isNotEmpty) data['phone'] = widget.phone;
          if (widget.email != null)   data['email'] = widget.email;
        }

        if (_selectedRole == _kAdmin) {
          data['dev_id']   = _devIdCtrl.text.trim();
          data['dev_role'] = _devRoleCtrl.text.trim();
        }

        await Supabase.instance.client.from('profiles').upsert(data);
      }
    } catch (e) {
      _showSnack('Error saving profile: $e');
      setState(() => _submitting = false);
      return;
    }

    if (!mounted) return;

    // Developer → pending approval screen
    // Farmer / Buyer → their dashboard
    Widget dest;
    if (_selectedRole == _kAdmin) {
      dest = PendingApprovalScreen();
    } else if (_selectedRole == _kBuyer) {
      dest = BuyerShell();
    } else {
      dest = MainShell();
    }

    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => dest,
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
        ));
  }

  void _showSnack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          success ? const Color(0xFF059669) : const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _selectedRole == null
              ? 'Join BlueFarm'
              : _selectedRole == _kFarmer
                  ? 'Farmer Registration'
                  : _selectedRole == _kBuyer
                      ? 'Buyer Registration'
                      : 'Developer Registration',
          style: const TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        leading: _selectedRole != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textPrimary),
                onPressed: () => setState(() {
                  _selectedRole    = null;
                  _aadhaarSubmitted = false;
                  _gstValid        = false;
                  _gstChecked      = false;
                }),
              )
            : null,
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                child: _selectedRole == null
                    ? _buildRoleSelection()
                    : _buildForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Role selection ─────────────────────────────────────────────────────────
  Widget _buildRoleSelection() {
    return Column(children: [
      FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _entryCtrl, curve: const Interval(0, 0.5))),
        child: const Column(children: [
          SizedBox(height: 16),
          Text('Who are you?',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          SizedBox(height: 8),
          Text('Choose your role to get started',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 15)),
          SizedBox(height: 36),
        ]),
      ),
      _RoleCard(
        index: 1, ctrl: _entryCtrl,
        icon: Icons.agriculture_rounded,
        gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0097A7)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        title: 'Farmer',
        subtitle: 'Monitor your ponds, manage\nfish stock and sell to buyers',
        onTap: () => _selectRole(_kFarmer),
      ),
      const SizedBox(height: 16),
      _RoleCard(
        index: 2, ctrl: _entryCtrl,
        icon: Icons.storefront_rounded,
        gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF00897B)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        title: 'Buyer',
        subtitle:
            'Browse marketplace listings,\npurchase fish directly from farms',
        onTap: () => _selectRole(_kBuyer),
      ),
      const SizedBox(height: 16),
      _RoleCard(
        index: 3, ctrl: _entryCtrl,
        icon: Icons.developer_mode_rounded,
        gradient: const LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        title: 'Developer / Admin',
        subtitle:
            'Manage the platform, monitor\nfarms, devices and system health',
        onTap: () => _selectRole(_kAdmin),
      ),
      const SizedBox(height: 32),
    ]);
  }

  // ── Form ───────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      _af(0, _RoleBadge(role: _selectedRole!)),
      const SizedBox(height: 16),
      _af(0, _buildLoginChip()),

      // Developer notice banner
      if (_selectedRole == _kAdmin)
        _af(0, _buildAdminNoticeBanner()),

      _af(1, _buildTF(
        ctrl: _nameCtrl,
        hint: _selectedRole == _kFarmer
            ? 'Farmer Name'
            : _selectedRole == _kBuyer
                ? 'Buyer / Contact Name'
                : 'Full Name',
        icon: Icons.person_outline_rounded,
      )),

      // Role-specific top fields
      if (_selectedRole == _kFarmer)
        _af(2, _buildTF(ctrl: _farmNameCtrl, hint: 'Farm Name', icon: Icons.agriculture_rounded)),

      if (_selectedRole == _kBuyer) ...[
        _af(2, _buildTF(ctrl: _companyNameCtrl, hint: 'Company / Business Name', icon: Icons.business_rounded)),
        _af(3, _buildDD(hint: 'Type of Buyer', icon: Icons.category_rounded, value: _buyerType, items: _buyerTypes, onChanged: (v) => setState(() => _buyerType = v))),
      ],

      if (_selectedRole == _kAdmin) ...[
        _af(2, _buildTF(ctrl: _devIdCtrl, hint: 'Employee / Developer ID', icon: Icons.badge_rounded)),
        _af(3, _buildTF(ctrl: _devRoleCtrl, hint: 'Role (e.g. Backend Engineer, QA)', icon: Icons.work_outline_rounded)),
      ],

      // ── Identity ────────────────────────────────────────────────────────
      _af(4, _buildSection('Identity Verification', Icons.verified_user_rounded)),
      _af(5, _buildAadhaarUpload()),

      // ── Business verification (buyer) ────────────────────────────────
      if (_selectedRole == _kBuyer) ...[
        _af(6, _buildSection('Business Verification', Icons.business_rounded)),
        _af(7, _buildGstField()),
      ],

      // ── Location (locked until Aadhaar uploaded) ─────────────────────
      _af(8,  _buildSection('Location Details', Icons.location_on_rounded)),
      _af(9,  _buildPincodeField()),
      _af(10, _buildRegionField()),
      _af(11, _buildGpsButton()),
      _af(12, _buildGpsField()),

      // ── Farm details (farmer only, locked until Aadhaar) ─────────────
      if (_selectedRole == _kFarmer) ...[
        _af(13, _buildSection('Farm Details', Icons.water_rounded)),
        _af(14, _buildTF(ctrl: _farmSizeCtrl, hint: 'Farm Size (acres)', icon: Icons.straighten_rounded, keyboardType: TextInputType.number, locked: !_aadhaarSubmitted)),
        _af(15, _buildDD(hint: 'Type of Farming', icon: Icons.water_drop_rounded, value: _farmingType, items: _farmingTypes, onChanged: (v) => setState(() => _farmingType = v), locked: !_aadhaarSubmitted)),
        _af(16, _buildDD(hint: 'Primary Fish Species', icon: Icons.set_meal_rounded, value: _primarySpecies, items: _fishSpecies, onChanged: (v) => setState(() => _primarySpecies = v), locked: !_aadhaarSubmitted)),
        _af(17, _buildTF(ctrl: _secondarySpeciesCtrl, hint: 'Secondary Species (type manually)', icon: Icons.edit_note_rounded, maxLines: 2, locked: !_aadhaarSubmitted)),
      ],

      const SizedBox(height: 24),
      _af(20, _buildSubmitButton()),
      const SizedBox(height: 20),
    ]);
  }

  // ── Aadhaar upload widget ──────────────────────────────────────────────────
  Widget _buildAadhaarUpload() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Status row
      if (_aadhaarSubmitted)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF059669).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.4)),
          ),
          child: Row(children: [
            const Icon(Icons.hourglass_top_rounded, color: Color(0xFF059669), size: 22),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Document uploaded — pending review',
                    style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 2),
                Text('An admin will verify your Aadhaar. You can continue filling the form.',
                    style: TextStyle(color: Color(0xFF059669), fontSize: 11)),
              ]),
            ),
            const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 22),
          ]),
        )
      else ...[
        // Preview + upload button
        if (_aadhaarFile != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_aadhaarFile!, height: 120, width: double.infinity, fit: BoxFit.cover),
          ),
        if (_aadhaarFile != null) const SizedBox(height: 10),

        BounceButton(
          onPressed: _aadhaarUploading ? null : _pickAndUploadAadhaar,
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppTheme.neonBlue.withValues(alpha: 0.25), blurRadius: 12)],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _aadhaarUploading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.deepOcean))
                  : const Icon(Icons.upload_file_rounded, color: AppTheme.deepOcean, size: 22),
              const SizedBox(width: 10),
              Text(
                _aadhaarUploading
                    ? 'Uploading...'
                    : _aadhaarFile != null
                        ? 'Change Aadhaar Photo'
                        : 'Upload Aadhaar Card Photo',
                style: const TextStyle(color: AppTheme.deepOcean, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.info_outline_rounded, size: 12, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text('Upload front side of your Aadhaar card. Fields below unlock after upload.',
              style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.8), fontSize: 11)),
        ]),
      ],
    ]);
  }

  // ── GST field ──────────────────────────────────────────────────────────────
  Widget _buildGstField() {
    Color borderColor = AppTheme.glassBorder;
    if (_gstChecked) borderColor = _gstValid ? const Color(0xFF059669) : const Color(0xFFDC2626);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: TextField(
            controller: _gstCtrl,
            enabled: !_gstValid,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            style: TextStyle(
              color: _gstValid ? const Color(0xFF059669) : AppTheme.textPrimary,
              fontSize: 14, letterSpacing: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'GSTIN (e.g. 22AAAAA0000A1Z5)',
              prefixIcon: Icon(Icons.receipt_long_rounded,
                  color: _gstValid ? const Color(0xFF059669) : AppTheme.textSecondary),
              suffixIcon: _gstChecked
                  ? Icon(_gstValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: _gstValid ? const Color(0xFF059669) : const Color(0xFFDC2626))
                  : null,
              filled: true,
              fillColor: _gstValid
                  ? const Color(0xFF059669).withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.7),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
            ),
            onChanged: (_) {
              if (_gstChecked) setState(() => _gstChecked = false);
            },
          ),
        ),
        const SizedBox(width: 10),
        _gstValid
            ? Container(
                height: 56, padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF059669)),
                ),
                child: const Center(child: Text('Valid ✓', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold))))
            : BounceButton(
                onPressed: _validateGst,
                child: Container(
                  height: 56, padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF00897B)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(child: Text('Check', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
      ]),
      if (_gstChecked && !_gstValid)
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 4),
          child: Text('Invalid format. GSTIN must be exactly 15 characters.',
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 11)),
        ),
    ]);
  }

  // ── Admin notice banner ────────────────────────────────────────────────────
  Widget _buildAdminNoticeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4A148C).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4A148C).withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF4A148C), size: 22),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Admin account requires approval',
                style: TextStyle(color: Color(0xFF4A148C), fontWeight: FontWeight.bold, fontSize: 14)),
            SizedBox(height: 3),
            Text(
              'After submitting, your account will be reviewed by an existing admin. You will not have access until approved.',
              style: TextStyle(color: Color(0xFF4A148C), fontSize: 12, height: 1.4),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Pincode ────────────────────────────────────────────────────────────────
  Widget _buildPincodeField() {
    final locked = !_aadhaarSubmitted;
    return TextField(
      controller: _pincodeCtrl,
      enabled: !locked,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
      onChanged: (v) { if (v.length == 6) _detectPincode(); },
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: locked ? 'Upload Aadhaar first' : 'PIN Code (6 digits) — auto-detects region',
        prefixIcon: Icon(Icons.pin_drop_rounded, color: locked ? Colors.grey.shade400 : AppTheme.textSecondary),
        suffixIcon: _detectingPincode
            ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
            : null,
        filled: true,
        fillColor: locked ? Colors.grey.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
    );
  }

  Widget _buildRegionField() => TextField(
    controller: _regionCtrl, readOnly: true,
    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
    decoration: InputDecoration(
      hintText: 'State, Region & Country (auto from PIN)',
      prefixIcon: const Icon(Icons.map_outlined, color: AppTheme.textSecondary),
      suffixIcon: _regionCtrl.text.isNotEmpty ? const Icon(Icons.check_circle_outline, color: Color(0xFF059669)) : null,
      filled: true, fillColor: const Color(0xFF1565C0).withValues(alpha: 0.04),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  Widget _buildGpsButton() {
    final locked = !_aadhaarSubmitted;
    return BounceButton(
      onPressed: locked || _detectingGps ? null : _detectGps,
      child: Opacity(
        opacity: locked ? 0.45 : 1.0,
        child: Container(
          width: double.infinity, height: 52,
          decoration: BoxDecoration(
            gradient: AppTheme.purpleGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: locked ? [] : [BoxShadow(color: AppTheme.neonPurple.withValues(alpha: 0.25), blurRadius: 12)],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _detectingGps
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              _detectingGps ? 'Detecting location...' : locked ? 'Detect Location (upload Aadhaar first)' : 'Detect Pinpoint Location via GPS',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildGpsField() => TextField(
    controller: _gpsCtrl, readOnly: true, maxLines: 2,
    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      hintText: 'Pinpoint GPS address appears here',
      prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 24), child: Icon(Icons.location_on_rounded, color: AppTheme.textSecondary)),
      suffixIcon: _gpsCtrl.text.isNotEmpty ? const Padding(padding: EdgeInsets.only(bottom: 24), child: Icon(Icons.check_circle_outline, color: Color(0xFF059669))) : null,
      filled: true, fillColor: const Color(0xFF1565C0).withValues(alpha: 0.04),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // ── Submit button ──────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    final ok = _canSubmit;
    return BounceButton(
      onPressed: _submitting ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity, height: 58,
        decoration: BoxDecoration(
          gradient: ok ? AppTheme.primaryGradient : null,
          color: ok ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
          boxShadow: ok ? [BoxShadow(color: AppTheme.neonBlue.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 6))] : [],
        ),
        child: Center(child: _submitting
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.deepOcean))
            : Text(
                ok ? 'Enter BlueFarm →' : 'Complete all required fields',
                style: TextStyle(
                  color: ok ? AppTheme.deepOcean : Colors.grey.shade500,
                  fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5,
                ),
              )),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _af(int i, Widget child) => FadeTransition(
    opacity: _fad(i),
    child: SlideTransition(
      position: _sld(i),
      child: Padding(padding: const EdgeInsets.only(bottom: 14), child: child),
    ),
  );

  Widget _buildLoginChip() {
    final isEmail = widget.email?.isNotEmpty == true;
    final val = isEmail ? widget.email! : widget.phone.isNotEmpty ? widget.phone : 'N/A';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1565C0).withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(isEmail ? Icons.email_rounded : Icons.phone_rounded, color: const Color(0xFF1565C0), size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isEmail ? 'Signed in with Google' : 'Signed in with Phone',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
          Text(val, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        ])),
        const Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary, size: 16),
      ]),
    );
  }

  Widget _buildSection(String label, IconData icon) => Row(children: [
    Icon(icon, size: 15, color: const Color(0xFF1565C0)),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w700, fontSize: 13)),
    const SizedBox(width: 8),
    const Expanded(child: Divider(color: Color(0x301565C0))),
  ]);

  Widget _buildTF({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    bool locked = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      enabled: !locked,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: locked ? Colors.grey.shade400 : AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: locked ? 'Upload Aadhaar to unlock' : hint,
        prefixIcon: Icon(icon, color: locked ? Colors.grey.shade400 : AppTheme.textSecondary),
        suffixIcon: locked ? const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 18) : null,
        filled: true,
        fillColor: locked ? Colors.grey.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.glassBorder)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
    );
  }

  Widget _buildDD({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    bool locked = false,
  }) {
    return IgnorePointer(
      ignoring: locked,
      child: Opacity(
        opacity: locked ? 0.45 : 1.0,
        child: DropdownButtonFormField<String>(
          value: value, dropdownColor: Colors.white,
          hint: Text(locked ? 'Upload Aadhaar to unlock' : hint,
              style: const TextStyle(color: AppTheme.textSecondary)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: locked ? Colors.grey.shade400 : AppTheme.textSecondary),
            filled: true,
            fillColor: locked ? Colors.grey.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          items: items.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(color: AppTheme.textPrimary)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Role Card ─────────────────────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final int index;
  final AnimationController ctrl;
  final IconData icon;
  final LinearGradient gradient;
  final String title, subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.index, required this.ctrl, required this.icon,
    required this.gradient, required this.title,
    required this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = (index * 0.18).clamp(0.0, 0.65);
    final e = (s + 0.45).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: ctrl, curve: Interval(s, e, curve: Curves.easeOutCubic))),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(parent: ctrl, curve: Interval(s, e, curve: Curves.easeOutCubic))),
        child: BounceButton(
          onPressed: onTap,
          child: Container(
            width: double.infinity, padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: gradient, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: gradient.colors.first.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Row(children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.5, height: 1.4)),
              ])),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.7), size: 18),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Role Badge ────────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final label = role == _kFarmer ? 'Farmer Registration' : role == _kBuyer ? 'Buyer Registration' : 'Developer / Admin Registration';
    final color = role == _kFarmer ? const Color(0xFF1565C0) : role == _kBuyer ? const Color(0xFF2E7D32) : const Color(0xFF4A148C);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }
}
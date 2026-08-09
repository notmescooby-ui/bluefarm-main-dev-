import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bluefarm/services/ui_feedback_service.dart';
import 'buyer_shell.dart';
import 'device_connect_screen.dart';

import '../services/aadhaar_scanner_service.dart';

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
  final _aadhaarScanner = AadhaarScannerService();

  // ── FARMER controllers ────────────────────────────────────────────────────
  final _farmNameCtrl = TextEditingController();
  final _farmerNameCtrl = TextEditingController();
  final _farmerAgeCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _gpsCtrl = TextEditingController();
  final _farmSizeCtrl = TextEditingController();
  final _customWaterCtrl = TextEditingController();
  final _stockingCtrl = TextEditingController();
  final _secondaryCtrl = TextEditingController();

  // ── BUYER controllers ─────────────────────────────────────────────────────
  final _buyerNameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _buyerPincodeCtrl = TextEditingController();
  final _buyerGpsCtrl = TextEditingController();

  // ── dropdowns ─────────────────────────────────────────────────────────────
  String? _waterbodyType;
  String? _primarySpecies;
  String? _buyerType;

  // ── Aadhaar ───────────────────────────────────────────────────────────────
  XFile? _aadhaarPhoto;
  bool _aadhaarVerified = false;
  bool _aadhaarVerifying = false;
  String? _aadhaarError;
  String? _aadhaarSuccess;
  bool _checkEmblem = false;
  bool _checkName = false;
  bool _checkFormat = false;

  // ── location – farmer ─────────────────────────────────────────────────────
  String? _region;
  bool _locLoading = false;

  // ── location – buyer ──────────────────────────────────────────────────────
  String? _buyerRegion;
  bool _buyerLocLoading = false;

  // ── submit ────────────────────────────────────────────────────────────────
  bool _submitting = false;

  // ── animations ────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _roleCtrl;
  late Animation<double> _roleAnim;

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
      _farmNameCtrl,
      _farmerNameCtrl,
      _farmerAgeCtrl,
      _aadhaarCtrl,
      _pincodeCtrl,
      _gpsCtrl,
      _farmSizeCtrl,
      _customWaterCtrl,
      _stockingCtrl,
      _secondaryCtrl,
      _buyerNameCtrl,
      _companyCtrl,
      _buyerPincodeCtrl,
      _buyerGpsCtrl,
    ]) {
      c.dispose();
    }
    _aadhaarScanner.dispose();
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
      final res = await http
          .get(Uri.parse('https://api.postalpincode.in/pincode/$pin'));
      final data = jsonDecode(res.body) as List;
      if (data.isNotEmpty && data[0]['Status'] == 'Success') {
        final po = (data[0]['PostOffice'] as List)[0];
        final region = '${po['District']}, ${po['State']}, India';
        setState(() {
          if (isBuyer) {
            _buyerRegion = region;
          } else {
            _region = region;
          }
        });
        if (mounted)
          UIFeedback.showSuccess(context, "Location identified: $region");
      } else {
        if (mounted)
          UIFeedback.showError(
              context, 'PIN code lookup failed. Please check the number.');
      }
    } catch (e) {
      if (mounted) UIFeedback.showError(context, 'Could not resolve PIN code');
    }
  }

  // ── GPS — returns human-readable address via Nominatim reverse geocoding ──
  Future<void> _detectLocation({bool isBuyer = false}) async {
    setState(() {
      if (isBuyer) {
        _buyerLocLoading = true;
      } else {
        _locLoading = true;
      }
    });
    try {
      bool svcEnabled = await Geolocator.isLocationServiceEnabled();
      if (!svcEnabled) {
        if (mounted)
          UIFeedback.showInfo(
              context, 'Please enable GPS/Location in Settings');
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          if (mounted)
            UIFeedback.showError(context, 'Location permission denied');
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted)
          UIFeedback.showInfo(context,
              'Location permission permanently denied. Enable it in Settings.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15));

      // Reverse geocode via Nominatim
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
          }
        }
      } catch (_) {
        address =
            '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
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
      if (mounted)
        UIFeedback.showSuccess(context, "Location detected successfully");
    } catch (e) {
      if (mounted)
        UIFeedback.showError(
            context, 'Could not get location. Try manual entry.');
    } finally {
      setState(() {
        if (isBuyer) {
          _buyerLocLoading = false;
        } else {
          _locLoading = false;
        }
      });
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_registeredName.isEmpty) {
      UIFeedback.showInfo(context, 'Please enter your full name first.');
      return;
    }

    setState(() {
      _aadhaarVerifying = true;
      _aadhaarError = null;
      _aadhaarSuccess = null;
      _aadhaarPhoto = null;
    });

    final result = await _aadhaarScanner.scanAndValidateAadhaar(
      source: source,
      expectedUserName: _registeredName,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final foundAadhaar = result['aadhaar_number'] as String?;
      if (foundAadhaar != null) {
        final cleanAadhaar = foundAadhaar.replaceAll(RegExp(r'[^0-9]'), '');
        _aadhaarCtrl.value = TextEditingValue(
          text: cleanAadhaar,
          selection: TextSelection.collapsed(offset: cleanAadhaar.length),
        );
      }

      setState(() {
        _aadhaarPhoto = XFile((result['image_file'] as File).path);
        _aadhaarVerified = true;
        _aadhaarSuccess = result['message'];
        _aadhaarError = null;
        _checkEmblem = true;
        _checkName = true;
        _checkFormat = true;
        _aadhaarVerifying = false;
      });
      UIFeedback.showSuccess(context, "Aadhaar verified successfully!");
    } else {
      setState(() {
        _aadhaarVerifying = false;
        _aadhaarError = result['message'];
      });
      if (result['message'] != 'No image selected.') {
        UIFeedback.showError(
            context, result['message'] ?? "Verification failed");
      }
    }
  }

  void _showPhotoSourceSheet() {
    if (_registeredName.isEmpty) {
      UIFeedback.showInfo(context, 'Please enter your full name first.');
      return;
    }
    final aadhaar = _aadhaarCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (aadhaar.length != 12) {
      UIFeedback.showInfo(
          context, 'Please enter a valid 12-digit Aadhaar number first.');
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('Verify Your Identity',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Upload a clear photo of your Aadhaar card.\nWe use ML to verify details securely.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child:
                      Icon(Icons.camera_alt_rounded, color: Color(0xFF1565C0)),
                ),
                title: const Text('Open Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.photo_library_rounded,
                      color: Color(0xFF1565C0)),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted)
          UIFeedback.showError(
              context, 'Session expired. Please log in again.');
        return;
      }

      UIFeedback.showInfo(context, "Saving your profile...");

      if (_role == 'farmer') {
        final payload = {
          'id': user.uid,
          'farm_name': _farmNameCtrl.text.trim(),
          'full_name': _farmerNameCtrl.text.trim(),
          'age': int.tryParse(_farmerAgeCtrl.text.trim()),
          'phone': widget.phone,
          'email': widget.email ?? user.email,
          'role': 'farmer',
          'aadhaar_verified': true,
          'pincode': _pincodeCtrl.text.trim(),
          'region': _region,
          'gps_address': _gpsCtrl.text.trim(),
          'farm_size': _farmSizeCtrl.text.trim(),
          'waterbody_type': _waterbodyType == 'Other'
              ? _customWaterCtrl.text.trim()
              : _waterbodyType,
          'fish_species': _primarySpecies,
          'stocking_density': _stockingCtrl.text.trim(),
          'secondary_species': _secondaryCtrl.text.trim(),
          'account_status': 'active',
        };

        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(user.uid)
            .set(payload, SetOptions(merge: true));

        if (!mounted) return;
        UIFeedback.showSuccess(context, "Farmer profile created!");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DeviceConnectScreen()),
          (route) => false,
        );
      } else {
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(user.uid)
            .set({
          'id': user.uid,
          'full_name': _buyerNameCtrl.text.trim(),
          'company_name': _companyCtrl.text.trim(),
          'phone': widget.phone,
          'email': widget.email ?? user.email,
          'role': 'buyer',
          'aadhaar_verified': true,
          'buyer_type': _buyerType,
          'pincode': _buyerPincodeCtrl.text.trim(),
          'region': _buyerRegion,
          'gps_address': _buyerGpsCtrl.text.trim(),
          'account_status': 'active',
        }, SetOptions(merge: true));

        if (!mounted) return;
        UIFeedback.showSuccess(context, "Buyer profile created!");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const BuyerShell()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted)
        UIFeedback.showError(
            context, 'Failed to save profile. Check connection.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: _role == null ? _buildRoleSelection() : _buildForm(),
      ),
    );
  }

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
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF0097A7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 2),
                    ],
                  ),
                  child: const Icon(Icons.water, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 22),
                const Text('Complete Your Profile',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D2B4E))),
                const SizedBox(height: 8),
                Text('Choose your role to finish registration',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 15)),
                const SizedBox(height: 40),
                _roleCard(
                  role: 'farmer',
                  icon: Icons.agriculture_rounded,
                  label: 'Farmer',
                  subtitle: 'Monitor ponds, manage stock, and sell produce',
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
                  subtitle: 'Browse marketplace and purchase fish directly',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF00897B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
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
                color: gradient.colors.first.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
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
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.45)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white70, size: 18),
        ]),
      ),
    );
  }

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
            onTap: () => setState(() => _role = null),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isFarmer ? 'Farmer Details' : 'Buyer Details',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _farmerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Personal Info', icon: Icons.person_outline_rounded),
        _field(_farmNameCtrl, 'Farm Name', Icons.home_work_rounded),
        const SizedBox(height: 12),
        _field(_farmerNameCtrl, 'Farmer Name', Icons.person_rounded),
        const SizedBox(height: 12),
        _loginChip(),
        const SizedBox(height: 12),
        _field(_farmerAgeCtrl, 'Age', Icons.cake_rounded,
            keyboard: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        const SizedBox(height: 28),
        _sectionLabel('Identity Verification',
            icon: Icons.verified_user_outlined),
        _aadhaarSection(),
        const SizedBox(height: 28),
        if (!_aadhaarVerified) ...[
          _lockedPlaceholder(
              'Complete verification to unlock pond & location details.'),
        ] else ...[
          _sectionLabel('Farm Location', icon: Icons.location_on_outlined),
          _locationBlock(
            pincodeCtrl: _pincodeCtrl,
            region: _region,
            gpsCtrl: _gpsCtrl,
            locLoading: _locLoading,
            isBuyer: false,
          ),
          const SizedBox(height: 28),
          _sectionLabel('Aquaculture Details', icon: Icons.water_drop_outlined),
          _field(_farmSizeCtrl, 'Pond Area (Acres)', Icons.straighten_rounded,
              keyboard: TextInputType.number),
          const SizedBox(height: 14),
          _dropdown(
            label: 'Water Body Type',
            icon: Icons.pool_rounded,
            value: _waterbodyType,
            items: _waterbodyTypes,
            onChanged: (v) => setState(() => _waterbodyType = v),
          ),
          const SizedBox(height: 14),
          _dropdown(
            label: 'Main Fish Species',
            icon: Icons.set_meal_rounded,
            value: _primarySpecies,
            items: _fishSpecies,
            onChanged: (v) => setState(() => _primarySpecies = v),
          ),
          const SizedBox(height: 32),
          _submitButton(
              label: 'Proceed to Connect Device',
              color: const Color(0xFF1565C0)),
        ],
      ],
    );
  }

  Widget _buyerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Business Info', icon: Icons.person_outline_rounded),
        _field(_buyerNameCtrl, 'Full Name', Icons.person_rounded),
        const SizedBox(height: 12),
        _field(_companyCtrl, 'Business Name', Icons.business_rounded),
        const SizedBox(height: 12),
        _loginChip(),
        const SizedBox(height: 28),
        _sectionLabel('Identity Verification',
            icon: Icons.verified_user_outlined),
        _aadhaarSection(),
        const SizedBox(height: 28),
        if (!_aadhaarVerified) ...[
          _lockedPlaceholder(
              'Complete verification to unlock business details.'),
        ] else ...[
          _sectionLabel('Business Type', icon: Icons.category_outlined),
          _dropdown(
            label: 'Buyer Category',
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
              label: 'Finish Registration', color: const Color(0xFF2E7D32)),
        ],
      ],
    );
  }

  Widget _aadhaarSection() {
    final accentColor =
        _role == 'buyer' ? const Color(0xFF2E7D32) : const Color(0xFF1565C0);

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
          TextField(
            controller: _aadhaarCtrl,
            keyboardType: TextInputType.number,
            maxLength: 12,
            enabled: !_aadhaarVerified,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Aadhaar Number',
              prefixIcon: const Icon(Icons.credit_card_rounded),
              counterText: '',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _aadhaarVerified ? null : _showPhotoSourceSheet,
            child: Container(
              width: double.infinity,
              height: _aadhaarPhoto == null ? 120 : 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: _aadhaarPhoto == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded,
                            size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text('Upload Aadhaar Photo',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb
                          ? const Center(child: Text("Photo Uploaded ✓"))
                          : Image.file(File(_aadhaarPhoto!.path),
                              fit: BoxFit.cover),
                    ),
            ),
          ),
          if (_aadhaarVerifying) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text('Verifying with secure ML...',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
          if (_aadhaarVerified) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text('Identity Verified Successfully',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

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
          onChanged: (v) {
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
          const SizedBox(height: 8),
          Text('📍 $region',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.teal)),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                locLoading ? null : () => _detectLocation(isBuyer: isBuyer),
            icon: locLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location_rounded),
            label:
                Text(locLoading ? 'Detecting...' : 'Use Current GPS Location'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: gpsCtrl,
          decoration: InputDecoration(
            labelText: 'Full Address',
            prefixIcon: const Icon(Icons.location_on_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _loginChip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Text('Verified Contact: ${widget.phone}',
          style: TextStyle(
              color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
    );
  }

  Widget _sectionLabel(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: const Color(0xFF1565C0)),
            const SizedBox(width: 8),
          ],
          Text(text,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboard = TextInputType.text,
      List<TextInputFormatter>? inputFormatters}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _dropdown(
      {required String label,
      required IconData icon,
      required String? value,
      required List<String> items,
      required void Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    );
  }

  Widget _lockedPlaceholder(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
      child: Text(message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600)),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _submitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

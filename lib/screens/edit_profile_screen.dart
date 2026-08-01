import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _saving = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController(); // For farmers
  final _companyCtrl = TextEditingController(); // For buyers
  final _pincodeCtrl = TextEditingController();
  final _gpsCtrl = TextEditingController();

  String? _region;
  bool _locLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      final doc = await _firestore.collection('profiles').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _profile = doc.data();
          _nameCtrl.text = _profile?['full_name'] ?? '';
          _phoneCtrl.text = _profile?['phone'] ?? '';
          _farmNameCtrl.text = _profile?['farm_name'] ?? '';
          _companyCtrl.text = _profile?['company_name'] ?? '';
          _pincodeCtrl.text = _profile?['pincode'] ?? '';
          _gpsCtrl.text = _profile?['gps_address'] ?? '';
          _region = _profile?['region'];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _farmNameCtrl.dispose();
    _companyCtrl.dispose();
    _pincodeCtrl.dispose();
    _gpsCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookupPincode(String pin) async {
    if (pin.length != 6) return;
    try {
      final res = await http.get(Uri.parse('https://api.postalpincode.in/pincode/$pin'));
      final data = jsonDecode(res.body) as List;
      if (data.isNotEmpty && data[0]['Status'] == 'Success') {
        final po = (data[0]['PostOffice'] as List)[0];
        final region = '${po['District']}, ${po['State']}, India';
        setState(() => _region = region);
      } else {
        _showSnack('PIN code lookup failed.');
      }
    } catch (e) {
      _showSnack('Could not resolve PIN code: $e');
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _locLoading = true);
    try {
      bool svcEnabled = await Geolocator.isLocationServiceEnabled();
      if (!svcEnabled) {
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
      if (perm == LocationPermission.deniedForever) {
        _showSnack('Location permission permanently denied.');
        await Geolocator.openAppSettings();
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15));

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
          } else if (state != null) {
            detectedRegion = '$state, India';
          }
        }
      } catch (_) {
        address = '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      }

      setState(() {
        _gpsCtrl.text = address;
        if (detectedRegion != null) _region = detectedRegion;
      });
    } catch (e) {
      _showSnack('Could not get location: $e');
    } finally {
      if (mounted) setState(() => _locLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _saveProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      final role = _profile?['role'] ?? 'farmer';
      final payload = {
        'full_name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'pincode': _pincodeCtrl.text.trim(),
        'gps_address': _gpsCtrl.text.trim(),
        'region': _region,
      };

      if (role == 'farmer') {
        payload['farm_name'] = _farmNameCtrl.text.trim();
      } else {
        payload['company_name'] = _companyCtrl.text.trim();
      }

      await _firestore.collection('profiles').doc(uid).update(payload);
      _showSnack('Profile updated successfully!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnack('Error updating profile: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF1F8F2),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20))),
      );
    }

    final role = _profile?['role'] ?? 'farmer';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F2),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _nameCtrl,
              label: 'Full Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            if (role == 'farmer') ...[
              _buildTextField(
                controller: _farmNameCtrl,
                label: 'Farm Name',
                icon: Icons.agriculture_outlined,
              ),
              const SizedBox(height: 16),
            ] else ...[
              _buildTextField(
                controller: _companyCtrl,
                label: 'Company / Business Name',
                icon: Icons.business_outlined,
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Location Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _pincodeCtrl,
              label: 'PIN Code',
              icon: Icons.pin_drop_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              onChanged: (val) {
                if (val.length == 6) _lookupPincode(val);
              },
            ),
            if (_region != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Row(
                  children: [
                    const Icon(Icons.location_city, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _region!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _gpsCtrl,
              label: 'GPS Address',
              icon: Icons.gps_fixed,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _locLoading ? null : _detectLocation,
                icon: _locLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location, size: 16),
                label: Text(_locLoading ? 'Detecting...' : 'Auto-detect Location'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1565C0),
                ),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
      ),
    );
  }
}

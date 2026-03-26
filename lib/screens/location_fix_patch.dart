// ─────────────────────────────────────────────────────────────────────────────
//  PATCH: farmer_info_screen.dart — _detectLocation fix
//
//  The bug: Geolocator.getCurrentPosition() fails silently when location
//  services are off OR permission is permanently denied, and setState is never
//  called for _locLoading = false in the error path because the early-return
//  misses the finally block.
//
//  Fix: wrap the whole body in try/catch/finally so _locLoading ALWAYS resets,
//  and add a mounted-guard before every setState.
//
//  REPLACE the existing _detectLocation method in farmer_info_screen.dart
//  with the version below.
// ─────────────────────────────────────────────────────────────────────────────

  Future<void> _detectLocation({bool isBuyer = false}) async {
    if (!mounted) return;
    setState(() {
      if (isBuyer) _buyerLocLoading = true;
      else _locLoading = true;
    });

    try {
      // 1. Check if location services are enabled
      final svcEnabled = await Geolocator.isLocationServiceEnabled();
      if (!svcEnabled) {
        _showSnack(
            'Location services are disabled. Please turn on GPS in Settings.');
        return;
      }

      // 2. Request / check permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (perm == LocationPermission.deniedForever) {
          _showSnack(
              'Location permission is permanently denied. Enable it in App Settings.');
          await Geolocator.openAppSettings();
        } else {
          _showSnack('Location permission denied.');
        }
        return;
      }

      // 3. Get position (15-second timeout)
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // 4. Reverse-geocode with Nominatim
      String address =
          '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      String? detectedRegion;

      try {
        final res = await http.get(
          Uri.parse(
            'https://nominatim.openstreetmap.org/reverse'
            '?format=json'
            '&lat=${pos.latitude}'
            '&lon=${pos.longitude}'
            '&zoom=18&addressdetails=1',
          ),
          headers: {'User-Agent': 'BlueFarm/1.0 (bluefarm@app)'},
        ).timeout(const Duration(seconds: 10));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          address = data['display_name'] as String? ?? address;

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
        }
      } catch (_) {
        // Nominatim failed — keep raw coordinates as address
      }

      if (!mounted) return;
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
      if (mounted) _showSnack('Could not get location: $e');
    } finally {
      // ALWAYS reset loading — this was missing in the original code
      if (mounted) {
        setState(() {
          if (isBuyer) _buyerLocLoading = false;
          else _locLoading = false;
        });
      }
    }
  }

// ─────────────────────────────────────────────────────────────────────────────
//  Also ensure these imports are at the top of farmer_info_screen.dart:
//
//  import 'dart:async';       // for TimeoutException (http.get timeout)
//  import 'dart:convert';     // jsonDecode
//  import 'package:http/http.dart' as http;
//  import 'package:geolocator/geolocator.dart';
// ─────────────────────────────────────────────────────────────────────────────
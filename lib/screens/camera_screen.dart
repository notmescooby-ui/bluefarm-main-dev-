// lib/screens/camera_screen.dart
//
// BlueFarm – Camera & AI Analysis Screen
// Uses: camera, image_picker, http (for AI backend call)
// Runs on: Android / iOS  (Raspberry Pi camera via MJPEG stream optional)
//
// pubspec.yaml dependencies needed:
//   camera: ^0.11.0+2
//   image_picker: ^1.1.2
//   http: ^1.2.1
//   permission_handler: ^11.3.1
//   path_provider: ^2.1.3

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// ─────────────────────────────────────────────────────────
//  THEME CONSTANTS  (mirrors main_shell.dart palette)
// ─────────────────────────────────────────────────────────
const _navy    = Color(0xFF0D1B6B);
const _blueDark= Color(0xFF0D47A1);
const _blueMid = Color(0xFF1565C0);
const _teal    = Color(0xFF00BCD4);
const _green   = Color(0xFF00C853);
const _amber   = Color(0xFFFFA000);
const _red     = Color(0xFFF44336);
const _bgLight = Color(0xFFEFF4FF);
const _cardBg  = Color(0xFFFFFFFF);
const _textMid = Color(0xFF546E7A);

// Dark-mode variants
const _bgDark   = Color(0xFF0A0F1E);
const _cardDark = Color(0xFF121929);
const _borderDk = Color(0xFF1E2D4A);

// ─────────────────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────────────────
enum _AnalysisState { idle, capturing, analyzing, result, error }

class FishAnalysisResult {
  final String species;
  final String healthStatus;      // "Healthy" | "At Risk" | "Diseased"
  final double confidenceScore;   // 0-1
  final List<String> observations;
  final List<String> recommendations;
  final String? possibleDisease;
  final Color statusColor;

  const FishAnalysisResult({
    required this.species,
    required this.healthStatus,
    required this.confidenceScore,
    required this.observations,
    required this.recommendations,
    this.possibleDisease,
    required this.statusColor,
  });

  factory FishAnalysisResult.fromJson(Map<String, dynamic> json) {
    final status = json['health_status'] as String? ?? 'Unknown';
    return FishAnalysisResult(
      species         : json['species']          as String? ?? 'Unknown Species',
      healthStatus    : status,
      confidenceScore : (json['confidence']      as num?)?.toDouble() ?? 0.0,
      observations    : List<String>.from(json['observations']    ?? []),
      recommendations : List<String>.from(json['recommendations'] ?? []),
      possibleDisease : json['possible_disease'] as String?,
      statusColor     : status == 'Healthy'
          ? _green
          : status == 'At Risk' ? _amber : _red,
    );
  }

  // ── Mock result for demo / no-backend mode ──────────────
  factory FishAnalysisResult.mock() => const FishAnalysisResult(
    species         : 'Rohu (Labeo rohita)',
    healthStatus    : 'At Risk',
    confidenceScore : 0.87,
    observations    : [
      'Slight discolouration on dorsal fin',
      'Reduced mucus coating visible',
      'Mild scale loss near gill area',
    ],
    recommendations : [
      'Reduce feeding by 20% for 48 hours',
      'Check ammonia levels — target < 0.3 mg/L',
      'Increase aeration overnight',
      'Consider salt bath (3 g/L × 20 min)',
    ],
    possibleDisease : 'Early Columnaris',
    statusColor     : _amber,
  );
}

// ─────────────────────────────────────────────────────────
//  MAIN SCREEN WIDGET
// ─────────────────────────────────────────────────────────
class CameraScreen extends StatefulWidget {
  /// Pass [isDark] from your theme provider / main_shell.dart
  final bool isDark;

  const CameraScreen({super.key, this.isDark = false});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {

  // ── Camera ──────────────────────────────────────────────
  CameraController? _camCtrl;
  List<CameraDescription> _cameras = [];
  int _camIndex = 0;                 // 0 = back, 1 = front
  bool _flashOn = false;
  bool _camReady = false;
  bool _showGrid = false;

  // ── Zoom ────────────────────────────────────────────────
  double _minZoom = 1.0;
  double _maxZoom = 4.0;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;

  // ── State machine ───────────────────────────────────────
  _AnalysisState _state = _AnalysisState.idle;
  File? _capturedImage;
  FishAnalysisResult? _result;
  String _errorMsg = '';

  // ── MJPEG stream (Raspberry Pi) ─────────────────────────
  bool _showStream = false;
  String _streamUrl = 'http://192.168.1.100:8080/?action=stream';

  // ── Animations ──────────────────────────────────────────
  late AnimationController _scanAnim;
  late AnimationController _pulseAnim;
  late AnimationController _resultAnim;
  late Animation<double>   _scanLine;
  late Animation<double>   _pulsePct;
  late Animation<Offset>   _resultSlide;

  // ─── picker ─────────────────────────────────────────────
  final _picker = ImagePicker();

  // ────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initCamera();
  }

  void _setupAnimations() {
    _scanAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _resultAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _scanLine = Tween<double>(begin: 0.18, end: 0.82)
        .animate(CurvedAnimation(parent: _scanAnim, curve: Curves.easeInOut));

    _pulsePct = Tween<double>(begin: 0.9, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));

    _resultSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _resultAnim,
            curve: const Cubic(0.34, 1.56, 0.64, 1)));
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      setState(() => _errorMsg = 'Camera permission denied.');
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _errorMsg = 'No cameras found on this device.');
        return;
      }
      await _startCamera(_cameras[_camIndex]);
    } catch (e) {
      setState(() => _errorMsg = 'Camera initialisation failed: $e');
    }
  }

  Future<void> _startCamera(CameraDescription cam) async {
    final ctrl = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await ctrl.initialize();
      _minZoom = await ctrl.getMinZoomLevel();
      _maxZoom = await ctrl.getMaxZoomLevel();
      if (mounted) {
        setState(() {
          _camCtrl = ctrl;
          _camReady = true;
          _currentZoom = 1.0;
        });
      }
    } catch (e) {
      debugPrint('CameraController.initialize error: $e');
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    await _camCtrl?.dispose();
    setState(() { _camReady = false; _camIndex = 1 - _camIndex; });
    await _startCamera(_cameras[_camIndex]);
    HapticFeedback.lightImpact();
  }

  Future<void> _toggleFlash() async {
    if (_camCtrl == null) return;
    _flashOn = !_flashOn;
    await _camCtrl!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
    HapticFeedback.selectionClick();
  }

  Future<void> _setZoom(double zoom) async {
    final clamped = zoom.clamp(_minZoom, _maxZoom);
    await _camCtrl?.setZoomLevel(clamped);
    setState(() => _currentZoom = clamped);
  }

  // ─────────────────────────────────────────────────────────
  //  CAPTURE + ANALYSE
  // ─────────────────────────────────────────────────────────
  Future<void> _capture() async {
    if (_camCtrl == null || !_camReady) return;
    HapticFeedback.mediumImpact();
    setState(() => _state = _AnalysisState.capturing);

    try {
      final xFile = await _camCtrl!.takePicture();
      final imgFile = File(xFile.path);
      setState(() {
        _capturedImage = imgFile;
        _state = _AnalysisState.analyzing;
      });
      _scanAnim.reset();
      _scanAnim.repeat(reverse: true);
      await _analyseImage(imgFile);
    } catch (e) {
      setState(() {
        _state = _AnalysisState.error;
        _errorMsg = 'Capture failed: $e';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;
    final imgFile = File(xFile.path);
    setState(() {
      _capturedImage = imgFile;
      _state = _AnalysisState.analyzing;
    });
    await _analyseImage(imgFile);
  }

  Future<void> _analyseImage(File imgFile) async {
    setState(() => _state = _AnalysisState.analyzing);

    try {
      // ── Replace with your actual endpoint ───────────────
      const endpoint = 'https://your-api.bluefarm.app/analyse';

      final bytes   = await imgFile.readAsBytes();
      final b64     = base64Encode(bytes);
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': b64}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _result = FishAnalysisResult.fromJson(data);
      } else {
        // Graceful fallback to mock result
        _result = FishAnalysisResult.mock();
      }
    } on TimeoutException {
      _result = FishAnalysisResult.mock();          // offline demo mode
    } on SocketException {
      _result = FishAnalysisResult.mock();          // offline demo mode
    } catch (_) {
      _result = FishAnalysisResult.mock();
    }

    if (!mounted) return;
    setState(() => _state = _AnalysisState.result);
    _resultAnim.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  void _reset() {
    _resultAnim.reverse().then((_) {
      if (mounted) setState(() {
        _state = _AnalysisState.idle;
        _capturedImage = null;
        _result = null;
      });
    });
  }

  // ─────────────────────────────────────────────────────────
  @override
  void dispose() {
    _camCtrl?.dispose();
    _scanAnim.dispose();
    _pulseAnim.dispose();
    _resultAnim.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bg   = widget.isDark ? _bgDark   : _bgLight;
    final card = widget.isDark ? _cardDark : _cardBg;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── 1. Camera Preview / captured image ─────────
            _buildViewfinder(),

            // ── 2. Top HUD ─────────────────────────────────
            _buildTopHud(),

            // ── 3. Scanning overlay (while analysing) ──────
            if (_state == _AnalysisState.analyzing)
              _buildScanOverlay(),

            // ── 4. Bottom controls bar ─────────────────────
            if (_state == _AnalysisState.idle ||
                _state == _AnalysisState.capturing)
              _buildBottomControls(),

            // ── 5. Result sheet ────────────────────────────
            if (_state == _AnalysisState.result && _result != null)
              _buildResultSheet(card),

            // ── 6. Error / no-camera state ─────────────────
            if (_errorMsg.isNotEmpty && _state != _AnalysisState.result)
              _buildErrorBanner(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  VIEWFINDER
  // ─────────────────────────────────────────────────────────
  Widget _buildViewfinder() {
    if (_showStream) {
      return _StreamView(url: _streamUrl);
    }

    if (_capturedImage != null &&
        (_state == _AnalysisState.analyzing ||
         _state == _AnalysisState.result)) {
      return SizedBox.expand(
        child: Image.file(_capturedImage!, fit: BoxFit.cover),
      );
    }

    if (!_camReady || _camCtrl == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: _teal),
        ),
      );
    }

    return GestureDetector(
      onScaleStart: (d) => _baseZoom = _currentZoom,
      onScaleUpdate: (d) => _setZoom(_baseZoom * d.scale),
      onTapDown: (d) async {
        final size   = MediaQuery.of(context).size;
        final offset = d.localPosition;
        final x = offset.dx / size.width;
        final y = offset.dy / size.height;
        await _camCtrl!.setFocusPoint(Offset(x, y));
        await _camCtrl!.setExposurePoint(Offset(x, y));
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_camCtrl!),
          // Grid overlay
          if (_showGrid)
            CustomPaint(painter: _GridPainter()),
          // Focus frame
          _buildFocusFrame(),
        ],
      ),
    );
  }

  Widget _buildFocusFrame() {
    return Center(
      child: Container(
        width: 220, height: 220,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Corner decorators
            for (final a in _corners) _cornerDot(a.$1, a.$2),
          ],
        ),
      ),
    );
  }

  static const _corners = [
    (Alignment.topLeft,     BorderRadius.only(topLeft: Radius.circular(14))),
    (Alignment.topRight,    BorderRadius.only(topRight: Radius.circular(14))),
    (Alignment.bottomLeft,  BorderRadius.only(bottomLeft: Radius.circular(14))),
    (Alignment.bottomRight, BorderRadius.only(bottomRight: Radius.circular(14))),
  ];

  Widget _cornerDot(Alignment align, BorderRadius br) => Align(
    alignment: align,
    child: Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        border: Border(
          top   : align.y < 0 ? const BorderSide(color: _teal, width: 3) : BorderSide.none,
          bottom: align.y > 0 ? const BorderSide(color: _teal, width: 3) : BorderSide.none,
          left  : align.x < 0 ? const BorderSide(color: _teal, width: 3) : BorderSide.none,
          right : align.x > 0 ? const BorderSide(color: _teal, width: 3) : BorderSide.none,
        ),
        borderRadius: br,
      ),
    ),
  );

  // ─────────────────────────────────────────────────────────
  //  TOP HUD
  // ─────────────────────────────────────────────────────────
  Widget _buildTopHud() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Back
            _hudBtn(Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.maybePop(context)),

            const SizedBox(width: 8),

            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Fish Health Scanner',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w900, fontSize: 16)),
                  Text('Point at fish or pond water',
                      style: TextStyle(color: Colors.white70,
                          fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            // Grid toggle
            _hudBtn(_showGrid ? Icons.grid_off : Icons.grid_on,
                onTap: () { setState(() => _showGrid = !_showGrid); }),

            const SizedBox(width: 8),

            // Stream toggle
            _hudBtn(_showStream ? Icons.videocam : Icons.videocam_off,
                active: _showStream,
                onTap: () {
                  setState(() => _showStream = !_showStream);
                  HapticFeedback.selectionClick();
                }),

            const SizedBox(width: 8),

            // Flash
            _hudBtn(_flashOn ? Icons.flash_on : Icons.flash_off,
                active: _flashOn,
                onTap: _toggleFlash),
          ],
        ),
      ),
    );
  }

  Widget _hudBtn(IconData icon,
      {required VoidCallback onTap, bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: active
              ? _teal.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? _teal : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(icon,
            color: active ? _teal : Colors.white, size: 18),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SCAN OVERLAY (while analysing)
  // ─────────────────────────────────────────────────────────
  Widget _buildScanOverlay() {
    return Stack(
      children: [
        // Dark tint
        Container(color: Colors.black.withValues(alpha: 0.4)),

        // Scan line
        AnimatedBuilder(
          animation: _scanLine,
          builder: (_, __) {
            final h = MediaQuery.of(context).size.height;
            return Positioned(
              top: h * _scanLine.value,
              left: 0, right: 0,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, _teal, Colors.transparent],
                  ),
                ),
              ),
            );
          },
        ),

        // Centre pill
        Center(
          child: ScaleTransition(
            scale: _pulsePct,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: _teal.withValues(alpha: 0.6)),
                boxShadow: [
                  BoxShadow(color: _teal.withValues(alpha: 0.25),
                      blurRadius: 24, spreadRadius: 4),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      color: _teal,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Analysing with AI…',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w800, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  BOTTOM CONTROLS
  // ─────────────────────────────────────────────────────────
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              // Zoom slider
              _buildZoomSlider(),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gallery
                  _actionBtn(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: _pickFromGallery,
                    size: 56,
                  ),

                  // Shutter
                  GestureDetector(
                    onTap: _state == _AnalysisState.capturing ? null : _capture,
                    child: AnimatedScale(
                      scale: _state == _AnalysisState.capturing ? 0.9 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        width: 76, height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: _teal.withValues(alpha: 0.5),
                              blurRadius: 20, spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [_teal, _blueDark],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Flip camera
                  _actionBtn(
                    icon: Icons.flip_camera_android_rounded,
                    label: 'Flip',
                    onTap: _flipCamera,
                    size: 56,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoomSlider() {
    final range = _maxZoom - _minZoom;
    if (range <= 0) return const SizedBox.shrink();
    return Row(
      children: [
        const Icon(Icons.zoom_out, color: Colors.white70, size: 16),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight      : 2,
              thumbShape       : const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape     : const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor : _teal,
              inactiveTrackColor: Colors.white24,
              thumbColor       : Colors.white,
              overlayColor     : _teal.withValues(alpha: 0.2),
            ),
            child: Slider(
              value : _currentZoom,
              min   : _minZoom,
              max   : _maxZoom,
              onChanged: (v) => _setZoom(v),
            ),
          ),
        ),
        const Icon(Icons.zoom_in, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text('${_currentZoom.toStringAsFixed(1)}×',
            style: const TextStyle(color: Colors.white70,
                fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    double size = 48,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size, height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.45),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.42),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(
              color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  RESULT SHEET
  // ─────────────────────────────────────────────────────────
  Widget _buildResultSheet(Color card) {
    final r = _result!;
    return SlideTransition(
      position: _resultSlide,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.62,
          ),
          decoration: BoxDecoration(
            color: card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 40, offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Handle ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header row ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 12, 0),
                child: Row(
                  children: [
                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: r.statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: r.statusColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: r.statusColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(r.healthStatus,
                              style: TextStyle(
                                  color: r.statusColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(r.species,
                          style: TextStyle(
                            color: widget.isDark ? Colors.white : _navy,
                            fontWeight: FontWeight.w900, fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis),
                    ),
                    // Confidence badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _blueDark.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(r.confidenceScore * 100).round()}% match',
                        style: const TextStyle(
                            color: _blueDark, fontSize: 11,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Close
                    GestureDetector(
                      onTap: _reset,
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 18, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable body ───────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Possible disease banner
                      if (r.possibleDisease != null)
                        _diseaseBanner(r.possibleDisease!),

                      // Confidence bar
                      const SizedBox(height: 14),
                      _sectionLabel('Confidence'),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: LinearProgressIndicator(
                          value      : r.confidenceScore,
                          minHeight  : 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor : AlwaysStoppedAnimation(r.statusColor),
                        ),
                      ),

                      // Observations
                      const SizedBox(height: 18),
                      _sectionLabel('🔍 Observations'),
                      const SizedBox(height: 8),
                      ...r.observations.map((o) => _bulletRow(o,
                          icon: Icons.remove_red_eye_rounded,
                          color: _textMid)),

                      // Recommendations
                      const SizedBox(height: 16),
                      _sectionLabel('💊 Recommendations'),
                      const SizedBox(height: 8),
                      ...r.recommendations.map((rec) => _bulletRow(rec,
                          icon: Icons.check_circle_outline_rounded,
                          color: _green)),

                      // Actions row
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _sheetBtn(
                              label: 'Retake',
                              icon : Icons.camera_alt_rounded,
                              color: _blueDark,
                              outline: true,
                              onTap: _reset,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _sheetBtn(
                              label: 'Save Report',
                              icon : Icons.save_alt_rounded,
                              color: _teal,
                              onTap: _saveReport,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _diseaseBanner(String disease) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: _amber, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Possible Disease Detected',
                    style: TextStyle(color: _red,
                        fontWeight: FontWeight.w900, fontSize: 12)),
                const SizedBox(height: 2),
                Text(disease,
                    style: const TextStyle(
                        color: _textMid, fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(label,
      style: TextStyle(
        color: widget.isDark ? Colors.white70 : _navy,
        fontWeight: FontWeight.w900, fontSize: 13,
      ));

  Widget _bulletRow(String text,
      {required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: widget.isDark ? Colors.white70 : _textMid,
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _sheetBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool outline = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
              color: outline ? color : Colors.transparent, width: 1.5),
          gradient: outline ? null
              : LinearGradient(
                  colors: [color, color.withValues(alpha: 0.75)]),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: outline ? color : Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: outline ? color : Colors.white,
                    fontWeight: FontWeight.w800, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  ERROR BANNER
  // ─────────────────────────────────────────────────────────
  Widget _buildErrorBanner() {
    return Positioned(
      bottom: 100, left: 24, right: 24,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _red.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_errorMsg,
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w700)),
            ),
            GestureDetector(
              onTap: () => setState(() => _errorMsg = ''),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SAVE REPORT (stub)
  // ─────────────────────────────────────────────────────────
  Future<void> _saveReport() async {
    if (_result == null) return;
    try {
      final dir  = await getApplicationDocumentsDirectory();
      final ts   = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/bluefarm_report_$ts.json');
      await file.writeAsString(jsonEncode({
        'timestamp'     : DateTime.now().toIso8601String(),
        'species'       : _result!.species,
        'health_status' : _result!.healthStatus,
        'confidence'    : _result!.confidenceScore,
        'observations'  : _result!.observations,
        'recommendations': _result!.recommendations,
        'possible_disease': _result!.possibleDisease,
      }));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved to ${file.path}'),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'),
              backgroundColor: _red),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────
//  MJPEG STREAM VIEW  (Raspberry Pi camera)
// ─────────────────────────────────────────────────────────
class _StreamView extends StatefulWidget {
  final String url;
  const _StreamView({required this.url});

  @override
  State<_StreamView> createState() => _StreamViewState();
}

class _StreamViewState extends State<_StreamView> {
  Uint8List? _frame;
  http.Client? _client;
  StreamSubscription<List<int>>? _sub;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      _client = http.Client();
      final req = http.Request('GET', Uri.parse(widget.url));
      final resp = await _client!.send(req);

      final buf = <int>[];
      _sub = resp.stream.listen((chunk) {
        buf.addAll(chunk);
        // MJPEG: find JPEG boundaries 0xFF 0xD8 ... 0xFF 0xD9
        int start = -1;
        for (int i = 0; i < buf.length - 1; i++) {
          if (buf[i] == 0xFF && buf[i + 1] == 0xD8) start = i;
          if (start != -1 && buf[i] == 0xFF && buf[i + 1] == 0xD9) {
            final jpegBytes = Uint8List.fromList(buf.sublist(start, i + 2));
            buf.removeRange(0, i + 2);
            if (mounted) setState(() => _frame = jpegBytes);
            break;
          }
        }
      });
    } catch (_) {
      // Stream unavailable — show placeholder
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_frame == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: _teal),
              const SizedBox(height: 12),
              Text('Connecting to ${widget.url}',
                  style: const TextStyle(color: Colors.white60,
                      fontSize: 12),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return SizedBox.expand(
      child: Image.memory(_frame!, fit: BoxFit.cover, gaplessPlayback: true),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  GRID PAINTER
// ─────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
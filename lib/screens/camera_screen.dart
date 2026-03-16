import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isFront = false;
  bool _initialized = false;
  XFile? _captured;
  String _error = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _initCamera(front: false);
  }

  Future<void> _initCamera({required bool front}) async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) setState(() => _error = 'Camera permission denied');
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) setState(() => _error = 'No cameras found');
        return;
      }

      CameraDescription cam = _cameras.firstWhere(
        (c) => c.lensDirection == (front ? CameraLensDirection.front : CameraLensDirection.back),
        orElse: () => _cameras.first,
      );

      _controller?.dispose();
      _controller = CameraController(cam, ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _initialized = true;
          _error = '';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to initialize camera');
    }
  }

  Future<void> _flip() async {
    _isFront = !_isFront;
    setState(() {
      _initialized = false;
      _captured = null;
    });
    await _initCamera(front: _isFront);
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      XFile photo = await _controller!.takePicture();
      setState(() => _captured = photo);
    } catch (e) {
      // Ignore
    }
  }

  void _stop() {
    _controller?.dispose();
    if (mounted) {
      setState(() {
        _initialized = false;
        _captured = null;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 90, left: 14, right: 14, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Farm Camera', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_isFront ? 'Front Camera' : 'Back Camera', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),

          // Viewport
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05)),
                  if (_captured != null)
                     Transform(
                      alignment: Alignment.center,
                      transform: _isFront ? Matrix4.rotationY(math.pi) : Matrix4.identity(),
                      child: Image.network(_captured!.path, fit: BoxFit.cover),
                    )
                  else if (_initialized && _controller != null)
                    Transform(
                      alignment: Alignment.center,
                      transform: _isFront ? Matrix4.rotationY(math.pi) : Matrix4.identity(),
                      child: CameraPreview(_controller!),
                    )
                  else if (_error.isNotEmpty)
                    Center(child: Text(_error, style: const TextStyle(color: AppTheme.lightDanger)))
                  else
                    const Center(child: CircularProgressIndicator(color: AppTheme.lightAccent)),

                  // Overlays
                  if (_initialized && _captured == null) ...[
                    Positioned(
                      top: 11,
                      left: 11,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFDC2626).withOpacity(0.82), borderRadius: BorderRadius.circular(7)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) => Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: Colors.white.withOpacity(_pulseController.value), shape: BoxShape.circle),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 11,
                      right: 11,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.48), borderRadius: BorderRadius.circular(7)),
                        child: Text(_isFront ? 'Front' : 'Back', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _flip,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  side: BorderSide(color: AppTheme.lightAccent.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flip_camera_android_outlined, size: 15, color: AppTheme.lightAccent),
                    const SizedBox(width: 6),
                    Text(_isFront ? 'Switch to Back' : 'Switch to Front', style: const TextStyle(fontSize: 12, color: AppTheme.lightAccent)),
                  ],
                ),
              ),

              GestureDetector(
                onTap: _initialized ? _capture : () => _initCamera(front: _isFront),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _initialized ? Theme.of(context).cardColor : null,
                    gradient: _initialized ? null : const LinearGradient(colors: [AppTheme.lightPrimaryMid, AppTheme.lightAccent]),
                    border: _initialized ? Border.all(color: AppTheme.lightAccent, width: 3.5) : null,
                    boxShadow: _initialized
                        ? [BoxShadow(color: AppTheme.lightAccent.withOpacity(0.4), blurRadius: 18 * _pulseController.value)]
                        : [BoxShadow(color: AppTheme.lightAccent.withOpacity(0.4), blurRadius: 18)],
                  ),
                  child: Center(
                    child: Icon(
                      _initialized ? Icons.circle_outlined : Icons.camera_alt_outlined,
                      color: _initialized ? AppTheme.lightAccent : Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),

              if (_initialized)
                OutlinedButton(
                  onPressed: _stop,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                  child: const Text('Stop Camera', style: TextStyle(fontSize: 12)),
                )
              else
                ElevatedButton(
                  onPressed: () => _initCamera(front: _isFront),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  ),
                  child: const Text('Start Camera', style: TextStyle(fontSize: 12, color: Colors.white)),
                ),
            ],
          ),

          if (_captured != null) ...[
            const SizedBox(height: 13),
            Container(
              decoration: AppTheme.cardDecoration(context),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Captured Photo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Transform(
                        alignment: Alignment.center,
                        transform: _isFront ? Matrix4.rotationY(math.pi) : Matrix4.identity(),
                        child: Image.network(_captured!.path, height: 175, width: double.infinity, fit: BoxFit.cover),
                    )
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                           onPressed: () {}, // Save logic in real app
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.lightAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                          ),
                          child: const Text('Save to Gallery', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _captured = null),
                          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                          child: const Text('Discard', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Text('Camera Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _tipCard('Clean Lens', 'Wipe the camera lens before capturing fish for disease analysis.'),
          _tipCard('Reduce Glare', 'Avoid pointing directly at sun reflections on the pond surface.'),
          _tipCard('Steady Hands', 'Hold steady for 2 seconds to allow auto-focus to adjust turbid water.'),
        ],
      ),
    );
  }

  Widget _tipCard(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}

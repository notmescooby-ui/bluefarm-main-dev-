import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String _reply = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _askClaude() async {
    if (_controller.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _reply = '';
    });

    final provider = context.read<AppProvider>();
    final response = await AIService().askClaude(_controller.text, provider.latestReading);

    if (mounted) {
      setState(() {
        _loading = false;
        _reply = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 90, left: 14, right: 14, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.lightPrimaryMid, AppTheme.lightAccent]),
              borderRadius: BorderRadius.circular(19),
            ),
            padding: const EdgeInsets.all(17),
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  right: -10,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 10),
                    const Text('BlueFarm AI Assistant', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 3),
                    Text('Powered by Claude - Ask anything about your farm', style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Input Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _askClaude(),
                  decoration: InputDecoration(
                    hintText: 'Ask about your farm...',
                    hintStyle: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: AppTheme.lightAccent.withOpacity(0.1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppTheme.lightAccent)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _loading ? null : _askClaude,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.lightPrimaryMid, AppTheme.lightAccent]),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reply
          if (_reply.isNotEmpty)
            Container(
              decoration: AppTheme.cardDecoration(context).copyWith(
                color: isDark ? AppTheme.lightAccent.withOpacity(0.05) : AppTheme.lightAccent.withOpacity(0.05),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(color: AppTheme.lightAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.psychology_outlined, color: AppTheme.lightAccent, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectableText(
                      _reply,
                      style: const TextStyle(height: 1.5, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

          const SizedBox(height: 14),

          // Quick Questions
          Text('QUICK QUESTIONS', style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              'Best feed schedule?',
              'Fish disease check?',
              'Water change needed?',
              'Optimal stocking?',
              'Feeding time now?',
            ]
                .map((q) => OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        _controller.text = q;
                        _askClaude();
                      },
                      child: Text(q, style: const TextStyle(fontSize: 11, color: AppTheme.lightAccent)),
                    ))
                .toList(),
          ),

          const SizedBox(height: 18),
          const Text('Smart Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const RecCard(index: 0, title: 'pH is low', badge: 'Critical'),
          const SizedBox(height: 10),
          const RecCard(index: 1, title: 'Turbidity is slightly high', badge: 'Warning'),
          const SizedBox(height: 10),
          const RecCard(index: 2, title: 'Temperature is perfect', badge: 'Good'),
        ],
      ),
    );
  }
}

class RecCard extends StatefulWidget {
  final int index;
  final String title;
  final String badge;

  const RecCard({super.key, required this.index, required this.title, required this.badge});

  @override
  State<RecCard> createState() => _RecCardState();
}

class _RecCardState extends State<RecCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.index == 0;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        decoration: AppTheme.cardDecoration(context).copyWith(
          color: isDark ? AppTheme.lightAccent.withOpacity(0.04) : AppTheme.lightAccent.withOpacity(0.02),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: AppTheme.lightAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.info_outline, color: AppTheme.lightAccent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(widget.badge, style: TextStyle(fontSize: 10, color: widget.badge == 'Good' ? AppTheme.lightSuccess : AppTheme.lightDanger)),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.chevron_right : Icons.keyboard_arrow_down, color: Theme.of(context).textTheme.bodySmall?.color, size: 18),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(left: 61, right: 13, bottom: 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Possible Causes', style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w700)),
                           const SizedBox(height: 4),
                           const Text('• Rainfall runoff\n• Excess fish waste', style: TextStyle(fontSize: 12, height: 1.5)),
                           const SizedBox(height: 8),
                           Text('What to Do', style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w700)),
                           const SizedBox(height: 4),
                           const Text('✓ Add agricultural limestone\n✓ Monitor for next 24 hours', style: TextStyle(fontSize: 12, height: 1.5, color: AppTheme.lightSuccess)),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

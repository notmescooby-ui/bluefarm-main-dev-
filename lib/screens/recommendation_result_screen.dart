import 'package:flutter/material.dart';

class RecommendationResultScreen extends StatelessWidget {
  final Map<String, String> recommendation;
  final String parameter;

  const RecommendationResultScreen({
    super.key,
    required this.recommendation,
    required this.parameter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF0F1A2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Action Plan",
          style: TextStyle(
            color: Color(0xFF0F1A2A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFDC2626),
                    title: "Detected Problem",
                    content: recommendation['problem'] ?? 'N/A',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFE5E5E0), height: 1),
                  ),
                  _buildSection(
                    icon: Icons.search,
                    iconColor: const Color(0xFFD97706),
                    title: "Possible Cause",
                    content: recommendation['cause'] ?? 'N/A',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFE5E5E0), height: 1),
                  ),
                  _buildSection(
                    icon: Icons.bolt,
                    iconColor: const Color(0xFF1565C0),
                    title: "Immediate Actions",
                    content: recommendation['immediate_actions'] ?? 'N/A',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFE5E5E0), height: 1),
                  ),
                  _buildSection(
                    icon: Icons.shield_outlined,
                    iconColor: const Color(0xFF059669),
                    title: "Preventive Measures",
                    content: recommendation['preventive_measures'] ?? 'N/A',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFE5E5E0), height: 1),
                  ),
                  _buildSection(
                    icon: Icons.analytics_outlined,
                    iconColor: const Color(0xFF6B7280),
                    title: "Monitoring Advice",
                    content: recommendation['monitoring_advice'] ?? 'N/A',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E5E0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Return to Dashboard",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F1A2A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    // Format bullet points properly if they exist in the raw text
    final formattedContent = content.split('\\n').map((line) => line.trim()).where((line) => line.isNotEmpty).join('\\n\\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F1A2A),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          formattedContent,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}

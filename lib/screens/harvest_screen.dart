import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  HARVEST SCREEN  (Farmer → posts listing → Buyer sees it)
// ═══════════════════════════════════════════════════════════════════════════════
class HarvestScreen extends StatefulWidget {
  const HarvestScreen({super.key});

  @override
  State<HarvestScreen> createState() => _HarvestScreenState();
}

class _HarvestScreenState extends State<HarvestScreen> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _myListings = [];
  bool _loading = true;
  int _tab = 0; // 0 = My Listings, 1 = Add New

  @override
  void initState() { super.initState(); _loadListings(); }

  Future<void> _loadListings() async {
    setState(() => _loading = true);
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      final data = await _client
          .from('listings')
          .select()
          .eq('farmer_id', userId)
          .order('created_at', ascending: false);
      setState(() => _myListings = List<Map<String, dynamic>>.from(data));
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // ── Tab bar ──────────────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        child: Row(children: [
          Expanded(child: _tabBtn('My Listings', 0)),
          const SizedBox(width: 10),
          Expanded(child: _tabBtn('Add Harvest', 1)),
        ]),
      ),
      const SizedBox(height: 2),

      Expanded(child: _tab == 0 ? _buildListings() : _buildAddForm()),
    ]);
  }

  Widget _tabBtn(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? AppTheme.lightAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: active ? AppTheme.lightAccent : AppTheme.lightAccent.withOpacity(0.3)),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13,
                color: active ? Colors.white : AppTheme.lightAccent)),
      ),
    );
  }

  // ── My Listings ───────────────────────────────────────────────────────────
  Widget _buildListings() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_myListings.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text('No harvest listings yet',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        const SizedBox(height: 8),
        Text('Tap "Add Harvest" to post your first listing',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
      ]));
    }
    return RefreshIndicator(
      onRefresh: _loadListings,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
        itemCount: _myListings.length,
        itemBuilder: (_, i) => _listingCard(_myListings[i]),
      ),
    );
  }

  Widget _listingCard(Map<String, dynamic> l) {
    final status = l['status'] as String? ?? 'active';
    final statusColor = status == 'active'
        ? AppTheme.lightSuccess
        : status == 'sold'
            ? AppTheme.lightWarning
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: AppTheme.lightAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.set_meal_rounded, color: AppTheme.lightAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l['species'] ?? '—',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text('Posted ${_timeAgo(l['created_at'])}',
                style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall!.color!)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Text(status.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _infoChip(Icons.scale_outlined, '${l['quantity_kg'] ?? 0} kg'),
          const SizedBox(width: 8),
          _infoChip(Icons.currency_rupee_outlined, '${l['price_per_kg'] ?? 0}/kg'),
          const SizedBox(width: 8),
          _infoChip(Icons.monitor_weight_outlined, '${l['avg_weight_g'] ?? '—'} g avg'),
        ]),
        if ((l['notes'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 10),
          Text(l['notes'],
              style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall!.color!)),
        ],
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => _markSold(l['id']),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightWarning,
                side: BorderSide(color: AppTheme.lightWarning.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Mark Sold', style: TextStyle(fontSize: 12)),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton(
            onPressed: () => _deleteListing(l['id']),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightDanger,
                side: BorderSide(color: AppTheme.lightDanger.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Delete', style: TextStyle(fontSize: 12)),
          )),
        ]),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppTheme.lightAccent),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Future<void> _markSold(String id) async {
    await _client.from('listings').update({'status': 'sold'}).eq('id', id);
    _loadListings();
  }

  Future<void> _deleteListing(String id) async {
    await _client.from('listings').delete().eq('id', id);
    _loadListings();
  }

  String _timeAgo(dynamic ts) {
    if (ts == null) return '';
    final dt = DateTime.tryParse(ts.toString());
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // ── Add Harvest Form ──────────────────────────────────────────────────────
  Widget _buildAddForm() => _AddHarvestForm(onSubmitted: () {
    setState(() => _tab = 0);
    _loadListings();
  });
}

// ── Add Harvest Form Widget ────────────────────────────────────────────────────
class _AddHarvestForm extends StatefulWidget {
  final VoidCallback onSubmitted;
  const _AddHarvestForm({required this.onSubmitted});

  @override
  State<_AddHarvestForm> createState() => _AddHarvestFormState();
}

class _AddHarvestFormState extends State<_AddHarvestForm> {
  final _client = Supabase.instance.client;
  final _speciesCtrl  = TextEditingController();
  final _qtyCtrl      = TextEditingController();
  final _weightCtrl   = TextEditingController();
  final _priceCtrl    = TextEditingController();
  final _notesCtrl    = TextEditingController();
  bool _submitting    = false;

  static const _species = [
    'Rohu', 'Catla', 'Mrigal', 'Tilapia', 'Pangasius',
    'Shrimp – Vannamei', 'Shrimp – Tiger', 'Catfish', 'Common Carp', 'Other',
  ];
  String? _selectedSpecies;

  @override
  void dispose() {
    _speciesCtrl.dispose(); _qtyCtrl.dispose();
    _weightCtrl.dispose(); _priceCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _selectedSpecies != null &&
      _qtyCtrl.text.trim().isNotEmpty &&
      _priceCtrl.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) { _showSnack('Fill in species, quantity, and price'); return; }
    setState(() => _submitting = true);
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      await _client.from('listings').insert({
        'farmer_id':    userId,
        'species':      _selectedSpecies,
        'quantity_kg':  double.tryParse(_qtyCtrl.text.trim()) ?? 0,
        'avg_weight_g': double.tryParse(_weightCtrl.text.trim()),
        'price_per_kg': double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'notes':        _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        'status':       'active',
      });
      _showSnack('Listing posted! Buyers can now see it.', success: true);
      widget.onSubmitted();
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? AppTheme.lightSuccess : AppTheme.lightDanger,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.lightAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.lightAccent.withOpacity(0.3))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline_rounded, color: AppTheme.lightAccent, size: 20),
            const SizedBox(width: 10),
            const Expanded(child: Text(
              'Once you post a harvest listing, buyers on the marketplace can see it and send you purchase requests.',
              style: TextStyle(fontSize: 13, color: AppTheme.lightAccent, height: 1.4),
            )),
          ]),
        ),
        const SizedBox(height: 20),

        _label('Fish Species *'),
        DropdownButtonFormField<String>(
          value: _selectedSpecies,
          decoration: _dec('Select species', Icons.set_meal_rounded),
          items: _species.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _selectedSpecies = v),
        ),
        const SizedBox(height: 14),

        _label('Quantity Available (kg) *'),
        TextField(
          controller: _qtyCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          decoration: _dec('e.g. 150', Icons.scale_outlined),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),

        _label('Average Weight per Fish (grams)'),
        TextField(
          controller: _weightCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          decoration: _dec('e.g. 800', Icons.monitor_weight_outlined),
        ),
        const SizedBox(height: 14),

        _label('Price per kg (₹) *'),
        TextField(
          controller: _priceCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          decoration: _dec('e.g. 120', Icons.currency_rupee_outlined),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),

        _label('Notes (optional)'),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: _dec('e.g. Fresh harvest, available for pickup', Icons.notes_rounded),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_canSubmit && !_submitting) ? _submit : null,
            icon: _submitting
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.upload_rounded),
            label: Text(_submitting ? 'Posting…' : 'Post Harvest Listing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightAccent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
  );

  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Theme.of(context).cardColor,
  );
}
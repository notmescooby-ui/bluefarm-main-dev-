import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../localization/app_translations.dart';

class HarvestScreen extends StatefulWidget {
  const HarvestScreen({super.key});
  @override
  State<HarvestScreen> createState() => _HarvestScreenState();
}

class _HarvestScreenState extends State<HarvestScreen> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _listings = [];
  bool _loading = true;
  bool _showForm = false;
  Map<String, dynamic>? _editingListing; // non-null when editing

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return;
      final data = await _client
          .from('listings')
          .select()
          .eq('farmer_id', uid)
          .order('created_at', ascending: false);
      setState(() => _listings = List<Map<String, dynamic>>.from(data));
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _openForm({Map<String, dynamic>? editing}) {
    setState(() { _showForm = true; _editingListing = editing; });
  }

  void _closeForm() {
    setState(() { _showForm = false; _editingListing = null; });
    _load();
  }

  Future<void> _markSold(String id) async {
    await _client.from('listings').update({'status': 'sold'}).eq('id', id);
    _load();
  }

  Future<void> _delete(String id) async {
    await _client.from('listings').delete().eq('id', id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // ── Top bar ────────────────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
        child: Row(children: [
          if (_showForm)
            GestureDetector(
              onTap: _closeForm,
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Color(0xFF1565C0)),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _showForm
                  ? (_editingListing != null ? 'Edit Listing' : 'Add Harvest')
                  : AppTranslations.get('harvest_market'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
          if (!_showForm)
            GestureDetector(
              onTap: () => _openForm(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.lightAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 5),
                  Text('Add Harvest',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700, fontSize: 13)),
                ]),
              ),
            ),
        ]),
      ),

      Expanded(
        child: _showForm
            ? _HarvestForm(
                editing: _editingListing,
                onDone: _closeForm,
              )
            : _buildListings(),
      ),
    ]);
  }

  Widget _buildListings() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_listings.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade300),
        const SizedBox(height: 14),
        Text(AppTranslations.get('no_listings'),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
        const SizedBox(height: 6),
        Text(AppTranslations.get('no_listings_sub'),
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
      ]));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
        itemCount: _listings.length,
        itemBuilder: (_, i) => _listingCard(_listings[i]),
      ),
    );
  }

  Widget _listingCard(Map<String, dynamic> l) {
    final status = l['status'] as String? ?? 'active';
    final statusColor = status == 'active' ? AppTheme.lightSuccess
        : status == 'sold' ? AppTheme.lightWarning : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: AppTheme.lightAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.set_meal_rounded,
                color: AppTheme.lightAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l['species'] ?? '—',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            if ((l['pond_number'] as String?)?.isNotEmpty == true)
              Text('Pond ${l['pond_number']}',
                  style: TextStyle(fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall!.color!)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Text(status.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                    color: statusColor)),
          ),
        ]),
        const SizedBox(height: 12),

        // Stats row
        Wrap(spacing: 8, runSpacing: 6, children: [
          if (l['quantity_kg'] != null)
            _chip(Icons.scale_outlined, '${l['quantity_kg']} kg'),
          if (l['fish_count'] != null)
            _chip(Icons.numbers_rounded, '${l['fish_count']} fish'),
          if (l['avg_weight_g'] != null)
            _chip(Icons.monitor_weight_outlined, '${l['avg_weight_g']}g avg'),
          if (l['price_per_fish'] != null)
            _chip(Icons.currency_rupee, '₹${l['price_per_fish']}/fish'),
          if (l['price_per_kg'] != null)
            _chip(Icons.currency_rupee, '₹${l['price_per_kg']}/kg'),
          if (l['bulk_price'] != null)
            _chip(Icons.local_offer_outlined, 'Bulk ₹${l['bulk_price']}'),
        ]),

        if ((l['notes'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(l['notes'], style: TextStyle(fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall!.color!)),
        ],

        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _openForm(editing: l),
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: const Text('Edit', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightAccent,
                side: BorderSide(color: AppTheme.lightAccent.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton(
            onPressed: () => _markSold(l['id']),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightWarning,
                side: BorderSide(color: AppTheme.lightWarning.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text(AppTranslations.get('mark_sold'),
                style: const TextStyle(fontSize: 12)),
          )),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _delete(l['id']),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightDanger,
                side: BorderSide(color: AppTheme.lightDanger.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Icon(Icons.delete_outline_rounded, size: 16),
          ),
        ]),
      ]),
    );
  }

  Widget _chip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppTheme.lightAccent),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
//  HARVEST FORM — Add or Edit
// ═══════════════════════════════════════════════════════════════════════════════
class _HarvestForm extends StatefulWidget {
  final Map<String, dynamic>? editing;
  final VoidCallback onDone;
  const _HarvestForm({this.editing, required this.onDone});
  @override
  State<_HarvestForm> createState() => _HarvestFormState();
}

class _HarvestFormState extends State<_HarvestForm> {
  final _client = Supabase.instance.client;

  final _pondCtrl       = TextEditingController();
  final _qtyCtrl        = TextEditingController();
  final _countCtrl      = TextEditingController();
  final _weightCtrl     = TextEditingController();
  final _priceKgCtrl    = TextEditingController();
  final _priceFishCtrl  = TextEditingController();
  final _bulkPriceCtrl  = TextEditingController();
  final _notesCtrl      = TextEditingController();

  String? _species;
  bool _submitting = false;

  static const _speciesList = [
    'Rohu', 'Catla', 'Mrigal', 'Tilapia', 'Pangasius',
    'Shrimp – Vannamei', 'Shrimp – Tiger', 'Catfish (Magur)',
    'Common Carp', 'Silver Carp', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      _species = e['species'] as String?;
      _pondCtrl.text       = e['pond_number']?.toString() ?? '';
      _qtyCtrl.text        = e['quantity_kg']?.toString() ?? '';
      _countCtrl.text      = e['fish_count']?.toString() ?? '';
      _weightCtrl.text     = e['avg_weight_g']?.toString() ?? '';
      _priceKgCtrl.text    = e['price_per_kg']?.toString() ?? '';
      _priceFishCtrl.text  = e['price_per_fish']?.toString() ?? '';
      _bulkPriceCtrl.text  = e['bulk_price']?.toString() ?? '';
      _notesCtrl.text      = e['notes']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    for (final c in [_pondCtrl, _qtyCtrl, _countCtrl, _weightCtrl,
        _priceKgCtrl, _priceFishCtrl, _bulkPriceCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canSubmit => _species != null && _qtyCtrl.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) { _snack('Fill in species and quantity'); return; }
    setState(() => _submitting = true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return;

      final data = {
        'farmer_id':    uid,
        'species':      _species,
        'pond_number':  _pondCtrl.text.trim().isNotEmpty ? _pondCtrl.text.trim() : null,
        'quantity_kg':  double.tryParse(_qtyCtrl.text.trim()),
        'fish_count':   int.tryParse(_countCtrl.text.trim()),
        'avg_weight_g': double.tryParse(_weightCtrl.text.trim()),
        'price_per_kg': double.tryParse(_priceKgCtrl.text.trim()),
        'price_per_fish': double.tryParse(_priceFishCtrl.text.trim()),
        'bulk_price':   double.tryParse(_bulkPriceCtrl.text.trim()),
        'notes':        _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        'status':       'active',
      };

      if (widget.editing != null) {
        await _client.from('listings').update(data)
            .eq('id', widget.editing!['id']);
      } else {
        await _client.from('listings').insert(data);
      }

      _snack(widget.editing != null ? 'Listing updated!' : 'Harvest posted!',
          success: true);
      widget.onDone();
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? AppTheme.lightSuccess : AppTheme.lightDanger,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
              color: AppTheme.lightAccent.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightAccent.withOpacity(0.25))),
          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline_rounded, color: AppTheme.lightAccent, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text(
              'Your listing will be visible to buyers on the marketplace once submitted.',
              style: TextStyle(fontSize: 12, color: AppTheme.lightAccent, height: 1.4),
            )),
          ]),
        ),

        _label('Fish Species *'),
        DropdownButtonFormField<String>(
          value: _species,
          decoration: _dec('Select species', Icons.set_meal_rounded),
          items: _speciesList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _species = v),
        ),
        const SizedBox(height: 14),

        _label('Pond Number / Name'),
        TextField(controller: _pondCtrl,
            decoration: _dec('e.g. Pond 1 or North Pond', Icons.water_rounded)),
        const SizedBox(height: 14),

        _label('Total Quantity Available (kg) *'),
        TextField(controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            onChanged: (_) => setState(() {}),
            decoration: _dec('e.g. 200', Icons.scale_outlined)),
        const SizedBox(height: 14),

        _label('Number of Fish'),
        TextField(controller: _countCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _dec('e.g. 150', Icons.numbers_rounded)),
        const SizedBox(height: 14),

        _label('Average Weight per Fish (grams)'),
        TextField(controller: _weightCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            decoration: _dec('e.g. 800', Icons.monitor_weight_outlined)),
        const SizedBox(height: 14),

        _label('Price per kg (₹)'),
        TextField(controller: _priceKgCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            decoration: _dec('e.g. 120', Icons.currency_rupee_outlined)),
        const SizedBox(height: 14),

        _label('Price per Fish (₹)'),
        TextField(controller: _priceFishCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            decoration: _dec('e.g. 90', Icons.currency_rupee_outlined)),
        const SizedBox(height: 14),

        _label('Bulk / Lot Price (₹) — for full batch'),
        TextField(controller: _bulkPriceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            decoration: _dec('e.g. 18000', Icons.local_offer_outlined)),
        const SizedBox(height: 14),

        _label('Notes (optional)'),
        TextField(controller: _notesCtrl, maxLines: 3,
            decoration: _dec('e.g. Live fish, available for pickup from 6 AM',
                Icons.notes_rounded)),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_canSubmit && !_submitting) ? _submit : null,
            icon: _submitting
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.upload_rounded),
            label: Text(_submitting
                ? AppTranslations.get('posting')
                : widget.editing != null
                    ? 'Update Listing'
                    : AppTranslations.get('post_listing')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightAccent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(
        fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0D2B4E))),
  );

  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Theme.of(context).cardColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}
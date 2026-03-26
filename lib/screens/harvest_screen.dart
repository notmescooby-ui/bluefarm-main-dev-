import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../localization/app_translations.dart';
import '../theme/app_theme.dart';

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
  Map<String, dynamic>? _editingListing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final data = await _client
          .from('listings')
          .select()
          .eq('farmer_id', uid)
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _listings = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _openForm({Map<String, dynamic>? editing}) {
    setState(() {
      _showForm = true;
      _editingListing = editing;
    });
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editingListing = null;
    });
    _load();
  }

  Future<void> _markSold(dynamic id) async {
    try {
      final updated = await _client
          .from('listings')
          .update({'status': 'sold'})
          .eq('id', id)
          .select();

      if (!mounted) return;
      if (updated.isEmpty) {
        _snack('Could not mark this listing as sold.');
        return;
      }

      setState(() {
        _listings = _listings
            .map((listing) => listing['id'] == id
                ? {...listing, 'status': 'sold'}
                : listing)
            .toList();
      });
      _snack('Listing marked as sold.', success: true);
    } catch (error) {
      if (!mounted) return;
      _snack('Error: $error');
    }
  }

  Future<void> _delete(dynamic id) async {
    final previousListings = List<Map<String, dynamic>>.from(_listings);

    setState(() {
      _listings = _listings.where((listing) => listing['id'] != id).toList();
    });

    try {
      await _client.from('listings').delete().eq('id', id);

      if (!mounted) return;
      _snack('Listing deleted.', success: true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _listings = previousListings);
      _snack('Error: $error');
    }
  }

  void _snack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppTheme.lightSuccess : AppTheme.lightDanger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _showForm ? _buildFormView() : _buildListingsView(),
    );
  }

  Widget _buildListingsView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 100, 14, 0),
      child: Column(
        key: const ValueKey('harvest-list'),
        children: [
          _HarvestHeader(
            title: 'Harvest Market',
            subtitle: 'Manage your fish listings and post new harvest stock.',
            actionLabel: 'Add Harvest',
            onAction: () => _openForm(),
          ),
          const SizedBox(height: 14),
          Expanded(child: _buildListings()),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 100, 14, 0),
      child: Column(
        key: const ValueKey('harvest-form'),
        children: [
          _HarvestHeader(
            title: _editingListing != null ? 'Edit Listing' : 'Add Harvest',
            subtitle: 'Fill in the harvest details that buyers will see.',
            actionLabel: 'Back',
            isPrimaryAction: false,
            onAction: _closeForm,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _HarvestForm(
              editing: _editingListing,
              onDone: _closeForm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListings() {
    if (_loading) {
      return Container(
        decoration: AppTheme.cardDecoration(context),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_listings.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
            decoration: AppTheme.cardDecoration(context),
            child: Column(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.lightPrimaryMid, AppTheme.lightAccent],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'No harvest listings yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Post your first harvest to show fish quantity, size, and pricing to buyers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openForm(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create First Listing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
        itemCount: _listings.length,
        itemBuilder: (_, index) => _listingCard(_listings[index]),
      ),
    );
  }

  Widget _listingCard(Map<String, dynamic> listing) {
    final status = (listing['status'] as String? ?? 'active').toLowerCase();
    final statusColor = status == 'active'
        ? AppTheme.lightSuccess
        : status == 'sold'
            ? AppTheme.lightWarning
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.lightAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.set_meal_rounded,
                  color: AppTheme.lightAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (listing['species'] as String?)?.trim().isNotEmpty == true
                          ? listing['species']
                          : 'Unknown species',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ready for buyers',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (listing['quantity_kg'] != null)
                _MetricChip(
                  icon: Icons.scale_outlined,
                  label: '${listing['quantity_kg']} kg',
                ),
              if (listing['price_per_kg'] != null)
                _MetricChip(
                  icon: Icons.currency_rupee,
                  label: 'Rs ${listing['price_per_kg']}/kg',
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openForm(editing: listing),
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.lightAccent,
                    side: BorderSide(
                      color: AppTheme.lightAccent.withOpacity(0.4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: status == 'sold' ? null : () => _markSold(listing['id']),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.lightWarning,
                    side: BorderSide(
                      color: AppTheme.lightWarning.withOpacity(0.45),
                    ),
                    disabledForegroundColor: AppTheme.lightWarning.withOpacity(0.45),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    status == 'sold' ? 'Sold' : AppTranslations.get('mark_sold'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _delete(listing['id']),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.lightDanger,
                  side: BorderSide(
                    color: AppTheme.lightDanger.withOpacity(0.45),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.delete_outline_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HarvestHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final bool isPrimaryAction;

  const _HarvestHeader({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    this.isPrimaryAction = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          isPrimaryAction
              ? ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(actionLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(actionLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.lightAccent,
                    side: BorderSide(
                      color: AppTheme.lightAccent.withOpacity(0.4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.lightAccent),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HarvestForm extends StatefulWidget {
  final Map<String, dynamic>? editing;
  final VoidCallback onDone;

  const _HarvestForm({
    this.editing,
    required this.onDone,
  });

  @override
  State<_HarvestForm> createState() => _HarvestFormState();
}

class _HarvestFormState extends State<_HarvestForm> {
  final _client = Supabase.instance.client;

  final _pondCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _countCtrl = TextEditingController();
  final _priceKgCtrl = TextEditingController();
  final _priceFishCtrl = TextEditingController();
  final _bulkPriceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _species;
  bool _submitting = false;

  static const _speciesList = [
    'Rohu',
    'Catla',
    'Mrigal',
    'Tilapia',
    'Pangasius',
    'Shrimp - Vannamei',
    'Shrimp - Tiger',
    'Catfish (Magur)',
    'Common Carp',
    'Silver Carp',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    if (editing != null) {
      _species = editing['species'] as String?;
      _pondCtrl.text = editing['pond_number']?.toString() ?? '';
      _qtyCtrl.text = editing['quantity_kg']?.toString() ?? '';
      _countCtrl.text = editing['fish_count']?.toString() ?? '';
      _priceKgCtrl.text = editing['price_per_kg']?.toString() ?? '';
      _priceFishCtrl.text = editing['price_per_fish']?.toString() ?? '';
      _bulkPriceCtrl.text = editing['bulk_price']?.toString() ?? '';
      _notesCtrl.text = editing['notes']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _pondCtrl,
      _qtyCtrl,
      _countCtrl,
      _priceKgCtrl,
      _priceFishCtrl,
      _bulkPriceCtrl,
      _notesCtrl,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _canSubmit => _species != null && _qtyCtrl.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) {
      _snack('Please fill in species and total weight');
      return;
    }

    setState(() => _submitting = true);

    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) {
        _snack('User not signed in');
        return;
      }

      final data = <String, dynamic>{
        'farmer_id': uid,
        'species': _species,
        'quantity_kg': double.tryParse(_qtyCtrl.text.trim()),
        'price_per_kg': double.tryParse(_priceKgCtrl.text.trim()),
        'status': 'active',
      };

      if (widget.editing != null) {
        await _client.from('listings').update(data).eq('id', widget.editing!['id']);
      } else {
        await _client.from('listings').insert(data);
      }

      _snack(
        widget.editing != null ? 'Listing updated!' : 'Harvest posted!',
        success: true,
      );
      widget.onDone();
    } catch (error) {
      _snack('Error: $error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppTheme.lightSuccess : AppTheme.lightDanger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final averageWeight = _calculatedAverageWeight();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? 12 : 0),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(0, 0, 0, bottomInset + 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.lightAccent.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.lightAccent.withOpacity(0.2)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.lightAccent, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your listing will appear to buyers after you submit it.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: AppTheme.lightAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: AppTheme.cardDecoration(context),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Fish Species *'),
                  DropdownButtonFormField<String>(
                    value: _species,
                    decoration: _dec('Select species', Icons.set_meal_rounded),
                    items: _speciesList
                        .map((species) => DropdownMenuItem(
                              value: species,
                              child: Text(species),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _species = value),
                  ),
                  const SizedBox(height: 14),
                  _label('Pond Number / Name'),
                  TextField(
                    controller: _pondCtrl,
                    decoration: _dec('e.g. Pond 1 or North Pond', Icons.water_rounded),
                  ),
                  const SizedBox(height: 14),
                  _label('Total Weight Harvested (kg) *'),
                  TextField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (_) => setState(() {}),
                    decoration: _dec('e.g. 200', Icons.scale_outlined),
                  ),
                  const SizedBox(height: 14),
                  _label('Number of Fish Harvested'),
                  TextField(
                    controller: _countCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    decoration: _dec('e.g. 150', Icons.numbers_rounded),
                  ),
                  if (averageWeight != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.lightPrimaryMid.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.lightAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.monitor_weight_outlined,
                              color: AppTheme.lightAccent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Estimated average per fish',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${averageWeight.toStringAsFixed(1)} g',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Calculated from total weight and fish count.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1.4,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _label('Price per kg (Rs)'),
                  TextField(
                    controller: _priceKgCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: _dec('e.g. 120', Icons.currency_rupee_outlined),
                  ),
                  const SizedBox(height: 14),
                  _label('Price per Fish (Rs)'),
                  TextField(
                    controller: _priceFishCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: _dec('e.g. 90', Icons.currency_rupee_outlined),
                  ),
                  const SizedBox(height: 14),
                  _label('Bulk / Lot Price (Rs)'),
                  TextField(
                    controller: _bulkPriceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: _dec('e.g. 18000', Icons.local_offer_outlined),
                  ),
                  const SizedBox(height: 14),
                  _label('Notes'),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    decoration: _dec(
                      'e.g. Live fish, available for early morning pickup',
                      Icons.notes_rounded,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_canSubmit && !_submitting) ? _submit : null,
                      icon: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload_rounded),
                      label: Text(
                        _submitting
                            ? AppTranslations.get('posting')
                            : widget.editing != null
                                ? 'Update Listing'
                                : AppTranslations.get('post_listing'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightAccent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Color(0xFF0D2B4E),
        ),
      ),
    );
  }

  InputDecoration _dec(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.lightPrimaryMid.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.lightAccent, width: 1.4),
      ),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  double? _calculatedAverageWeight() {
    final quantityKg = double.tryParse(_qtyCtrl.text.trim());
    final fishCount = int.tryParse(_countCtrl.text.trim());
    if (quantityKg == null || fishCount == null || fishCount <= 0) {
      return null;
    }
    return (quantityKg * 1000) / fishCount;
  }
}

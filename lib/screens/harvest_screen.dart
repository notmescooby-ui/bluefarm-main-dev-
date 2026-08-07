import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_theme.dart';

class HarvestScreen extends StatefulWidget {
  const HarvestScreen({super.key});

  @override
  State<HarvestScreen> createState() => _HarvestScreenState();
}

class _HarvestScreenState extends State<HarvestScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _listings = [];
  bool _loading = true;
  bool _showForm = false;
  Map<String, dynamic>? _editingListing;
  dynamic _openMenuId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final querySnapshot = await _firestore
          .collection('listings')
          .where('farmer_id', isEqualTo: uid)
          .get();

      if (!mounted) return;
      setState(() {
        var docs = querySnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
        docs.sort((a, b) {
          final t1 = a['created_at'] as Timestamp?;
          final t2 = b['created_at'] as Timestamp?;
          if (t1 == null && t2 == null) return 0;
          if (t1 == null) return 1;
          if (t2 == null) return -1;
          return t2.compareTo(t1); // descending
        });
        _listings = docs;
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
      _openMenuId = null;
    });
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editingListing = null;
    });
    _load();
  }

  Future<void> _toggleSold(dynamic id, String currentStatus) async {
    final newStatus = currentStatus == 'sold' ? 'active' : 'sold';
    try {
      await _firestore
          .collection('listings')
          .doc(id as String)
          .update({'status': newStatus});

      if (!mounted) return;

      setState(() {
        _listings = _listings
            .map((listing) => listing['id'] == id
                ? {...listing, 'status': newStatus}
                : listing)
            .toList();
        _openMenuId = null;
      });
      _snack(newStatus == 'sold' ? 'Marked as sold.' : 'Marked as listed.', success: true);
    } catch (error) {
      if (!mounted) return;
      _snack('Error: $error');
    }
  }

  Future<void> _delete(dynamic id) async {
    final previousListings = List<Map<String, dynamic>>.from(_listings);

    setState(() {
      _listings = _listings.where((listing) => listing['id'] != id).toList();
      _openMenuId = null;
    });

    try {
      await _firestore.collection('listings').doc(id as String).delete();

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
        backgroundColor: success ? AppColors.success : AppColors.error,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F5),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20, right: 20, bottom: 20,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Harvest & Market",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F1A2A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "YOUR LISTINGS GO LIVE TO BUYERS INSTANTLY",
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openForm(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F1A2A),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildListings(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F5),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20, right: 20, bottom: 20,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editingListing != null ? 'Edit Listing' : 'Add Harvest',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F1A2A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "FILL IN THE HARVEST DETAILS THAT BUYERS WILL SEE",
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _closeForm,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF0F1A2A).withValues(alpha: 0.2)),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.arrow_back, color: Color(0xFF0F1A2A), size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _HarvestForm(
                editing: _editingListing,
                onDone: _closeForm,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildListings() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_listings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0F1A2A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.set_meal, size: 36, color: Color(0xFF0F1A2A)),
            ),
            const SizedBox(height: 20),
            const Text(
              "No listings yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F1A2A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Post your first catch to appear in the buyer marketplace right away.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF6B7280).withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _openForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F1A2A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("+ Add your first harvest", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _listings.map((listing) => _listingCard(listing)).toList(),
    );
  }

  Widget _listingCard(Map<String, dynamic> listing) {
    final status = (listing['status'] as String? ?? 'active').toLowerCase();
    final isSold = status == 'sold';
    final id = listing['id'];

    final pond = listing['pond_number']?.toString() ?? 'N/A';
    final species = listing['species']?.toString() ?? 'Unknown';
    final count = listing['fish_count']?.toString() ?? '-';
    
    // Calculate average weight
    final qtyStr = listing['quantity_kg']?.toString() ?? '0';
    final qty = double.tryParse(qtyStr) ?? 0;
    final fishCountNum = int.tryParse(count) ?? 0;
    final avgWeight = (fishCountNum > 0) ? (qty / fishCountNum).toStringAsFixed(2) : '-';
    
    final priceStr = listing['price_per_kg']?.toString() ?? '0';
    
    final isOpen = _openMenuId == id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E5E0),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(
              color: isSold ? Colors.grey.withValues(alpha: 0.4) : const Color(0xFF059669),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pond.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          species,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F1A2A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$count fish · avg $avgWeight kg",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _openMenuId = isOpen ? null : id;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.more_vert, size: 20, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total $qtyStr kg",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "₹$priceStr",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F1A2A),
                              ),
                            ),
                            const Text(
                              "/kg",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSold ? Colors.grey.shade200 : const Color(0xFF059669).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        isSold ? "Sold" : "Ready for buyers",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSold ? Colors.grey.shade600 : const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isOpen) ...[
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (isSold) {
                              _toggleSold(id, status);
                            } else {
                              _openForm(editing: listing);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isSold ? "Mark listed" : "Edit",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F1A2A),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!isSold) {
                              _toggleSold(id, status);
                            } else {
                              _delete(id);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSold ? Colors.transparent : const Color(0xFFE2E8F0),
                              border: isSold ? Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)) : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isSold ? "Delete" : "Mark sold",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSold ? const Color(0xFFDC2626) : const Color(0xFF0F1A2A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
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
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        _snack('User not signed in');
        return;
      }

      final profileDoc = await _firestore.collection('profiles').doc(uid).get();
      final pData = profileDoc.data() ?? {};
      
      final data = <String, dynamic>{
        'farmer_id': uid,
        'species': _species,
        'quantity_kg': double.tryParse(_qtyCtrl.text.trim()),
        'price_per_kg': double.tryParse(_priceKgCtrl.text.trim()),
        'fish_count': int.tryParse(_countCtrl.text.trim()),
        'pond_number': _pondCtrl.text.trim(),
        'status': 'active',
        'created_at': FieldValue.serverTimestamp(),
        'profiles': {
          'full_name': pData['full_name'] ?? 'Farmer',
          'farm_name': pData['farm_name'] ?? 'Farm',
          'region': pData['region'] ?? '',
        }
      };

      if (widget.editing != null) {
        await _firestore.collection('listings').doc(widget.editing!['id'] as String).update(data);
      } else {
        await _firestore.collection('listings').add(data);
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
        backgroundColor: success ? const Color(0xFF059669) : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E5E0),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Fish Species *'),
          DropdownButtonFormField<String>(
            initialValue: _species,
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
                    ? 'Posting...'
                    : widget.editing != null
                        ? 'Update Listing'
                        : 'Post Listing',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F1A2A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
          color: Color(0xFF0F1A2A),
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
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F1A2A), width: 1.4),
      ),
      filled: true,
      fillColor: const Color(0xFFF9F9F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  BUYER SHELL — Quick-commerce fish marketplace (Instamart/BigBasket style)
//  Tabs: Market (species-grouped) | Orders | Profile
//  Global floating cart bar accessible from anywhere
// ─────────────────────────────────────────────────────────────────────────────

const _kGreen      = Color(0xFF2E7D32);
const _kGreenLight = Color(0xFF4CAF50);
const _kGreenDark  = Color(0xFF1B5E20);
const _kAmber      = Color(0xFFF59E0B);
const _kBg         = Color(0xFFF1F8F2);
const _kCard       = Colors.white;
const _kText       = Color(0xFF1A2E1A);
const _kMuted      = Color(0xFF6B7C6B);

const _kPrimarySpecies = ['Catla', 'Rohu', 'Mrigal'];

const _kSpeciesEmoji = {
  'Catla': '🐟', 'Rohu': '🐠', 'Mrigal': '🐡',
  'Tilapia (Nile)': '🐡', 'Pangasius': '🐟', 'Shrimp – Vannamei': '🦐',
  'Shrimp – Tiger': '🦐', 'Catfish (Magur)': '🐠',
};

const _kSpeciesColor = {
  'Catla': Color(0xFF1565C0), 'Rohu': Color(0xFF2E7D32), 'Mrigal': Color(0xFF6A1B9A),
};

const _kSpeciesBg = {
  'Catla': Color(0xFFE3F0FF), 'Rohu': Color(0xFFE8F5E9), 'Mrigal': Color(0xFFF3E5F5),
};

// ─────────────────────────────────────────────────────────────────────────────
//  CART ITEM MODEL
// ─────────────────────────────────────────────────────────────────────────────
class CartItem {
  final String listingId, farmerId, species, farmName, farmerName, location;
  final double pricePerKg, availableKg;
  double quantityKg;

  CartItem({
    required this.listingId, required this.farmerId, required this.species,
    required this.farmName, required this.farmerName, required this.location,
    required this.pricePerKg, required this.availableKg, required this.quantityKg,
  });

  double get subtotal => pricePerKg * quantityKg;
}

// ─────────────────────────────────────────────────────────────────────────────
//  BUYER SHELL
// ─────────────────────────────────────────────────────────────────────────────
class BuyerShell extends StatefulWidget {
  const BuyerShell({super.key});

  @override
  State<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends State<BuyerShell> {
  int _tab = 0;
  final List<CartItem> _cart = [];

  void _addToCart(CartItem item) {
    setState(() {
      final idx = _cart.indexWhere((c) => c.listingId == item.listingId);
      if (idx != -1) {
        _cart[idx].quantityKg =
            (_cart[idx].quantityKg + item.quantityKg).clamp(0, item.availableKg);
      } else {
        _cart.add(item);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${item.species} from ${item.farmName} added'),
      backgroundColor: _kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
          label: 'View Cart', textColor: Colors.white, onPressed: _openCart),
    ));
  }

  void _removeFromCart(String id) =>
      setState(() => _cart.removeWhere((c) => c.listingId == id));

  void _updateQty(String id, double qty) {
    setState(() {
      final idx = _cart.indexWhere((c) => c.listingId == id);
      if (idx != -1) {
        if (qty <= 0) _cart.removeAt(idx);
        else _cart[idx].quantityKg = qty;
      }
    });
  }

  void _clearCart() => setState(() => _cart.clear());

  double get _total => _cart.fold(0, (s, i) => s + i.subtotal);
  int    get _count => _cart.length;

  void _openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CartSheet(
        cart: _cart, total: _total,
        onRemove: _removeFromCart, onUpdateQty: _updateQty,
        onClear: _clearCart, onCheckout: _openCheckout,
      ),
    );
  }

  void _openCheckout() {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckoutSheet(
        cart: _cart, total: _total,
        onConfirmed: () { _clearCart(); setState(() => _tab = 1); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(children: [
        IndexedStack(index: _tab, children: [
          _MarketTab(onAddToCart: _addToCart, cart: _cart),
          const _OrdersTab(),
          const _ProfileTab(),
        ]),

        // Floating cart bar
        if (_count > 0)
          Positioned(
            bottom: 80, left: 20, right: 20,
            child: GestureDetector(
              onTap: _openCart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_kGreenDark, _kGreen],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: _kGreen.withOpacity(0.4),
                      blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('$_count item${_count > 1 ? 's' : ''}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('View Cart',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  Text('₹${_total.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                ]),
              ),
            ),
          ),
      ]),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: _kGreen.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront, color: _kGreen),
              label: 'Market'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long, color: _kGreen),
              label: 'Orders'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: _kGreen),
              label: 'Profile'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MARKET TAB
// ─────────────────────────────────────────────────────────────────────────────
class _MarketTab extends StatefulWidget {
  final void Function(CartItem) onAddToCart;
  final List<CartItem> cart;
  const _MarketTab({required this.onAddToCart, required this.cart});

  @override
  State<_MarketTab> createState() => _MarketTabState();
}

class _MarketTabState extends State<_MarketTab> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _all = [];
  bool _loading = true;
  String _selectedSpecies = 'All';
  String _sortBy = 'price_low';
  double _maxPrice = 1000;
  String _locationFilter = '';
  bool _showFilters = false;
  String? _buyerName, _buyerLocation;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid != null) {
        final p = await _client.from('profiles').select('full_name, region').eq('id', uid).maybeSingle();
        if (p != null) { _buyerName = p['full_name']; _buyerLocation = p['region']; }
      }
      final data = await _client
          .from('listings')
          .select('*, profiles(full_name, farm_name, region)')
          .eq('status', 'active')
          .order('created_at', ascending: false);
      setState(() => _all = List<Map<String, dynamic>>.from(data));
    } catch (_) {
      setState(() => _all = _mock());
    }
    setState(() => _loading = false);
  }

  List<Map<String, dynamic>> _mock() => [
    _m('Catla',  'Rajesh Farms',   'Rajesh Kumar',   180, 120, 1.8, 'Nashik, Maharashtra'),
    _m('Catla',  'Blue Pond Farm', 'Suresh Patil',   165, 80,  2.1, 'Pune, Maharashtra'),
    _m('Catla',  'Green Aqua',     'Amit Shah',       195, 200, 1.5, 'Thane, Maharashtra'),
    _m('Rohu',   'Sunrise Fish',   'Priya Devi',      145, 150, 1.2, 'Nagpur, Maharashtra'),
    _m('Rohu',   'River Edge',     'Mohan Lal',       138, 60,  1.4, 'Aurangabad, Maharashtra'),
    _m('Rohu',   'AquaGold',       'Sanjay Yadav',    155, 90,  1.6, 'Mumbai, Maharashtra'),
    _m('Mrigal', 'Crystal Waters', 'Kavita Singh',    130, 110, 0.9, 'Kolhapur, Maharashtra'),
    _m('Mrigal', 'Heritage Pond',  'Ramesh Nair',     142, 45,  1.1, 'Solapur, Maharashtra'),
    _m('Tilapia (Nile)', 'FastFish','Vijay More',     120, 200, 0.8, 'Satara, Maharashtra'),
    _m('Pangasius', 'Delta Aqua',  'Nilesh Patil',    110, 300, 1.0, 'Latur, Maharashtra'),
  ];

  Map<String, dynamic> _m(String sp, String fn, String farmer, double price,
      double qty, double wt, String loc) => {
    'id': '${sp}_${fn.hashCode}', 'species': sp, 'price_per_kg': price,
    'quantity_kg': qty, 'avg_weight_kg': wt, 'min_order_kg': 5.0,
    'status': 'active', 'farmer_id': farmer.hashCode.toString(),
    'profiles': {'full_name': farmer, 'farm_name': fn, 'region': loc},
  };

  List<Map<String, dynamic>> get _filtered {
    var list = List<Map<String, dynamic>>.from(_all);
    if (_selectedSpecies != 'All') list = list.where((l) => l['species'] == _selectedSpecies).toList();
    list = list.where((l) => ((l['price_per_kg'] as num?)?.toDouble() ?? 0) <= _maxPrice).toList();
    if (_locationFilter.isNotEmpty) {
      list = list.where((l) {
        final p = l['profiles'] as Map<String, dynamic>?;
        return (p?['region'] ?? '').toString().toLowerCase().contains(_locationFilter.toLowerCase());
      }).toList();
    }
    switch (_sortBy) {
      case 'price_low':  list.sort((a, b) => ((a['price_per_kg'] as num?) ?? 0).compareTo((b['price_per_kg'] as num?) ?? 0)); break;
      case 'price_high': list.sort((a, b) => ((b['price_per_kg'] as num?) ?? 0).compareTo((a['price_per_kg'] as num?) ?? 0)); break;
      case 'qty_high':   list.sort((a, b) => ((b['quantity_kg']  as num?) ?? 0).compareTo((a['quantity_kg']  as num?) ?? 0)); break;
    }
    return list;
  }

  Map<String, List<Map<String, dynamic>>> get _grouped {
    final r = <String, List<Map<String, dynamic>>>{};
    for (final item in _filtered) {
      final s = item['species'] as String? ?? 'Other';
      r.putIfAbsent(s, () => []).add(item);
    }
    return r;
  }

  List<String> get _allSpecies {
    final s = _all.map((l) => l['species'] as String? ?? 'Other').toSet().toList()..sort();
    return ['All', ..._kPrimarySpecies, ...s.where((x) => !_kPrimarySpecies.contains(x))];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      // App bar
      SliverAppBar(
        expandedHeight: 130, pinned: true,
        backgroundColor: _kGreenDark,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_kGreenDark, _kGreen],
                  begin: Alignment.topLeft, end: Alignment.bottomRight)),
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(_buyerName != null ? 'Hello, ${_buyerName!.split(' ').first} 👋' : 'BlueFarm Market 🐟',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(_buyerLocation != null ? '📍 $_buyerLocation' : 'Fresh fish, direct from farms',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.tune_rounded, color: Colors.white),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),

      SliverToBoxAdapter(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _locationFilter = v),
              decoration: InputDecoration(
                hintText: 'Filter by location...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
            ),
          ),

          // Filter panel
          if (_showFilters) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Filters & Sort',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Max Price: ₹${_maxPrice.toInt()}/kg',
                      style: const TextStyle(fontSize: 13, color: _kMuted)),
                  const Text('₹1000', style: TextStyle(fontSize: 11, color: _kMuted)),
                ]),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _kGreen, thumbColor: _kGreen,
                      overlayColor: _kGreen.withOpacity(0.12)),
                  child: Slider(value: _maxPrice, min: 50, max: 1000, divisions: 19,
                      onChanged: (v) => setState(() => _maxPrice = v)),
                ),
                const SizedBox(height: 8),
                const Text('Sort by', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: [
                  _sortChip('Lowest Price',   'price_low'),
                  _sortChip('Most Available', 'qty_high'),
                  _sortChip('Highest Price',  'price_high'),
                ]),
              ]),
            ),
          ],

          // Species chips
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _allSpecies.length,
              itemBuilder: (_, i) {
                final s = _allSpecies[i];
                final selected = _selectedSpecies == s;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSpecies = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? _kGreen : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? _kGreen : Colors.grey.shade300),
                    ),
                    child: Text(
                      s == 'All' ? '🐟 All' : '${_kSpeciesEmoji[s] ?? '🐠'} $s',
                      style: TextStyle(
                        color: selected ? Colors.white : _kText,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),

      // Listings
      if (_loading)
        const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: _kGreen)))
      else if (_filtered.isEmpty)
        SliverFillRemaining(
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🐟', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No listings found', style: TextStyle(color: _kMuted, fontSize: 16)),
          ])),
        )
      else
        SliverList(delegate: SliverChildListDelegate(_buildContent())),

      const SliverToBoxAdapter(child: SizedBox(height: 100)),
    ]);
  }

  Widget _sortChip(String label, String value) {
    final sel = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: sel ? _kGreen : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                color: sel ? Colors.white : _kMuted,
                fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  List<Widget> _buildContent() {
    if (_selectedSpecies != 'All') {
      return _section(_selectedSpecies, _grouped[_selectedSpecies] ?? []);
    }
    final result = <Widget>[];
    for (final sp in _kPrimarySpecies) {
      if ((_grouped[sp] ?? []).isNotEmpty) result.addAll(_section(sp, _grouped[sp]!));
    }
    for (final entry in _grouped.entries) {
      if (!_kPrimarySpecies.contains(entry.key)) result.addAll(_section(entry.key, entry.value));
    }
    return result;
  }

  List<Widget> _section(String species, List<Map<String, dynamic>> listings) {
    final color   = _kSpeciesColor[species] ?? _kGreen;
    final bgColor = _kSpeciesBg[species]    ?? const Color(0xFFE8F5E9);
    final emoji   = _kSpeciesEmoji[species] ?? '🐠';
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(species, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color)),
            Text('${listings.length} seller${listings.length != 1 ? 's' : ''} available',
                style: TextStyle(fontSize: 12, color: _kMuted)),
          ]),
        ]),
      ),
      ...listings.map((l) => _ListingCard(
          listing: l, onAddToCart: widget.onAddToCart, cart: widget.cart)),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LISTING CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ListingCard extends StatefulWidget {
  final Map<String, dynamic> listing;
  final void Function(CartItem) onAddToCart;
  final List<CartItem> cart;
  const _ListingCard({required this.listing, required this.onAddToCart, required this.cart});

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard> {
  double _qty = 5;

  Map<String, dynamic> get _profile => (widget.listing['profiles'] as Map<String, dynamic>?) ?? {};
  bool   get _inCart    => widget.cart.any((c) => c.listingId == widget.listing['id'].toString());
  double get _price     => (widget.listing['price_per_kg'] as num?)?.toDouble()  ?? 0;
  double get _available => (widget.listing['quantity_kg']  as num?)?.toDouble()  ?? 0;
  double get _avgWt     => (widget.listing['avg_weight_kg'] as num?)?.toDouble() ?? 0;
  String get _species   => widget.listing['species']  as String? ?? '';
  String get _farmName  => _profile['farm_name']  as String? ?? 'Farm';
  String get _farmer    => _profile['full_name']  as String? ?? 'Farmer';
  String get _location  => _profile['region']     as String? ?? '';
  Color  get _color     => _kSpeciesColor[_species] ?? _kGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _inCart ? _kGreen.withOpacity(0.4) : Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Header: farm + price
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(_kSpeciesEmoji[_species] ?? '🐠',
                  style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_farmName,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _kText),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(_farmer, style: TextStyle(fontSize: 11, color: _kMuted)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('₹${_price.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _color)),
              Text('per kg', style: TextStyle(fontSize: 10, color: _kMuted)),
            ]),
          ]),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 10),

          // Info row
          Row(children: [
            _chip(Icons.scale_rounded, '${_available.toStringAsFixed(0)} kg'),
            const SizedBox(width: 8),
            if (_avgWt > 0) ...[
              _chip(Icons.straighten_rounded, '~${_avgWt.toStringAsFixed(1)} kg avg'),
              const SizedBox(width: 8),
            ],
            Expanded(child: _chip(Icons.location_on_rounded,
                _location.isNotEmpty ? _location.split(',').first : 'N/A', expand: true)),
          ]),

          const SizedBox(height: 12),

          // Qty + Add
          Row(children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                _qBtn(Icons.remove_rounded,
                    () => setState(() => _qty = (_qty - 5).clamp(5, _available))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('${_qty.toStringAsFixed(0)} kg',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                _qBtn(Icons.add_rounded,
                    () => setState(() => _qty = (_qty + 5).clamp(5, _available))),
              ]),
            ),
            const SizedBox(width: 10),
            Text('₹${(_price * _qty).toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _color)),
            const Spacer(),
            GestureDetector(
              onTap: _inCart ? null : () => widget.onAddToCart(CartItem(
                listingId: widget.listing['id'].toString(),
                farmerId: widget.listing['farmer_id']?.toString() ?? '',
                species: _species, farmName: _farmName, farmerName: _farmer,
                pricePerKg: _price, availableKg: _available,
                location: _location, quantityKg: _qty,
              )),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: _inCart ? Colors.grey.shade200 : _color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_inCart ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
                      color: _inCart ? _kMuted : Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(_inCart ? 'Added' : 'Add to Cart',
                      style: TextStyle(
                          color: _inCart ? _kMuted : Colors.white,
                          fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _chip(IconData icon, String label, {bool expand = false}) {
    final inner = Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: _kMuted),
      const SizedBox(width: 4),
      expand
          ? Expanded(child: Text(label,
              style: TextStyle(fontSize: 11, color: _kMuted), overflow: TextOverflow.ellipsis))
          : Text(label, style: TextStyle(fontSize: 11, color: _kMuted)),
    ]);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: expand ? Row(children: [Expanded(child: inner)]) : inner,
    );
  }

  Widget _qBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: _kGreen)),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  CART SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _CartSheet extends StatelessWidget {
  final List<CartItem> cart;
  final double total;
  final void Function(String) onRemove;
  final void Function(String, double) onUpdateQty;
  final VoidCallback onClear, onCheckout;

  const _CartSheet({required this.cart, required this.total,
      required this.onRemove, required this.onUpdateQty,
      required this.onClear, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            const Text('Your Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (cart.isNotEmpty)
              TextButton(
                  onPressed: onClear,
                  child: Text('Clear all', style: TextStyle(color: Colors.red.shade400, fontSize: 13))),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: cart.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🛒', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('Your cart is empty', style: TextStyle(color: _kMuted, fontSize: 16)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.length,
                  itemBuilder: (_, i) {
                    final item  = cart[i];
                    final color = _kSpeciesColor[item.species] ?? _kGreen;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                              color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text(_kSpeciesEmoji[item.species] ?? '🐠',
                              style: const TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.species,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          Text(item.farmName, style: TextStyle(fontSize: 11, color: _kMuted)),
                          Text('₹${item.pricePerKg.toStringAsFixed(0)}/kg',
                              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
                        ])),
                        Row(children: [
                          _qb(Icons.remove_rounded, () => onUpdateQty(item.listingId, item.quantityKg - 5)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('${item.quantityKg.toStringAsFixed(0)}kg',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                          _qb(Icons.add_rounded, () => onUpdateQty(item.listingId, item.quantityKg + 5)),
                        ]),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('₹${item.subtotal.toStringAsFixed(0)}',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color)),
                          GestureDetector(
                            onTap: () => onRemove(item.listingId),
                            child: Text('Remove', style: TextStyle(fontSize: 10, color: Colors.red.shade400)),
                          ),
                        ]),
                      ]),
                    );
                  },
                ),
        ),
        if (cart.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                    blurRadius: 16, offset: const Offset(0, -4))]),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text('₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _kGreen)),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCheckout,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _kGreen, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Proceed to Checkout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
      ]),
    );
  }

  Widget _qb(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300)),
      child: Icon(icon, size: 14, color: _kGreen),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  CHECKOUT SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _CheckoutSheet extends StatefulWidget {
  final List<CartItem> cart;
  final double total;
  final VoidCallback onConfirmed;

  const _CheckoutSheet({required this.cart, required this.total, required this.onConfirmed});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final _client      = Supabase.instance.client;
  final _locCtrl     = TextEditingController();
  bool  _placing     = false;
  bool  _placed      = false;

  @override
  void initState() { super.initState(); _prefill(); }

  @override
  void dispose() { _locCtrl.dispose(); super.dispose(); }

  Future<void> _prefill() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final p = await _client.from('profiles').select('region').eq('id', uid).maybeSingle();
      if (p != null) _locCtrl.text = p['region'] as String? ?? '';
    } catch (_) {}
  }

  Future<void> _place() async {
    setState(() => _placing = true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return;
      for (final item in widget.cart) {
        await _client.from('orders').insert({
          'listing_id': item.listingId, 'buyer_id': uid, 'farmer_id': item.farmerId,
          'species': item.species, 'farm_name': item.farmName,
          'quantity_kg': item.quantityKg, 'price_per_kg': item.pricePerKg,
          'total_price': item.subtotal, 'delivery_address': _locCtrl.text.trim(),
          'status': 'confirmed',
        });
      }
      setState(() { _placing = false; _placed = true; });
      await Future.delayed(const Duration(milliseconds: 1800));
      if (mounted) { Navigator.of(context).pop(); widget.onConfirmed(); }
    } catch (e) {
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order failed: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: _placed ? _success() : _form(),
    );
  }

  Widget _success() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 80, height: 80,
        decoration: const BoxDecoration(color: _kGreen, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 44)),
    const SizedBox(height: 20),
    const Text('Order Placed! 🎉',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    Text('Your order is confirmed.\nFarmers will be notified.',
        textAlign: TextAlign.center,
        style: TextStyle(color: _kMuted, fontSize: 14, height: 1.5)),
  ]));

  Widget _form() {
    final grand = widget.total + 50;
    return Column(children: [
      Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Align(alignment: Alignment.centerLeft,
            child: Text('Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
      ),
      const Divider(height: 1),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Order Summary',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            ...widget.cart.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Text('${_kSpeciesEmoji[item.species] ?? '🐠'} ${item.species}',
                    style: const TextStyle(fontSize: 13)),
                const Spacer(),
                Text('${item.quantityKg.toStringAsFixed(0)} kg × ₹${item.pricePerKg.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 12, color: _kMuted)),
                const SizedBox(width: 8),
                Text('₹${item.subtotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
            )),
            const Divider(height: 20),
            _row('Subtotal', '₹${widget.total.toStringAsFixed(0)}'),
            const SizedBox(height: 6),
            _row('Delivery fee', '₹50'),
            const Divider(height: 16),
            Row(children: [
              const Text('Grand Total',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const Spacer(),
              Text('₹${grand.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: _kGreen)),
            ]),
            const SizedBox(height: 20),
            const Text('Delivery / Business Location',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _locCtrl, maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Enter your delivery address',
                prefixIcon: const Icon(Icons.location_on_outlined, color: _kGreen),
                filled: true, fillColor: _kBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kGreen)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kAmber.withOpacity(0.4))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded, color: _kAmber, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'Your order will be confirmed immediately. Farmers will prepare your fish for delivery.',
                  style: TextStyle(fontSize: 12, color: Colors.amber.shade800, height: 1.4),
                )),
              ]),
            ),
          ]),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                blurRadius: 16, offset: const Offset(0, -4))]),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _placing ? null : _place,
            style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen, foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4, shadowColor: _kGreen.withOpacity(0.4)),
            child: _placing
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text('Place Order · ₹${grand.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ]);
  }

  Widget _row(String l, String v) => Row(children: [
    Text(l, style: TextStyle(fontSize: 13, color: _kMuted)),
    const Spacer(),
    Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
//  ORDERS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return;
      final data = await _client.from('orders').select().eq('buyer_id', uid).order('created_at', ascending: false);
      setState(() => _orders = List<Map<String, dynamic>>.from(data));
    } catch (_) {}
    setState(() => _loading = false);
  }

  Color    _sc(String s) { switch(s) { case 'confirmed': return _kGreen; case 'delivered': return Colors.blue; case 'cancelled': return Colors.red; default: return _kAmber; } }
  IconData _si(String s) { switch(s) { case 'confirmed': return Icons.check_circle_rounded; case 'delivered': return Icons.local_shipping_rounded; case 'cancelled': return Icons.cancel_rounded; default: return Icons.pending_rounded; } }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true, backgroundColor: _kGreenDark,
          title: const Text('My Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          actions: [IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: _load)],
        ),
        if (_loading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: _kGreen)))
        else if (_orders.isEmpty)
          SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('📦', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No orders yet', style: TextStyle(color: _kMuted, fontSize: 16)),
          ])))
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildBuilderDelegate((_, i) {
              final o = _orders[i]; final status = o['status'] as String? ?? 'pending';
              final color = _sc(status);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Container(width: 48, height: 48,
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(_si(status), color: color, size: 24)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${_kSpeciesEmoji[o['species']] ?? '🐠'} ${o['species'] ?? 'Fish Order'}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 3),
                      Text(o['farm_name'] != null ? 'From: ${o['farm_name']}' : 'Order #${o['id'].toString().substring(0, 8)}',
                          style: TextStyle(fontSize: 12, color: _kMuted)),
                      Text('${(o['quantity_kg'] as num?)?.toStringAsFixed(0) ?? '?'} kg · ₹${(o['total_price'] as num?)?.toStringAsFixed(0) ?? '?'}',
                          style: TextStyle(fontSize: 12, color: _kGreen, fontWeight: FontWeight.w700)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
                      child: Text(status[0].toUpperCase() + status.substring(1),
                          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
              );
            }, childCount: _orders.length)),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PROFILE TAB
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final _client = Supabase.instance.client;
  Map<String, dynamic>? _profile;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final d = await _client.from('profiles').select().eq('id', uid).maybeSingle();
      setState(() => _profile = d);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final name    = _profile?['full_name']    as String? ?? 'Buyer';
    final company = _profile?['company_name'] as String? ?? '';
    final type    = _profile?['buyer_type']   as String? ?? '';
    final region  = _profile?['region']       as String? ?? '';
    final phone   = _client.auth.currentUser?.phone ?? '';
    final email   = _client.auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true, expandedHeight: 160, backgroundColor: _kGreenDark,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [_kGreenDark, _kGreen],
                      begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 2)),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 8),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                if (company.isNotEmpty)
                  Text(company, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
              ]),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(delegate: SliverChildListDelegate([
            if (_profile?['aadhaar_verified'] == true)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: _kGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kGreen.withOpacity(0.25))),
                child: const Row(children: [
                  Icon(Icons.verified_rounded, color: _kGreen, size: 18),
                  SizedBox(width: 8),
                  Text('Aadhaar Verified Buyer',
                      style: TextStyle(color: _kGreen, fontWeight: FontWeight.w700, fontSize: 13)),
                ]),
              ),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
              child: Column(children: [
                if (type.isNotEmpty)   _pr('Buyer Type', type,   Icons.category_rounded),
                if (region.isNotEmpty) _pr('Location',   region, Icons.location_on_rounded),
                if (phone.isNotEmpty)  _pr('Phone',      phone,  Icons.phone_rounded),
                if (email.isNotEmpty)  _pr('Email',      email,  Icons.email_rounded),
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                label: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => _client.auth.signOut(),
              ),
            ),
            const SizedBox(height: 80),
          ])),
        ),
      ]),
    );
  }

  Widget _pr(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      Icon(icon, size: 18, color: _kGreen),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: _kMuted)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    ]),
  );
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyerShell extends StatefulWidget {
  const BuyerShell({super.key});

  @override
  State<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends State<BuyerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('BlueFarm Market',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () =>
                Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          _MarketplaceTab(),
          _MyOrdersTab(),
          _BuyerProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.storefront), label: 'Marketplace'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long), label: 'My Orders'),
          NavigationDestination(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── MARKETPLACE ───────────────────────────────────────────────────────────────
class _MarketplaceTab extends StatefulWidget {
  const _MarketplaceTab();

  @override
  State<_MarketplaceTab> createState() => _MarketplaceTabState();
}

class _MarketplaceTabState extends State<_MarketplaceTab> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _listings = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _loading = true);
    try {
      final data = await _client
          .from('listings')
          .select(
              '*, profiles(full_name, farm_name, farm_location)')
          .eq('status', 'active')
          .order('created_at', ascending: false);
      setState(() =>
          _listings = List<Map<String, dynamic>>.from(data));
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _listings
        .where((l) => (l['species'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_search.toLowerCase()))
        .toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search fish species...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (v) => setState(() => _search = v),
        ),
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadListings,
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No listings found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) => _ListingCard(
                          listing: filtered[i],
                          onRefresh: _loadListings,
                        ),
                      ),
              ),
      ),
    ]);
  }
}

class _ListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onRefresh;

  const _ListingCard(
      {required this.listing, required this.onRefresh});

  Future<void> _sendRequest(BuildContext context) async {
    final client = Supabase.instance.client;
    final buyerId = client.auth.currentUser?.id;
    if (buyerId == null) return;
    try {
      await client.from('orders').insert({
        'listing_id': listing['id'],
        'buyer_id': buyerId,
        'farmer_id': listing['farmer_id'],
        'quantity_kg': listing['min_order_kg'] ?? 1.0,
        'agreed_price': listing['price_per_kg'],
        'status': 'requested',
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Purchase request sent!')));
      }
      onRefresh();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile =
        listing['profiles'] as Map<String, dynamic>?;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(listing['species'] ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                          '₹${listing['price_per_kg']}/kg',
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
              const SizedBox(height: 8),
              Text(
                  'Available: ${listing['quantity_kg']} kg  •  Min: ${listing['min_order_kg']} kg',
                  style: const TextStyle(color: Colors.grey)),
              Text(
                  'Farm: ${profile?['farm_name'] ?? 'N/A'}  •  ${profile?['farm_location'] ?? ''}',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
              if (listing['description'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(listing['description'],
                      style: const TextStyle(fontSize: 13)),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _sendRequest(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A6FA8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Send Purchase Request'),
                ),
              ),
            ]),
      ),
    );
  }
}

// ── MY ORDERS ─────────────────────────────────────────────────────────────────
class _MyOrdersTab extends StatefulWidget {
  const _MyOrdersTab();

  @override
  State<_MyOrdersTab> createState() => _MyOrdersTabState();
}

class _MyOrdersTabState extends State<_MyOrdersTab> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      final data = await _client
          .from('orders')
          .select('*, listings(species, price_per_kg)')
          .eq('buyer_id', userId)
          .order('created_at', ascending: false);
      setState(() =>
          _orders = List<Map<String, dynamic>>.from(data));
    } catch (_) {}
    setState(() => _loading = false);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'requested':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'delivered':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadOrders,
            child: _orders.isEmpty
                ? const Center(child: Text('No orders yet'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (ctx, i) {
                      final o = _orders[i];
                      final listing = o['listings']
                          as Map<String, dynamic>?;
                      return Card(
                        margin:
                            const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                              listing?['species'] ?? 'Order'),
                          subtitle: Text(
                              '${o['quantity_kg']} kg  •  ₹${o['agreed_price']}/kg'),
                          trailing: Chip(
                            label: Text(o['status'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11)),
                            backgroundColor:
                                _statusColor(o['status'] ?? ''),
                          ),
                        ),
                      );
                    },
                  ),
          );
  }
}

// ── PROFILE ───────────────────────────────────────────────────────────────────
class _BuyerProfileTab extends StatelessWidget {
  const _BuyerProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 16),
          Text(user?.phone ?? user?.email ?? 'Buyer',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Chip(label: Text('Buyer')),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            onPressed: () =>
                Supabase.instance.client.auth.signOut(),
          ),
        ]),
      ),
    );
  }
}
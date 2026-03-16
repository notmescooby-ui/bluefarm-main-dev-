import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _client = Supabase.instance.client;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _readings = [];
  List<Map<String, dynamic>> _pendingAdmins = [];
  bool _loading = true;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _client
            .from('profiles')
            .select('id, full_name, role, farm_name, account_status, created_at')
            .order('created_at', ascending: false),
        _client
            .from('sensor_readings')
            .select()
            .order('created_at', ascending: false)
            .limit(50),
        _client.from('listings').select('id, status').eq('status', 'active'),
        _client.from('orders').select('id, status'),
      ]);

      final users    = List<Map<String, dynamic>>.from(results[0] as List);
      final readings = List<Map<String, dynamic>>.from(results[1] as List);
      final listings = results[2] as List;
      final orders   = results[3] as List;

      setState(() {
        _users    = users;
        _readings = readings;
        _pendingAdmins = users
            .where((u) => u['role'] == 'admin' && u['account_status'] == 'pending')
            .toList();
        _stats = {
          'total_users':     users.length,
          'farmers':         users.where((u) => u['role'] == 'farmer').length,
          'buyers':          users.where((u) => u['role'] == 'buyer').length,
          'pending_admins':  _pendingAdmins.length,
          'active_listings': listings.length,
          'total_orders':    orders.length,
          'total_readings':  readings.length,
        };
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _approveAdmin(String userId) async {
    await _client
        .from('profiles')
        .update({'account_status': 'active'}).eq('id', userId);
    _showSnack('Account approved', success: true);
    _loadData();
  }

  Future<void> _rejectAdmin(String userId) async {
    await _client
        .from('profiles')
        .update({'account_status': 'rejected'}).eq('id', userId);
    _showSnack('Account rejected');
    _loadData();
  }

  void _showSnack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          success ? const Color(0xFF059669) : const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D4F7C),
        title: const Text('Admin Dashboard',
            style: TextStyle(color: Colors.white)),
        actions: [
          if ((_stats['pending_admins'] ?? 0) > 0)
            Stack(children: [
              IconButton(
                icon: const Icon(Icons.person_add_rounded, color: Colors.white),
                onPressed: () => setState(() => _index = 3),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      '${_stats['pending_admins']}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ),
            ]),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _client.auth.signOut(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _index,
              children: [
                _buildOverview(),
                _buildUsers(),
                _buildSensorData(),
                _buildPendingApprovals(),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.dashboard), label: 'Overview'),
          const NavigationDestination(
              icon: Icon(Icons.people), label: 'Users'),
          const NavigationDestination(
              icon: Icon(Icons.sensors), label: 'Sensor Data'),
          NavigationDestination(
            icon: (_stats['pending_admins'] ?? 0) > 0
                ? Badge(
                    label: Text('${_stats['pending_admins']}'),
                    child: const Icon(Icons.pending_actions),
                  )
                : const Icon(Icons.pending_actions),
            label: 'Approvals',
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    final cards = [
      ('Total Users',     '${_stats['total_users']}',    Icons.people,          Colors.blue),
      ('Farmers',         '${_stats['farmers']}',         Icons.grass,           Colors.green),
      ('Buyers',          '${_stats['buyers']}',          Icons.storefront,      Colors.orange),
      ('Pending Admins',  '${_stats['pending_admins']}',  Icons.pending_actions, Colors.red),
      ('Active Listings', '${_stats['active_listings']}', Icons.list_alt,        Colors.teal),
      ('Total Orders',    '${_stats['total_orders']}',    Icons.receipt,         Colors.purple),
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: cards.length,
      itemBuilder: (ctx, i) {
        final (label, value, icon, color) = cards[i];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(value,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsers() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _users.isEmpty
          ? const Center(child: Text('No users yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _users.length,
              itemBuilder: (ctx, i) {
                final u = _users[i];
                final roleColor = u['role'] == 'admin'
                    ? Colors.purple
                    : u['role'] == 'buyer'
                        ? Colors.orange
                        : Colors.green;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: roleColor.withOpacity(0.15),
                      child: Icon(Icons.person, color: roleColor),
                    ),
                    title: Text(u['full_name'] ?? 'No name'),
                    subtitle: Text(u['farm_name'] ??
                        u['id'].toString().substring(0, 8)),
                    trailing: Chip(
                      label: Text(u['role'] ?? 'farmer',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11)),
                      backgroundColor: roleColor,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSensorData() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _readings.isEmpty
          ? const Center(child: Text('No sensor data yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _readings.length,
              itemBuilder: (ctx, i) {
                final r    = _readings[i];
                final time = DateTime.tryParse(r['created_at'] ?? '');
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'pH: ${r['ph']}  •  Temp: ${r['temperature']}°C',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text('Turbidity: ${r['turbidity']} NTU',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        Text(
                          time != null
                              ? '${time.hour}:${time.minute.toString().padLeft(2, '0')}'
                              : '',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPendingApprovals() {
    return _pendingAdmins.isEmpty
        ? const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('No pending approvals',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _pendingAdmins.length,
            itemBuilder: (ctx, i) {
              final u = _pendingAdmins[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const CircleAvatar(
                          backgroundColor: Color(0x1A4A148C),
                          child: Icon(Icons.developer_mode_rounded,
                              color: Color(0xFF4A148C)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u['full_name'] ?? 'Unknown',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(
                                  'ID: ${u['id'].toString().substring(0, 16)}...',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Pending',
                              style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontSize: 12)),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _approveAdmin(u['id']),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            onPressed: () => _rejectAdmin(u['id']),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
import re

# 1. Fix auth_service.dart braces
with open('lib/services/auth_service.dart', 'r', encoding='utf-8') as f:
    auth_srv = f.read()
# Let's just fix the whole class declaration
# My edit was:
# import 'package:firebase_auth/firebase_auth.dart';
# import 'package:google_sign_in/google_sign_in.dart';
# import 'package:cloud_firestore/cloud_firestore.dart';
# class AuthService {
# But if I replaced wrongly, I might have messed up the class line.
# Let's restore the class start if it is broken.
with open('lib/services/auth_service.dart', 'w', encoding='utf-8') as f:
    # Just fix if the file ends without closing brace
    if auth_srv.count('{') > auth_srv.count('}'):
        auth_srv += '\n}'
    f.write(auth_srv)

# 2. Fix main_shell.dart imports
with open('lib/screens/main_shell.dart', 'r', encoding='utf-8') as f:
    main_shell = f.read()
main_shell = main_shell.replace("import '../services/supabase_compatibility.dart';", "")
main_shell = main_shell.replace("import 'package:bluefarm/services/supabase_compatibility.dart';", "")
with open('lib/screens/main_shell.dart', 'w', encoding='utf-8') as f:
    f.write(main_shell)

# 3. Fix app_provider.dart
with open('lib/providers/app_provider.dart', 'r', encoding='utf-8') as f:
    app_prov = f.read()
app_prov = app_prov.replace("import '../services/supabase_service.dart';", "")
app_prov = app_prov.replace("final _supabase = SupabaseService();", "")
with open('lib/providers/app_provider.dart', 'w', encoding='utf-8') as f:
    f.write(app_prov)

# 4. Fix buyer_shell.dart
with open('lib/screens/buyer_shell.dart', 'r', encoding='utf-8') as f:
    buyer = f.read()

buyer = buyer.replace("import 'package:bluefarm/services/supabase_compatibility.dart' hide LaunchMode;", "")
buyer = buyer.replace("final uid = Supabase.instance.client.auth.currentUser?.id;", "final uid = FirebaseAuth.instance.currentUser?.uid;")
buyer = buyer.replace('''final p = await Supabase.instance.client
          .from('profiles')
          .select('full_name, region')
          .eq('id', uid)
          .maybeSingle();''', '''final doc = await FirebaseFirestore.instance.collection('profiles').doc(uid).get();\n      final p = doc.data();''')

# For the remaining _client errors, it seems they are in places my script missed:
# line 391: final data = await _client
fetch_market_bad = '''      var q = _client
          .from('listings')
          .select()
          .eq('status', 'active');
      if (_searchQuery.isNotEmpty) {
        q = q.ilike('species', '%%');
      }
      final data = await q;'''
fetch_market_good = '''      var q = FirebaseFirestore.instance.collection('listings').where('status', 'isEqualTo', 'active');
      final qs = await q.get();
      var data = qs.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return m;
      }).toList();
      if (_searchQuery.isNotEmpty) {
        data = data.where((item) => (item['species'] as String?)?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false).toList();
      }'''
buyer = buyer.replace(fetch_market_bad, fetch_market_good)

# line 1010: _client in _OrdersTabState
orders_bad = '''    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    setState(() => _loadingPast = true);
    try {
      final data = await _client
          .from('orders')
          .select()
          .eq('buyer_id', uid)
          .order('created_at', ascending: false);'''
orders_good = '''    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _loadingPast = true);
    try {
      final qs = await FirebaseFirestore.instance.collection('orders').where('buyer_id', isEqualTo: uid).orderBy('created_at', descending: true).get();
      final data = qs.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return m;
      }).toList();'''
buyer = buyer.replace(orders_bad, orders_good)

# line 1567: _client in _BillingPageState
billing_prefill_bad = '''    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final p = await _client
          .from('profiles')
          .select('full_name, region, phone')
          .eq('id', uid)
          .maybeSingle();'''
billing_prefill_good = '''    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('profiles').doc(uid).get();
      final p = doc.data();'''
buyer = buyer.replace(billing_prefill_bad, billing_prefill_good)

# line 1587: _client.from('orders').insert
billing_insert_bad = '''          if (_isUuid(item.farmerId)) {
            orderData['farmer_id'] = item.farmerId;
          }
          await _client.from('orders').insert(orderData);
        }'''
billing_insert_good = '''          if (_isUuid(item.farmerId)) {
            orderData['farmer_id'] = item.farmerId;
          }
          await FirebaseFirestore.instance.collection('orders').doc().set(orderData);
        }'''
buyer = buyer.replace(billing_insert_bad, billing_insert_good)

with open('lib/screens/buyer_shell.dart', 'w', encoding='utf-8') as f:
    f.write(buyer)
print('Done errors fixes')

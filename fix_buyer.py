with open('lib/screens/buyer_shell.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import re

# Fix listings query
text = re.sub(r'final data = await FirebaseFirestore\.instance\.collection\(\'listings\'\)\.get\(\);\s*\.select\(\'\*, profiles\(full_name, farm_name, region\)\'\);', 
              r'final snap = await FirebaseFirestore.instance.collection(\'listings\').get();\n      final data = snap.docs.map((d) => d.data()).toList();', 
              text, flags=re.MULTILINE)

# Fix orders query
text = re.sub(r'final data = await FirebaseFirestore\.instance\.collection\(\'orders\'\)\.get\(\);\s*\.select\(\);\s*\.eq\(\'buyer_id\', uid\);', 
              r'final snap = await FirebaseFirestore.instance.collection(\'orders\').where(\'buyer_id\', isEqualTo: uid).get();\n      final data = snap.docs.map((d) => d.data()).toList();', 
              text, flags=re.MULTILINE)

# If the above fails because of formatting, just do simpler replaces
text = text.replace("final data = await FirebaseFirestore.instance.collection('listings').get();\n          .select('*, profiles(full_name, farm_name, region)');", 
                    "final snap = await FirebaseFirestore.instance.collection('listings').get();\n      final data = snap.docs.map((d) => d.data()).toList();")

text = text.replace("final data = await FirebaseFirestore.instance.collection('orders').get();\n          .select()\n          .eq('buyer_id', uid);", 
                    "final snap = await FirebaseFirestore.instance.collection('orders').where('buyer_id', isEqualTo: uid).get();\n      final data = snap.docs.map((d) => d.data()).toList();")

text = text.replace("setState(() => _all = List<Map<String, dynamic>>.from(data));", "setState(() => _all = data);")
text = text.replace("setState(() => _pastOrders = List<Map<String, dynamic>>.from(data));", "setState(() => _pastOrders = data);")

with open('lib/screens/buyer_shell.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print('Fixed buyer_shell queries')

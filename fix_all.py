import os

with open('lib/screens/main_shell.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("p.userProfile?[\\'", "p.userProfile?['")
text = text.replace("\\']", "']")

with open('lib/screens/main_shell.dart', 'w', encoding='utf-8') as f:
    f.write(text)

with open('lib/main.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("..startRealtimeListening()", "..initializeData()")
lines = text.split('\n')
new_lines = []
skip = False
for line in lines:
    if 'Supabase.instance.client.auth.onAuthStateChange.listen' in line:
        skip = True
        continue
    if skip and '});' in line:
        skip = False
        continue
    if skip:
        continue
    if 'StreamSubscription<AuthState>? _authSub;' in line:
        continue
    if '_authSub?.cancel();' in line:
        continue
    new_lines.append(line)

with open('lib/main.dart', 'w', encoding='utf-8') as f:
    f.write('\n'.join(new_lines))

with open('lib/screens/buyer_shell.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("final data = []\n          .from('listings')", "final data = await FirebaseFirestore.instance.collection('listings').get();")
text = text.replace("final data = []\n          .from('orders')", "final data = await FirebaseFirestore.instance.collection('orders').get();")
text = text.replace(".from('listings')", ".collection('listings')")
text = text.replace(".from('orders')", ".collection('orders')")

with open('lib/screens/buyer_shell.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print('Done')

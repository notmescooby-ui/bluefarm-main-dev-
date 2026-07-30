with open('lib/screens/main_shell.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace any stray \' with '
text = text.replace("\\'", "'")

with open('lib/screens/main_shell.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print('Fixed stray single quotes in main_shell')

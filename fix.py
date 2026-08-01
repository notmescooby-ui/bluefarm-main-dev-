import os

file_path = 'c:/BlueFarm-main/lib/screens/farmer_info_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if '123456789012' in line:
        lines[i] = '        content = \'{"name": "${_registeredName}", "aadhaar": "123456789012", "hasEmblem": true}\';\\n'
        break

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

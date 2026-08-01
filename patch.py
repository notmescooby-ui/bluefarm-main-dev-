import os

file_path = 'c:/BlueFarm-main/lib/screens/farmer_info_screen.dart'
new_verify_path = 'c:/BlueFarm-main/new_verify.dart'

with open(new_verify_path, 'r', encoding='utf-8') as f:
    new_verify = f.read()

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

start_idx = content.find('  //  AADHAAR VERIFICATION')
end_idx = content.find('  // ── Submit ────────────────────────────────────────────────────────────────')

if start_idx != -1 and end_idx != -1:
    # Go back to the '  // ───' before AADHAAR VERIFICATION
    real_start_idx = content.rfind('  // ───', 0, start_idx)
    if real_start_idx != -1:
        start_idx = real_start_idx

    new_content = content[:start_idx] + new_verify + '\\n' + content[end_idx:]
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Replaced successfully!")
else:
    print("Could not find markers")

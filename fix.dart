import 'dart:io';

void main() {
  final file = File('c:/BlueFarm-main/lib/screens/farmer_info_screen.dart');
  var lines = file.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('"aadhaar": "123456789012"')) {
      lines[i] = '        content = \\\'{"name": "\${_nameCtrl.text.trim()}", "aadhaar": "123456789012", "hasEmblem": true}\\\';';
    }
  }
  file.writeAsStringSync(lines.join('\\n'));
}

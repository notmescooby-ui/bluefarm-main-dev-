import 'dart:io';

void main() {
  final file = File('c:/BlueFarm-main/lib/screens/farmer_info_screen.dart');
  var content = file.readAsStringSync();
  // Split by literal \n and join with actual newline
  var lines = content.split('\\n');
  file.writeAsStringSync(lines.join('\n'));
}

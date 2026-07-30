import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  int count = 0;
  
  for (var file in files) {
    var content = file.readAsStringSync();
    bool changed = false;
    
    if (content.contains('.withOpacity(')) {
      content = content.replaceAll('.withOpacity(', '.withValues(alpha: ');
      changed = true;
    }
    
    if (content.contains('activeColor:')) {
      content = content.replaceAll('activeColor:', 'activeThumbColor:');
      changed = true;
    }
    
    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed ${file.path}');
      count++;
    }
  }
  print('Fixed $count files');
}

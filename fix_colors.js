const fs = require('fs');
const glob = require('glob');

const files = [
  'lib/screens/main_shell.dart',
  'lib/screens/home_screen.dart',
  'lib/screens/ai_screen.dart',
  'lib/screens/camera_screen.dart',
  'lib/screens/hardware_screen.dart'
];

for (const file of files) {
  let content = fs.readFileSync(file, 'utf8');
  
  content = content.replace(/const TextStyle\(/g, 'TextStyle(');
  content = content.replace(/const Text\(/g, 'Text(');
  content = content.replace(/const Icon\(/g, 'Icon(');
  
  // Replace TextMuted
  content = content.replace(/AppTheme\.lightTextMuted/g, "Theme.of(context).textTheme.bodySmall?.color");
  
  fs.writeFileSync(file, content);
}

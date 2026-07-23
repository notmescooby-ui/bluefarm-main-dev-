const fs = require('fs');
let pub = fs.readFileSync('pubspec.yaml', 'utf8');

// The user wants to perfectly replace the dependencies section.
// Usually it looks like:
// dependencies:
//   flutter:
//     sdk: flutter
//   ...

// Let's replace anything from 'dependencies:' to 'dev_dependencies:'
const depIndex = pub.indexOf('\ndependencies:');
const devDepIndex = pub.indexOf('\ndev_dependencies:');

if (depIndex !== -1 && devDepIndex !== -1 && devDepIndex > depIndex) {
  const newDeps = `
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.32.0
  firebase_auth: ^4.20.0
  cloud_firestore: ^4.17.5
  fl_chart: ^0.68.0
  camera: ^0.11.0
  http: ^1.2.0
  shared_preferences: ^2.2.2
  google_fonts: ^6.1.0
  provider: ^6.1.1
  flutter_animate: ^4.3.0
  permission_handler: ^11.1.0
  image_picker: ^1.0.7
`;
  pub = pub.substring(0, depIndex) + newDeps + pub.substring(devDepIndex);
  fs.writeFileSync('pubspec.yaml', pub);
} else {
  console.log("Could not find dependencies/dev_dependencies blocks accurately.");
}

const fs = require('fs');
let manifest = fs.readFileSync('android/app/src/main/AndroidManifest.xml', 'utf8');

if (!manifest.includes('android.permission.INTERNET')) {
  // Add permissions just before <application
  const perms = `
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-feature android:name="android.hardware.camera"/>
    <uses-feature android:name="android.hardware.camera.autofocus"/>
`;
  manifest = manifest.replace('<application', perms + '    <application');
  fs.writeFileSync('android/app/src/main/AndroidManifest.xml', manifest);
  console.log("Updated AndroidManifest.xml");
} else {
  console.log("AndroidManifest.xml already updated");
}

let gradle = fs.readFileSync('android/app/build.gradle', 'utf8');
gradle = gradle.replace(/compileSdk = flutter.compileSdkVersion/g, 'compileSdk = 34');
gradle = gradle.replace(/minSdkVersion flutter.minSdkVersion/g, 'minSdkVersion 21');
fs.writeFileSync('android/app/build.gradle', gradle);
console.log("Updated build.gradle");

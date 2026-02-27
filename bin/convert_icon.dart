import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final inputPath = r'C:\Users\wjcheon\.gemini\antigravity\brain\180482d7-e7db-452b-825f-8baf451f8e9a\media__1772095129806.jpg';
  final outputPath = 'assets/icons/app_icon.png';

  final bytes = File(inputPath).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image != null) {
    File(outputPath).writeAsBytesSync(img.encodePng(image));
    print('✅ Saved transparent png to $outputPath');
  } else {
    print('Failed to decode jpg.');
  }
}

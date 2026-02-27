import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // 원본 이미지 경로
  final inputDir = r'C:\Users\wjcheon\.gemini\antigravity\brain\180482d7-e7db-452b-825f-8baf451f8e9a';
  final outputDir = r'C:\Users\wjcheon\.gemini\antigravity\brain\180482d7-e7db-452b-825f-8baf451f8e9a\store_assets';
  Directory(outputDir).createSync(recursive: true);

  final imagesToProcess = [
    'main_menu_1771984977455.png',
    'level_select_screenshot.png',
    'game_play_screenshot.png',
    'after_one_move_1771985014037.png',
    'wrong_move_penalty.png'
  ];

  // Play Store 권장 해상도
  final sizes = {
    'phone': {'width': 1080, 'height': 1920},
    'tablet_7inch': {'width': 1200, 'height': 1920},
    'tablet_10inch': {'width': 1600, 'height': 2560},
  };

  for (int i = 0; i < imagesToProcess.length; i++) {
    final fileName = imagesToProcess[i];
    final file = File('$inputDir\\$fileName');
    
    if (!file.existsSync()) {
      print('File not found: $fileName');
      continue;
    }

    final image = img.decodeImage(file.readAsBytesSync());
    if (image == null) continue;

    sizes.forEach((deviceType, dims) {
      final targetWidth = dims['width']!;
      final targetHeight = dims['height']!;
      
      // 원본 비율을 유지하면서 타겟 해상도에 맞게 리사이징 및 빈 공간은 배경색(#0D1520)으로 채움
      final resized = img.copyResizeCropSquare(image, size: targetWidth); // This doesn't work well for rectangles, let's use copyResize with fit
      
      // Create a blank canvas with the target background color
      final canvas = img.Image(width: targetWidth, height: targetHeight);
      img.fill(canvas, color: img.ColorRgb8(13, 21, 32)); // #0D1520 (게임 배경색)

      // Calculate scale to fit within target
      double scale = targetWidth / image.width;
      if (image.height * scale > targetHeight) {
        scale = targetHeight / image.height;
      }

      final scaledWidth = (image.width * scale).toInt();
      final scaledHeight = (image.height * scale).toInt();

      final scaledImage = img.copyResize(image, width: scaledWidth, height: scaledHeight, interpolation: img.Interpolation.linear);

      // Draw onto canvas centered
      final dstX = (targetWidth - scaledWidth) ~/ 2;
      final dstY = (targetHeight - scaledHeight) ~/ 2;

      img.compositeImage(canvas, scaledImage, dstX: dstX, dstY: dstY);

      final outName = '${deviceType}_screenshot_${i + 1}.png';
      File('$outputDir\\$outName').writeAsBytesSync(img.encodePng(canvas));
      print('Created $outName');
    });
  }
  print('All store assets generated successfully.');
}

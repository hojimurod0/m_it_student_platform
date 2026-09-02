// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final inputPath = r'C:\Users\user\.gemini\antigravity-ide\brain\8c8e2b66-8ff1-4ebe-99e3-4f0b75d6de9a\.user_uploaded\media_1788187180417.png';
  final inputFile = File(inputPath);
  
  if (!inputFile.existsSync()) {
    print('Error: Input file not found at $inputPath');
    return;
  }

  final bytes = inputFile.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('Error: Could not decode image');
    return;
  }

  print('Original size: ${image.width}x${image.height}');

  // 1. Generate 512x512 Play Store App Icon
  final resized512 = img.copyResize(
    image,
    width: 512,
    height: 512,
    interpolation: img.Interpolation.cubic,
  );

  final outputDir = Directory('assets/images');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final outPath512 = 'assets/images/app_icon_512.png';
  File(outPath512).writeAsBytesSync(img.encodePng(resized512));
  print('Saved: $outPath512 (512x512)');

  // 2. Generate 1024x500 Feature Graphic with the logo centered
  final featureGraphic = img.Image(width: 1024, height: 500);
  // Fill background with the lime color from the logo: #D3FF32 / #D2FF1F
  final bgColor = image.getPixel(10, 10);
  img.fill(featureGraphic, color: bgColor);

  // Resize icon to 280x280 for the center of feature graphic
  final centerLogo = img.copyResize(image, width: 280, height: 280, interpolation: img.Interpolation.cubic);
  final offsetX = (1024 - 280) ~/ 2;
  final offsetY = (500 - 280) ~/ 2;
  img.compositeImage(featureGraphic, centerLogo, dstX: offsetX, dstY: offsetY);

  final outPathFeature = 'assets/images/feature_graphic_1024x500.png';
  File(outPathFeature).writeAsBytesSync(img.encodePng(featureGraphic));
  print('Saved: $outPathFeature (1024x500)');
}

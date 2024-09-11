import 'package:flutter/foundation.dart';
import 'package:image/image.dart';

extension ImgX on Image {
  Image addPadding(
    int padding, {
    Color? paddingColor,
  }) {
    paddingColor ??= ColorRgb8(255, 255, 255);

    final int newWidth = width + (padding * 2);
    final int newHeight = height + (padding * 2);

    final paddedImage = Image(width: newWidth, height: newHeight);

    // Fill the new image with the padding color
    fill(paddedImage, color: paddingColor);

    // Copy the original image onto the new image with offset
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        paddedImage.setPixel(x + padding, y + padding, getPixel(x, y));
      }
    }

    return paddedImage;
  }
}

abstract final class ImageUtil {
  static bool isImage(String mime) => mime.startsWith('image');

  static Future<Uint8List> compress(
    Uint8List data, {
    int quality = 80,
    Image? Function(Uint8List data)? decoder,
    String? mime,
  }) async {
    decoder ??= switch (mime) {
      // Common image formats
      'image/jpeg' || 'image/jpg' => decodeJpg,
      'image/png' => decodePng,
      'image/gif' => decodeGif,
      'image/tiff' => decodeTiff,
      'image/webp' => decodeWebP,
      // For max image compatibility
      // [decodeImage] is slower than the specific decoders
      final String v when isImage(v) => decodeImage,
      // Non-image formats
      _ => null,
    };
    if (decoder == null) throw 'No decoder for: $mime';

    final img = await compute(decoder, data);
    if (img == null) throw 'Invalid image';
    return compute(
      (decoded) => encodeJpg(decoded, quality: quality),
      img,
    );
  }
}

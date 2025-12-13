import 'package:image_size_getter/image_size_getter.dart';

/// {@template image_size_getter.GifDecoder}
///
/// [GifDecoder] is a class for decoding gif image.
///
/// {@endtemplate}
class GifDecoder extends BaseDecoder with MutilFileHeaderAndFooterValidator {
  /// {@macro image_size_getter.GifDecoder}
  const GifDecoder();

  String get decoderName => 'gif';

  @override
  List<String> get supportedExtensions => List.unmodifiable(['gif']);

  Size _getSize(List<int> widthList, List<int> heightList) {
    final width = convertRadix16ToInt(widthList, reverse: true);
    final height = convertRadix16ToInt(heightList, reverse: true);

    return Size(width, height);
  }

  @override
  Size getSize(ImageInput input) {
    final widthList = input.getRange(6, 8);
    final heightList = input.getRange(8, 10);

    return _getSize(widthList, heightList);
  }

  @override
  Future<Size> getSizeAsync(AsyncImageInput input) async {
    final widthList = await input.getRange(6, 8);
    final heightList = await input.getRange(8, 10);

    return _getSize(widthList, heightList);
  }

  @override
  MutilFileHeaderAndFooter get headerAndFooter => _GifInfo();
}

/// Internal class that defines GIF file format validation rules.
///
/// This class supports both standard and non-standard GIF files:
/// - Standard GIF files end with the 0x3B trailer byte
/// - Non-standard GIF files may omit the 0x3B trailer
///
/// The relaxed footer validation (accepting files without 0x3B) is intentional
/// because:
/// 1. Some valid GIF files produced by certain encoders don't include the trailer
/// 2. The GIF size information is stored in the header (bytes 6-10), not the footer
/// 3. The primary purpose of this library is to extract image dimensions, not
///    to perform comprehensive file validation
/// 4. The GIF header is still validated, ensuring basic format correctness
class _GifInfo with MutilFileHeaderAndFooter {
  static const start89a = [
    0x47,
    0x49,
    0x46,
    0x38,
    0x37,
    0x61,
  ];
  static const start87a = [
    0x47,
    0x49,
    0x46,
    0x38,
    0x39,
    0x61,
  ];

  static const end = [0x3B];
  
  // Allow GIF files without the standard 0x3B trailer.
  // Some GIF encoders create valid GIF files without the trailer byte.
  // We provide both options: with trailer and without (empty list).
  static const emptyEnd = <int>[];

  @override
  List<List<int>> get mutipleEndBytesList => [end, emptyEnd];

  @override
  List<List<int>> get mutipleStartBytesList => [
        start87a,
        start89a,
      ];
}

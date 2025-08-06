import 'package:collection/collection.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:image_size_getter/src/entity/block_entity.dart';

/// {@template image_size_getter.JpegDecoder}
///
/// [JpegDecoder] is a class for decoding JPEG image.
///
/// {@endtemplate}
class JpegDecoder extends BaseDecoder with SimpleTypeValidator {
  /// {@macro image_size_getter.JpegDecoder}
  const JpegDecoder({
    this.isStandardJpeg = true,
  });

  final bool isStandardJpeg;

  @override
  String get decoderName => isStandardJpeg ? 'jpeg' : 'non-standard-jpeg';

  @override
  List<String> get supportedExtensions =>
      List.unmodifiable(['jpg', 'jpeg', 'jfif', 'pjpeg', 'pjp']);

  @override
  Size getSize(ImageInput input) {
    int start = 2;
    BlockEntity? block;
    var orientation = 1;

    while (true) {
      block = _getBlockSync(input, start);

      if (block == null) {
        throw Exception('Invalid jpeg file');
      }

      // Check for App1 block
      if (block.type == 0xE1) {
        final app1BlockData = input.getRange(
          start,
          block.start + block.length,
        );
        final exifOrientation = _getOrientation(app1BlockData);
        if (exifOrientation != null) {
          orientation = exifOrientation;
        }
      }

      if (block.type == 0xC0 || block.type == 0xC2) {
        final widthList = input.getRange(start + 7, start + 9);
        final heightList = input.getRange(start + 5, start + 7);
        return _getSize(widthList, heightList, orientation);
      } else {
        start += block.length;
      }
    }
  }

  Size _getSize(List<int> widthList, List<int> heightList, int orientation) {
    final width = convertRadix16ToInt(widthList);
    final height = convertRadix16ToInt(heightList);
    final needRotate = [5, 6, 7, 8].contains(orientation);
    return Size(width, height, needRotate: needRotate);
  }

  @override
  Future<Size> getSizeAsync(AsyncImageInput input) async {
    int start = 2;
    BlockEntity? block;
    var orientation = 1;

    while (true) {
      block = await _getBlockAsync(input, start);

      if (block == null) {
        throw Exception('Invalid jpeg file');
      }

      // Check for App1 block
      if (block.type == 0xE1) {
        final app1BlockData = await input.getRange(
          start,
          block.start + block.length,
        );
        final exifOrientation = _getOrientation(app1BlockData);
        if (exifOrientation != null) {
          orientation = exifOrientation;
        }
      }

      if (block.type == 0xC0 || block.type == 0xC2) {
        final widthList = await input.getRange(start + 7, start + 9);
        final heightList = await input.getRange(start + 5, start + 7);
        return _getSize(widthList, heightList, orientation);
      } else {
        start += block.length;
      }
    }
  }

  BlockEntity? _getBlockSync(ImageInput input, int blockStart) {
    try {
      final blockInfoList = input.getRange(blockStart, blockStart + 4);

      if (blockInfoList[0] != 0xFF) {
        return null;
      }

      final blockSizeList = input.getRange(blockStart + 2, blockStart + 4);

      return _createBlock(blockSizeList, blockStart, blockInfoList);
    } catch (e) {
      return null;
    }
  }

  Future<BlockEntity?> _getBlockAsync(
      AsyncImageInput input, int blockStart) async {
    try {
      final blockInfoList = await input.getRange(blockStart, blockStart + 4);

      if (blockInfoList[0] != 0xFF) {
        return null;
      }

      final blockSizeList =
          await input.getRange(blockStart + 2, blockStart + 4);

      return _createBlock(blockSizeList, blockStart, blockInfoList);
    } catch (e) {
      return null;
    }
  }

  BlockEntity _createBlock(
    List<int> sizeList,
    int blockStart,
    List<int> blockInfoList,
  ) {
    final blockLength =
        convertRadix16ToInt(sizeList) + 2; // +2 for 0xFF and TYPE
    final typeInt = blockInfoList[1];

    return BlockEntity(typeInt, blockLength, blockStart);
  }

  @override
  SimpleFileHeaderAndFooter get simpleFileHeaderAndFooter =>
      isStandardJpeg ? _JpegInfo() : _NonStandardJpegInfo();

  int? _getOrientation(List<int> app1blockData) {
    // About EXIF, See: https://www.media.mit.edu/pia/Research/deepview/exif.html#orientation

    // app1 block buffer:
    // header (2 bytes)
    // length (2 bytes)
    // exif header (6 bytes)
    // exif for little endian (2 bytes), 0x4d4d is for big endian, 0x4949 is for little endian
    // tag mark (2 bytes)
    // offset first IFD (4 bytes)
    // IFD data :
    // number of entries (2 bytes)
    // for each entry:
    //   exif tag (2 bytes)
    //   data format (2 bytes), 1 = unsigned byte, 2 = ascii, 3 = unsigned short, 4 = unsigned long, 5 = unsigned rational, 6 = signed byte, 7 = undefined, 8 = signed short, 9 = signed long, 10 = signed rational
    //   number of components (4 bytes)
    //   value (4 bytes)
    //   padding (0 ~ 3 bytes, depends on data format)
    // So, the IFD data starts at offset 14.

    // Check app1 block exif info is valid
    if (app1blockData.length < 14) {
      return null;
    }

    // Check app1 block exif info is valid
    final exifIdentifier = app1blockData.sublist(4, 10);

    final listEquality = ListEquality();

    if (!listEquality
        .equals(exifIdentifier, [0x45, 0x78, 0x69, 0x66, 0x00, 0x00])) {
      return null;
    }

    final littleEndian = app1blockData[10] == 0x49;

    int getNumber(int start, int end) {
      final numberList = app1blockData.sublist(start, end);
      return convertRadix16ToInt(numberList, reverse: littleEndian);
    }

    // Get idf byte
    var idf0Start = 18;
    final tagEntryCount = getNumber(idf0Start, idf0Start + 2);

    var currentIndex = idf0Start + 2;

    for (var i = 0; i < tagEntryCount; i++) {
      final tagType = getNumber(currentIndex, currentIndex + 2);

      if (tagType == 0x0112) {
        return getNumber(currentIndex + 8, currentIndex + 10);
      }

      // every tag length is 0xC bytes
      currentIndex += 0xC;
    }

    return null;
  }
}

class _JpegInfo with SimpleFileHeaderAndFooter {
  static const start = [0xFF, 0xD8];
  static const end = [0xFF, 0xD9];

  @override
  List<int> get endBytes => end;

  @override
  List<int> get startBytes => start;
}

/// Non-standard JPEG Info
///
/// Some mvimg files have a non-standard header.
///
/// The file is not end with 0xFFD9, so we need to use this to get the size.
class _NonStandardJpegInfo with SimpleFileHeaderAndFooter {
  static const start = [0xFF, 0xD8];
  static const end = <int>[];

  @override
  List<int> get endBytes => end;

  @override
  List<int> get startBytes => start;
}

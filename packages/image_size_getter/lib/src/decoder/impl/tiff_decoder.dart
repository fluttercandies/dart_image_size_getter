import 'package:image_size_getter/image_size_getter.dart';

/// {@template image_size_getter.TiffDecoder}
///
/// [TiffDecoder] is a class for decoding TIFF file.
///
/// {@endtemplate}
class TiffDecoder extends BaseDecoder {
  /// {@macro image_size_getter.TiffDecoder}
  const TiffDecoder();

  @override
  String get decoderName => 'tiff';

  @override
  List<String> get supportedExtensions => List.unmodifiable(['tif', 'tiff']);

  @override
  Size getSize(ImageInput input) {
    return _parseTiffSize(input, false);
  }

  @override
  Future<Size> getSizeAsync(AsyncImageInput input) async {
    return _parseTiffSizeAsync(input, false);
  }

  @override
  bool isValid(ImageInput input) {
    final header = input.getRange(0, 8);
    return _isTiff(header);
  }

  @override
  Future<bool> isValidAsync(AsyncImageInput input) async {
    final header = await input.getRange(0, 8);
    return _isTiff(header);
  }

  bool _isTiff(List<int> header) {
    if (header.length < 8) return false;
    
    // Check TIFF header: II (little endian) or MM (big endian) + 42
    final byteOrder = header.sublist(0, 2);
    final version = header.sublist(2, 4);
    
    // Little endian: 0x4949 (II) + 0x002A (42)
    final isLittleEndian = byteOrder[0] == 0x49 && byteOrder[1] == 0x49 &&
                          version[0] == 0x2A && version[1] == 0x00;
    
    // Big endian: 0x4D4D (MM) + 0x2A00 (42)
    final isBigEndian = byteOrder[0] == 0x4D && byteOrder[1] == 0x4D &&
                       version[0] == 0x00 && version[1] == 0x2A;
    
    return isLittleEndian || isBigEndian;
  }

  Size _parseTiffSize(ImageInput input, bool isAsync) {
    final header = input.getRange(0, 8);
    final isLittleEndian = header[0] == 0x49 && header[1] == 0x49;
    
    // Get IFD offset (bytes 4-7)
    final ifdOffsetBytes = input.getRange(4, 8);
    final ifdOffset = _convertToInt(ifdOffsetBytes, isLittleEndian);
    
    // Read IFD
    final ifdData = input.getRange(ifdOffset, ifdOffset + 2);
    final numEntries = _convertToInt(ifdData, isLittleEndian);
    
    int? width, height;
    
    // Read each IFD entry
    for (int i = 0; i < numEntries; i++) {
      final entryOffset = ifdOffset + 2 + (i * 12);
      final entry = input.getRange(entryOffset, entryOffset + 12);
      
      final tag = _convertToInt(entry.sublist(0, 2), isLittleEndian);
      final type = _convertToInt(entry.sublist(2, 4), isLittleEndian);
      final count = _convertToInt(entry.sublist(4, 8), isLittleEndian);
      final value = entry.sublist(8, 12);
      
      if (tag == 256) { // ImageWidth
        width = _getValue(value, type, count, isLittleEndian);
      } else if (tag == 257) { // ImageLength (height)
        height = _getValue(value, type, count, isLittleEndian);
      }
      
      if (width != null && height != null) break;
    }
    
    if (width == null || height == null) {
      throw Exception('Invalid TIFF file: missing width or height');
    }
    
    return Size(width, height);
  }

  Future<Size> _parseTiffSizeAsync(AsyncImageInput input, bool isAsync) async {
    final header = await input.getRange(0, 8);
    final isLittleEndian = header[0] == 0x49 && header[1] == 0x49;
    
    // Get IFD offset (bytes 4-7)
    final ifdOffsetBytes = await input.getRange(4, 8);
    final ifdOffset = _convertToInt(ifdOffsetBytes, isLittleEndian);
    
    // Read IFD
    final ifdData = await input.getRange(ifdOffset, ifdOffset + 2);
    final numEntries = _convertToInt(ifdData, isLittleEndian);
    
    int? width, height;
    
    // Read each IFD entry
    for (int i = 0; i < numEntries; i++) {
      final entryOffset = ifdOffset + 2 + (i * 12);
      final entry = await input.getRange(entryOffset, entryOffset + 12);
      
      final tag = _convertToInt(entry.sublist(0, 2), isLittleEndian);
      final type = _convertToInt(entry.sublist(2, 4), isLittleEndian);
      final count = _convertToInt(entry.sublist(4, 8), isLittleEndian);
      final value = entry.sublist(8, 12);
      
      if (tag == 256) { // ImageWidth
        width = _getValue(value, type, count, isLittleEndian);
      } else if (tag == 257) { // ImageLength (height)
        height = _getValue(value, type, count, isLittleEndian);
      }
      
      if (width != null && height != null) break;
    }
    
    if (width == null || height == null) {
      throw Exception('Invalid TIFF file: missing width or height');
    }
    
    return Size(width, height);
  }

  int _convertToInt(List<int> bytes, bool isLittleEndian) {
    if (isLittleEndian) {
      return convertRadix16ToInt(bytes, reverse: true);
    } else {
      return convertRadix16ToInt(bytes, reverse: false);
    }
  }

  int _getValue(List<int> valueBytes, int type, int count, bool isLittleEndian) {
    switch (type) {
      case 1: // BYTE
        return valueBytes[0];
      case 2: // ASCII
        return valueBytes[0];
      case 3: // SHORT
        return _convertToInt(valueBytes.sublist(0, 2), isLittleEndian);
      case 4: // LONG
        return _convertToInt(valueBytes, isLittleEndian);
      case 5: // RATIONAL
        // For simplicity, just return the numerator
        return _convertToInt(valueBytes.sublist(0, 4), isLittleEndian);
      default:
        return _convertToInt(valueBytes, isLittleEndian);
    }
  }
}

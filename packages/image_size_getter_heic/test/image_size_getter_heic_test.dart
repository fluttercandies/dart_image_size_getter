import 'dart:io';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter_heic/image_size_getter_heic.dart';
import 'package:test/test.dart';

void main() {
  group('Test heic decoder', () {
    final decoder = HeicDecoder();
    final input = FileInput(File('example/asset/example.heic'));
    test('sync', () {
      expect(decoder.isValid(input), equals(true));
    });

    test('async', () {
      final asyncInput = AsyncImageInput.input(input);
      expect(decoder.isValidAsync(asyncInput), completion(equals(true)));
    });

    test('extension', () {
      expect(decoder.isExtensionSupported('heic'), equals(true));
      expect(decoder.isExtensionSupported('HEIC'), equals(true));
      expect(decoder.isExtensionSupported('heif'), equals(true));
      expect(decoder.isExtensionSupported('HEIF'), equals(true));

      expect(decoder.isExtensionSupported('jpg'), equals(false));
      expect(decoder.isExtensionSupported('JPG'), equals(false));
    });
  });

  group('Test get heic size', () {
    final decoder = HeicDecoder();

    ImageSizeGetter.registerDecoder(decoder);

    final input = FileInput(File('example/asset/example.heic'));
    test('sync', () async {
      expect(decoder.getSize(input), equals(Size(1440, 960)));
    });

    test('async', () async {
      final asyncInput = AsyncImageInput.input(input);
      final size = await decoder.getSizeAsync(asyncInput);
      expect(size, equals(Size(1440, 960)));
    });
  });
}

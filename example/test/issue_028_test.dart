import 'dart:io';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:test/test.dart';

void main() {
  group('PNG with trailing bytes test', () {
    late List<File> pngFiles;

    setUpAll(() {
      final dir = Directory('asset/issue28');
      pngFiles = dir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.png'))
          .toList();

      expect(pngFiles.isNotEmpty, true,
          reason: 'No PNG files found in asset/issue28/');
    });

    test('all PNG files decode successfully with correct decoder name', () {
      for (final file in pngFiles) {
        final fileInput = FileInput(file);
        final result = ImageSizeGetter.getSizeResult(fileInput);

        expect(result.size.width, greaterThan(0));
        expect(result.size.height, greaterThan(0));
        expect(result.decoder.decoderName, 'png');
      }
    });

    test('PNG with trailing bytes after IEND still decodes correctly', () {
      // issue28-1.png has trailing data after its first IEND chunk.
      final bugPng = File('asset/issue28/issue28-1.png');

      expect(bugPng.existsSync(), true,
          reason: 'Expected fixture asset/issue28/issue28-1.png to exist');

      final result = ImageSizeGetter.getSizeResult(FileInput(bugPng));

      expect(result.size.width, 1000);
      expect(result.size.height, 1000);
      expect(result.decoder.decoderName, 'png');
    });

    test('standard PNG with no trailing bytes still decodes correctly', () {
      // issue28-2.png is a standard, well-formed PNG (IEND at EOF).
      final standardPng = File('asset/issue28/issue28-2.png');

      expect(standardPng.existsSync(), true,
          reason: 'Expected fixture asset/issue28/issue28-2.png to exist');

      final result = ImageSizeGetter.getSizeResult(FileInput(standardPng));

      expect(result.size.width, 2200);
      expect(result.size.height, 1467);
      expect(result.decoder.decoderName, 'png');
    });
  });
}

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:io';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:test/test.dart';

void main() {
  group('Test decoders', () {
    test('Test gif decoder', () {
      final gif = File('../../example/asset/dialog.gif');

      const GifDecoder decoder = GifDecoder();
      final input = FileInput(gif);

      assert(decoder.isValid(input));
      expect(decoder.getSize(input), Size(688, 1326));
    });

    test('Test jpeg decoder', () {
      final jpeg = File('../../example/asset/IMG_20180908_080245.jpg');

      const JpegDecoder decoder = JpegDecoder();
      final input = FileInput(jpeg);

      assert(decoder.isValid(input));
      expect(decoder.getSize(input), Size(4032, 3024));
    });

    test('Test non-standard jpeg decoder', () {
      final jpeg = File('../../example/asset/test.MP.jpg');

      const JpegDecoder decoder = JpegDecoder(isStandardJpeg: false);
      final input = FileInput(jpeg);

      assert(decoder.isValid(input));
      expect(decoder.getSize(input), Size(3840, 2160, needRotate: true));
    });

    test('Test png decoder', () {
      final png = File('../../example/asset/ic_launcher.png');

      const PngDecoder decoder = PngDecoder();
      final input = FileInput(png);

      assert(decoder.isValid(input));
      expect(decoder.getSize(input), Size(96, 96));
    });

    test('Test webp decoder', () {
      final webp = File('../../example/asset/demo.webp');

      const WebpDecoder decoder = WebpDecoder();
      final input = FileInput(webp);

      assert(decoder.isValid(input));
      expect(decoder.getSize(input), Size(988, 466));
    });

    test('Test bmp decoder', () {
      final bmp = File('../../example/asset/demo.bmp');

      const BmpDecoder decoder = BmpDecoder();
      final input = FileInput(bmp);

      assert(decoder.isValid(input));
      expect(decoder.getSize(input), Size(256, 256));
    });

    test('Test have orientation jpeg', () {
      final orientation3 =
          File('../../example/asset/have_orientation_exif_3.jpg');

      const JpegDecoder decoder = JpegDecoder();
      final input = FileInput(orientation3);

      assert(decoder.isValid(input));
      expect(decoder.getSize(input), Size(533, 799));

      final orientation6 =
          File('../../example/asset/have_orientation_exif_6.jpg');
      final input2 = FileInput(orientation6);

      assert(decoder.isValid(input2));
      final size = decoder.getSize(input2);
      expect(size, Size(3264, 2448, needRotate: true));
    });
  });

  group('Test get size.', () {
    test('Test webp size', () async {
      final file = File('../../example/asset/demo.webp');
      final size = ImageSizeGetter.getSize(FileInput(file));
      print('size = $size');
      await expectLater(size, Size(988, 466));

      final result = ImageSizeGetter.getSizeResult(FileInput(file));
      print('size = ${result.size} (decoded by ${result.decoder.decoderName})');
    });

    test('Test webp extended format size', () async {
      final file = File('../../example/asset/demo_extended.webp');
      final size = ImageSizeGetter.getSize(FileInput(file));
      print('size = $size');
      await expectLater(size, Size(988, 466));

      final result = ImageSizeGetter.getSizeResult(FileInput(file));
      print('size = ${result.size} (decoded by ${result.decoder.decoderName})');
    });

    test('Test webp lossless format size', () async {
      final file = File('../../example/asset/demo_lossless.webp');
      final size = ImageSizeGetter.getSize(FileInput(file));
      print('size = $size');
      await expectLater(size, Size(988, 466));

      final result = ImageSizeGetter.getSizeResult(FileInput(file));
      print('size = ${result.size} (decoded by ${result.decoder.decoderName})');
    });

    test('Test jpeg size', () async {
      final file = File('../../example/asset/IMG_20180908_080245.jpg');
      final size = ImageSizeGetter.getSize(FileInput(file));
      print('size = $size');
      await expectLater(size, Size(4032, 3024));

      final result = ImageSizeGetter.getSizeResult(FileInput(file));
      print('size = ${result.size} (decoded by ${result.decoder.decoderName})');
    });

    test('Test non-standard jpeg size', () async {
      final file = File('../../example/asset/test.MP.jpg');
      final size = ImageSizeGetter.getSize(FileInput(file));
      print('size = $size');
      await expectLater(size, Size(3840, 2160, needRotate: true));

      final result = ImageSizeGetter.getSizeResult(FileInput(file));
      print('size = ${result.size} (decoded by ${result.decoder.decoderName})');
    });

    group('Test gif size', () {
      test('89a', () async {
        final file = File('../../example/asset/dialog.gif');
        final size = ImageSizeGetter.getSize(FileInput(file));
        print('size = $size');
        await expectLater(size, Size(688, 1326));

        final result = ImageSizeGetter.getSizeResult(FileInput(file));
        print(
            'size = ${result.size} (decoded by ${result.decoder.decoderName})');
      });

      test('87a', () async {
        final file = File('../../example/asset/87a.gif');
        final size = ImageSizeGetter.getSize(FileInput(file));
        print('size = $size');
        await expectLater(size, Size(200, 150));

        final result = ImageSizeGetter.getSizeResult(FileInput(file));
        print(
            'size = ${result.size} (decoded by ${result.decoder.decoderName})');
      });
    });

    test('Test png size', () async {
      final file = File('../../example/asset/ic_launcher.png');
      final size = ImageSizeGetter.getSize(FileInput(file));
      print('size = $size');
      await expectLater(size, Size(96, 96));

      final result = ImageSizeGetter.getSizeResult(FileInput(file));
      print('size = ${result.size} (decoded by ${result.decoder.decoderName})');
    });

    test('Test png size with memory', () async {
      final file = File('../../example/asset/ic_launcher.png');
      final bytes = file.readAsBytesSync();
      final size = ImageSizeGetter.getSize(MemoryInput(bytes));
      print('size = $size');
      await expectLater(size, Size(96, 96));

      final result = ImageSizeGetter.getSizeResult(MemoryInput(bytes));
      print('size = ${result.size} (decoded by ${result.decoder.decoderName})');
    });
  });

  group('Test async methods', () {
    test('Test getSizeAsync with gif', () async {
      final file = File('../../example/asset/dialog.gif');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final size = await ImageSizeGetter.getSizeAsync(asyncInput);
      expect(size, Size(688, 1326));
    });

    test('Test getSizeAsync with jpeg', () async {
      final file = File('../../example/asset/IMG_20180908_080245.jpg');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final size = await ImageSizeGetter.getSizeAsync(asyncInput);
      expect(size, Size(4032, 3024));
    });

    test('Test getSizeAsync with non-standard jpeg', () async {
      final file = File('../../example/asset/test.MP.jpg');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final size = await ImageSizeGetter.getSizeAsync(asyncInput);
      expect(size, Size(3840, 2160, needRotate: true));
    });

    test('Test getSizeAsync with png', () async {
      final file = File('../../example/asset/ic_launcher.png');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final size = await ImageSizeGetter.getSizeAsync(asyncInput);
      expect(size, Size(96, 96));
    });

    test('Test getSizeAsync with webp', () async {
      final file = File('../../example/asset/demo.webp');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final size = await ImageSizeGetter.getSizeAsync(asyncInput);
      expect(size, Size(988, 466));
    });

    test('Test getSizeAsync with webp extended format', () async {
      final file = File('../../example/asset/demo_extended.webp');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final size = await ImageSizeGetter.getSizeAsync(asyncInput);
      expect(size, Size(988, 466));
    });

    test('Test getSizeAsync with webp lossless format', () async {
      final file = File('../../example/asset/demo_lossless.webp');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final size = await ImageSizeGetter.getSizeAsync(asyncInput);
      expect(size, Size(988, 466));
    });

    test('Test getSizeAsync with bmp', () async {
      final file = File('../../example/asset/demo.bmp');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final size = await ImageSizeGetter.getSizeAsync(asyncInput);
      expect(size, Size(256, 256));
    });

    test('Test getSizeAsync with orientation jpeg', () async {
      final file = File('../../example/asset/have_orientation_exif_3.jpg');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final size = await ImageSizeGetter.getSizeAsync(asyncInput);
      expect(size, Size(533, 799));

      final file2 = File('../../example/asset/have_orientation_exif_6.jpg');
      final input2 = FileInput(file2);
      final asyncInput2 = AsyncImageInput.input(input2);
      
      final size2 = await ImageSizeGetter.getSizeAsync(asyncInput2);
      expect(size2, Size(3264, 2448, needRotate: true));
    });

    test('Test getSizeResultAsync with gif', () async {
      final file = File('../../example/asset/dialog.gif');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final result = await ImageSizeGetter.getSizeResultAsync(asyncInput);
      expect(result.size, Size(688, 1326));
      expect(result.decoder.decoderName, 'gif');
    });

    test('Test getSizeResultAsync with jpeg', () async {
      final file = File('../../example/asset/IMG_20180908_080245.jpg');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final result = await ImageSizeGetter.getSizeResultAsync(asyncInput);
      expect(result.size, Size(4032, 3024));
      expect(result.decoder.decoderName, 'jpeg');
    });

    test('Test getSizeResultAsync with png', () async {
      final file = File('../../example/asset/ic_launcher.png');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final result = await ImageSizeGetter.getSizeResultAsync(asyncInput);
      expect(result.size, Size(96, 96));
      expect(result.decoder.decoderName, 'png');
    });

    test('Test getSizeResultAsync with webp', () async {
      final file = File('../../example/asset/demo.webp');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final result = await ImageSizeGetter.getSizeResultAsync(asyncInput);
      expect(result.size, Size(988, 466));
      expect(result.decoder.decoderName, 'webp');
    });

    test('Test getSizeResultAsync with bmp', () async {
      final file = File('../../example/asset/demo.bmp');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      final result = await ImageSizeGetter.getSizeResultAsync(asyncInput);
      expect(result.size, Size(256, 256));
      expect(result.decoder.decoderName, 'bmp');
    });

    test('Test getSizeAsync with non-existent file', () async {
      final file = File('../../example/asset/non_existent.jpg');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      expect(
        () async => await ImageSizeGetter.getSizeAsync(asyncInput),
        throwsA(isA<StateError>()),
      );
    });

    test('Test getSizeResultAsync with non-existent file', () async {
      final file = File('../../example/asset/non_existent.jpg');
      final input = FileInput(file);
      final asyncInput = AsyncImageInput.input(input);
      
      expect(
        () async => await ImageSizeGetter.getSizeResultAsync(asyncInput),
        throwsA(isA<StateError>()),
      );
    });

    test('Test getSizeAsync with unsupported format', () async {
      // Create a temporary file with unsupported content
      final tempFile = File('../../example/asset/temp_unsupported.txt');
      await tempFile.writeAsString('This is not an image file');
      
      try {
        final input = FileInput(tempFile);
        final asyncInput = AsyncImageInput.input(input);
        
        expect(
          () async => await ImageSizeGetter.getSizeAsync(asyncInput),
          throwsA(isA<UnsupportedError>()),
        );
      } finally {
        // Clean up
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    });

    test('Test getSizeResultAsync with unsupported format', () async {
      // Create a temporary file with unsupported content
      final tempFile = File('../../example/asset/temp_unsupported2.txt');
      await tempFile.writeAsString('This is not an image file');
      
      try {
        final input = FileInput(tempFile);
        final asyncInput = AsyncImageInput.input(input);
        
        expect(
          () async => await ImageSizeGetter.getSizeResultAsync(asyncInput),
          throwsA(isA<UnsupportedError>()),
        );
      } finally {
        // Clean up
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    });

    test('Test getSizeAsync with memory input via AsyncImageInput', () async {
      final file = File('../../example/asset/ic_launcher.png');
      final bytes = await file.readAsBytes();
      final memoryInput = MemoryInput(bytes);
      final asyncInput = AsyncImageInput.input(memoryInput);
      
      final size = await ImageSizeGetter.getSizeAsync(asyncInput);
      expect(size, Size(96, 96));
    });

    test('Test getSizeResultAsync with memory input via AsyncImageInput', () async {
      final file = File('../../example/asset/ic_launcher.png');
      final bytes = await file.readAsBytes();
      final memoryInput = MemoryInput(bytes);
      final asyncInput = AsyncImageInput.input(memoryInput);
      
      final result = await ImageSizeGetter.getSizeResultAsync(asyncInput);
      expect(result.size, Size(96, 96));
      expect(result.decoder.decoderName, 'png');
    });
  });
}

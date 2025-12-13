import 'dart:io';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:test/test.dart';

void main() {
  group('Test non-standard GIF (without 0x3B ending)', () {
    test('Test GIF without 0x3B trailer', () {
      final gif = File('../../example/asset/non_standard_ending.gif');
      
      const GifDecoder decoder = GifDecoder();
      final input = FileInput(gif);
      
      // The file should still be valid even without 0x3B ending
      expect(decoder.isValid(input), isTrue, 
        reason: 'GIF should be valid even without 0x3B trailer');
      
      // Size should still be readable
      expect(decoder.getSize(input), Size(200, 150));
    });
    
    test('Test standard GIF with 0x3B trailer for comparison', () {
      final gif = File('../../example/asset/87a.gif');
      
      const GifDecoder decoder = GifDecoder();
      final input = FileInput(gif);
      
      expect(decoder.isValid(input), isTrue);
      expect(decoder.getSize(input), Size(200, 150));
    });
    
    test('Test GIF89a format with and without trailer', () {
      final gif89a = File('../../example/asset/dialog.gif');
      
      const GifDecoder decoder = GifDecoder();
      final input = FileInput(gif89a);
      
      // Standard GIF89a should still work
      expect(decoder.isValid(input), isTrue);
      expect(decoder.getSize(input), Size(688, 1326));
    });
    
    test('Test that invalid headers are still rejected', () {
      // Create a file with invalid header in a temporary directory
      final tempDir = Directory.systemTemp.createTempSync('gif_test_');
      final tempFile = File('${tempDir.path}/temp_invalid.gif');
      
      try {
        tempFile.writeAsBytesSync([0x47, 0x49, 0x46, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        
        const GifDecoder decoder = GifDecoder();
        final input = FileInput(tempFile);
        
        // Invalid GIF header should be rejected
        expect(decoder.isValid(input), isFalse, 
          reason: 'File with invalid GIF header should be rejected');
      } finally {
        // Clean up temp directory and all its contents
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
    });
  });
}

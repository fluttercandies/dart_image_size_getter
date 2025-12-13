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
  });
}

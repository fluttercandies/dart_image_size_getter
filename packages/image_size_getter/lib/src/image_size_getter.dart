import 'dart:collection';

import 'package:image_size_getter/image_size_getter.dart';

export 'core/input.dart';

/// {@template image_size_getter._DecoderContainer}
///
/// [_DecoderContainer] is a container for [BaseDecoder]s.
///
/// {@endtemplate}
class _DecoderContainer extends IterableBase<BaseDecoder> {
  /// {@macro image_size_getter._DecoderContainer}
  _DecoderContainer(List<BaseDecoder> decoders) {
    for (final decoder in decoders) {
      _decoders[decoder.decoderName] = decoder;
    }
  }

  /// The [BaseDecoder]s.
  final Map<String, BaseDecoder> _decoders = {};

  /// {@template image_size_getter._DecoderContainer.register}
  ///
  /// Registers a [BaseDecoder] to the container.
  ///
  /// If the [BaseDecoder] is already registered, it will be replaced.
  ///
  /// {@endtemplate}
  void registerDecoder(BaseDecoder decoder) {
    _decoders[decoder.decoderName] = decoder;
  }

  @override
  Iterator<BaseDecoder> get iterator => _decoders.values.iterator;
}

/// The instance of [_DecoderContainer].
///
/// This instance is used to register [BaseDecoder]s, it will be used by [ImageSizeGetter].
final _decoders = _DecoderContainer([
  const GifDecoder(),
  const JpegDecoder(),
  const JpegDecoder(isStandardJpeg: false),
  const WebpDecoder(),
  const PngDecoder(),
  const BmpDecoder(),
  const TiffDecoder(),
]);

/// {@template image_size_getter.ImageSizeGetter}
///
/// The main class of [ImageSizeGetter].
///
/// Simple example:
///
/// ```dart
/// import 'dart:io';
///
/// import 'package:image_size_getter/image_size_getter.dart';
/// import 'package:image_size_getter/file_input.dart'; // For compatibility with flutter web.
///
/// void main(List<String> arguments) async {
///   final file = File('asset/IMG_20180908_080245.jpg');
///   final size = ImageSizeGetter.getSize(FileInput(file));
///   print('jpg size: $size');
/// }
/// ```
///
/// {@endtemplate}
class ImageSizeGetter {
  /// {@macro image_size_getter._DecoderContainer.register}
  static void registerDecoder(BaseDecoder decoder) {
    _decoders.registerDecoder(decoder);
  }

  /// Returns the [input] is png format or not.
  ///
  /// See also: [PngDecoder.isValid] or [PngDecoder.isValidAsync].
  static bool isPng(ImageInput input) {
    return PngDecoder().isValid(input);
  }

  /// Returns the [input] is webp format or not.
  ///
  /// See also: [WebpDecoder.isValid] or [WebpDecoder.isValidAsync].
  static bool isWebp(ImageInput input) {
    return WebpDecoder().isValid(input);
  }

  /// Returns the [input] is gif format or not.
  ///
  /// See also: [GifDecoder.isValid] or [GifDecoder.isValidAsync].
  static bool isGif(ImageInput input) {
    return GifDecoder().isValid(input);
  }

  /// Returns the [input] is jpeg format or not.
  ///
  /// See also: [JpegDecoder.isValid] or [JpegDecoder.isValidAsync].
  static bool isJpg(ImageInput input) {
    return JpegDecoder().isValid(input);
  }

  /// Returns the [input] is tiff format or not.
  ///
  /// See also: [TiffDecoder.isValid] or [TiffDecoder.isValidAsync].
  static bool isTiff(ImageInput input) {
    return TiffDecoder().isValid(input);
  }

  /// {@template image_size_getter.getSize}
  ///
  /// Get the size of the [input].
  ///
  /// If the [input] not exists, it will throw [StateError].
  ///
  /// If the [input] is not a valid image format, it will throw [UnsupportedError].
  ///
  /// {@endtemplate}
  @Deprecated(
      'Use getSizeResult instead. This method will be removed in the next major version.')
  static Size getSize(ImageInput input) {
    if (!input.exists()) {
      throw StateError('The input is not exists.');
    }

    for (var value in _decoders) {
      if (value.isValid(input)) {
        return value.getSize(input);
      }
    }

    throw UnsupportedError('The input is not supported.');
  }

  /// {@macro image_size_getter.getSize}
  ///
  /// The method is async.
  @Deprecated(
      'Use getSizeResultAsync instead. This method will be removed in the next major version.')
  static Future<Size> getSizeAsync(AsyncImageInput input) async {
    if (!await input.exists()) {
      throw StateError('The input is not exists.');
    }

    if (!(await input.supportRangeLoad())) {
      final delegateInput = await input.delegateInput();
      try {
        return ImageSizeGetter.getSize(delegateInput);
      } finally {
        delegateInput.release();
      }
    }

    for (var value in _decoders) {
      if (await value.isValidAsync(input)) {
        return value.getSizeAsync(input);
      }
    }

    throw UnsupportedError('The input is not supported.');
  }

  /// {@template image_size_getter.getSizeResult}
  /// Get the size of the [input] and the [BaseDecoder] that decodes the [input].
  /// {@endtemplate}
  static SizeResult getSizeResult(ImageInput input) {
    if (!input.exists()) {
      throw StateError('The input is not exists.');
    }

    for (var value in _decoders) {
      if (value.isValid(input)) {
        return SizeResult(size: value.getSize(input), decoder: value);
      }
    }

    throw UnsupportedError('The input is not supported.');
  }

  /// {@macro image_size_getter.getSizeResult}
  ///
  /// The method is async version for [getSizeResult].
  static Future<SizeResult> getSizeResultAsync(AsyncImageInput input) async {
    if (!await input.exists()) {
      throw StateError('The input is not exists.');
    }

    if (!(await input.supportRangeLoad())) {
      final delegateInput = await input.delegateInput();
      try {
        return ImageSizeGetter.getSizeResult(delegateInput);
      } finally {
        delegateInput.release();
      }
    }

    for (var value in _decoders) {
      if (await value.isValidAsync(input)) {
        return SizeResult(
          size: await value.getSizeAsync(input),
          decoder: value,
        );
      }
    }

    throw UnsupportedError('The input is not supported.');
  }
}

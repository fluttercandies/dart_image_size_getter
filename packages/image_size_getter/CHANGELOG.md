# CHANGELOG

- [CHANGELOG](#changelog)
  - [2.4.1](#241)
  - [2.4.0](#240)
  - [2.3.0+1](#2301)
  - [2.3.0](#230)
  - [2.2.0](#220)
  - [2.1.3](#213)
  - [2.1.2](#212)
  - [2.1.1](#211)
  - [2.1.0](#210)
  - [2.0.0](#200)
  - [1.1.0](#110)
  - [1.0.0](#100)
  - [0.3.0](#030)
  - [0.2.1](#021)
  - [0.2.0](#020)
  - [0.1.1](#011)
  - [0.1.0](#010)

## 2.4.1

- Fix: Corrected orientation retrieval in JPEG images.

## 2.4.0

- Add `isExtensionSupported` to `BaseDecoder`

## 2.3.0+1

- Docs: Add docs for dartdoc.

## 2.3.0

Feature:

- Add `getSizeResult` for `SizeResult`

## 2.2.0

Feature:

- Add non-standard jpeg decoder

## 2.1.3

Fix:

- Support lossless WebP ([#38](https://github.com/CaiJingLong/dart_image_size_getter/issues/38))

## 2.1.2

Fix：

- Support gif 87a type [#23] [#24].

## 2.1.1

- fix: remove debug value print calls from `jpeg_decoder` by @ZaLiTHkA in <https://github.com/CaiJingLong/dart_image_size_getter/pull/21>
- @ZaLiTHkA made their first contribution in <https://github.com/CaiJingLong/dart_image_size_getter/pull/21>

**Full Changelog**: <https://github.com/CaiJingLong/dart_image_size_getter/compare/library-2.1.0...library-2.1.1>

## 2.1.0

Feature:

- Add `needRotate` for `Size`

**What's Changed:** - Add needRotate for Size by @CaiJingLong in <https://github.com/CaiJingLong/dart_image_size_getter/pull/20>

**Full Changelog**: <https://github.com/CaiJingLong/dart_image_size_getter/compare/http_input-2.0.0...library-2.1.0>

## 2.0.0

New feature:

- Refactored the code and removed the `AsyncImageSizeGetter` class.
- We can customize the decoder.

## 1.1.0

- Support webp extended format by @nkming2 in <https://github.com/CaiJingLong/dart_image_size_getter/pull/11>
- Http input by @CaiJingLong in <https://github.com/CaiJingLong/dart_image_size_getter/pull/14>

**New Contributors:** - @nkming2 made their first contribution in <https://github.com/CaiJingLong/dart_image_size_getter/pull/11>

**Full Changelog:** <https://github.com/CaiJingLong/dart_image_size_getter/compare/1.0.0...1.1.0>

## 1.0.0

Null safety version.

## 0.3.0

Support get size of async input of image.

## 0.2.1

Update dependency.
Fix readme.

## 0.2.0

Support memory type.

Breaking change:
Fix: type of `ImageSizeGetter`

## 0.1.1

FIx jpeg format.

## 0.1.0

Initial version.

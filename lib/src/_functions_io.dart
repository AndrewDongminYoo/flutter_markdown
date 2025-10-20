// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// 🎯 Dart imports:
import 'dart:io' as io;

// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart' show CupertinoTheme;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';

// 🌎 Project imports:
import 'package:flutter_markdown/src/style_sheet.dart';
import 'package:flutter_markdown/src/widget.dart';

/// Type for a function that creates image widgets.
typedef ImageBuilder = Widget Function(
  Uri uri,
  String? imageDirectory,
  double? width,
  double? height,
);

/// A default image builder handling http/https, resource, and file URLs.
Widget kDefaultImageBuilder(
  Uri uri,
  String? imageDirectory,
  double? width,
  double? height,
) {
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    return Image.network(
      uri.toString(),
      width: width,
      height: height,
      errorBuilder: kDefaultImageErrorWidgetBuilder,
    );
  } else if (uri.scheme == 'data') {
    return _handleDataSchemeUri(uri, width, height);
  } else if (uri.scheme == 'resource') {
    return Image.asset(
      uri.path,
      width: width,
      height: height,
      errorBuilder: kDefaultImageErrorWidgetBuilder,
    );
  } else {
    final fileUri = imageDirectory != null ? Uri.parse(imageDirectory + uri.toString()) : uri;
    if (fileUri.scheme == 'http' || fileUri.scheme == 'https') {
      return Image.network(
        fileUri.toString(),
        width: width,
        height: height,
        errorBuilder: kDefaultImageErrorWidgetBuilder,
      );
    } else {
      try {
        return Image.file(
          io.File.fromUri(fileUri),
          width: width,
          height: height,
          errorBuilder: kDefaultImageErrorWidgetBuilder,
        );
      } on Object catch (error, stackTrace) {
        // Handle any invalid file URI's.
        return Builder(
          builder: (BuildContext context) {
            return kDefaultImageErrorWidgetBuilder(context, error, stackTrace);
          },
        );
      }
    }
  }
}

/// A default error widget builder for handling image errors.
Widget kDefaultImageErrorWidgetBuilder(BuildContext context, Object error, StackTrace? stackTrace) => const SizedBox();

/// A default style sheet generator.
typedef MarkdownStyleSheetBuilder = MarkdownStyleSheet Function(BuildContext, MarkdownStyleSheetBaseTheme?);

/// A default style sheet generator.
MarkdownStyleSheet kFallbackStyle(
  BuildContext context,
  MarkdownStyleSheetBaseTheme? baseTheme,
) {
  final cupertino = MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context));
  final material = MarkdownStyleSheet.fromTheme(Theme.of(context));
  final textScaler = MediaQuery.textScalerOf(context);
  return switch (baseTheme) {
    // coverage:ignore-start
    // This is a workaround for the fact that the platform theme is not available in the constructor of MarkdownStyleSheet.
    MarkdownStyleSheetBaseTheme.platform => switch (defaultTargetPlatform) {
        TargetPlatform.iOS || TargetPlatform.macOS => cupertino.copyWith(textScaler: textScaler),
        _ => material.copyWith(textScaler: textScaler)
      },
    // coverage:ignore-end
    MarkdownStyleSheetBaseTheme.cupertino => cupertino.copyWith(textScaler: textScaler),
    _ => material.copyWith(textScaler: textScaler)
  };
}

Widget _handleDataSchemeUri(Uri uri, double? width, double? height) {
  final mimeType = uri.data!.mimeType;
  if (mimeType.startsWith('image/')) {
    return Image.memory(
      uri.data!.contentAsBytes(),
      width: width,
      height: height,
      errorBuilder: kDefaultImageErrorWidgetBuilder,
    );
  } else if (mimeType.startsWith('text/')) {
    return Text(uri.data!.contentAsString());
  }
  return const SizedBox();
}

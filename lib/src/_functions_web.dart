// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;

/// Type for a function that creates image widgets.
typedef ImageBuilder = Widget Function(
  Uri uri,
  String? imageDirectory,
  double? width,
  double? height,
);

/// A default image builder handling http/https, resource, data, and file URLs.
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
    final Uri fileUri;

    if (imageDirectory != null) {
      try {
        fileUri = Uri.parse(p.join(imageDirectory, uri.toString()));
      } on Exception catch (error, stackTrace) {
        // Handle any invalid file URI's.
        return Builder(
          builder: (BuildContext context) {
            return kDefaultImageErrorWidgetBuilder(context, error, stackTrace);
          },
        );
      }
    } else {
      fileUri = uri;
    }

    if (fileUri.scheme == 'http' || fileUri.scheme == 'https') {
      return Image.network(
        fileUri.toString(),
        width: width,
        height: height,
        errorBuilder: kDefaultImageErrorWidgetBuilder,
      );
    } else {
      final src = p.join(p.current, fileUri.toString());
      return Image.network(
        src,
        width: width,
        height: height,
        errorBuilder: kDefaultImageErrorWidgetBuilder,
      );
    }
  }
}

/// A default error widget builder for handling image errors.
Widget kDefaultImageErrorWidgetBuilder(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
) =>
    const SizedBox();

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

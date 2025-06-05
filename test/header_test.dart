// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// 🐦 Flutter imports:
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'helpers/utils.dart';

void main() => defineTests();

void defineTests() {
  group('Header', () {
    testWidgets(
      'level one',
      (WidgetTester tester) async {
        const data = '# Header';
        await tester.pumpWidget(boilerplate(const MarkdownBody(data: data)));

        final widgets = selfAndDescendantWidgetsOf(
          find.byType(MarkdownBody),
          tester,
        );
        expectWidgetTypes(widgets, <Type>[
          MarkdownBody,
          Column,
          Wrap,
          Text,
          RichText,
        ]);
        expectTextStrings(widgets, <String>['Header']);
      },
    );
  });
}

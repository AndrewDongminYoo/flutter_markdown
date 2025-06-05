// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/utils.dart';

void main() => defineTests();

void defineTests() {
  group('Text Alignment', () {
    testWidgets(
      'apply text alignments from stylesheet',
      (WidgetTester tester) async {
        final theme = ThemeData.light().copyWith(textTheme: textTheme);
        final style1 = MarkdownStyleSheet.fromTheme(theme).copyWith(
          h1Align: WrapAlignment.center,
          h3Align: WrapAlignment.end,
        );

        const data = '# h1\n ## h2';
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              styleSheet: style1,
            ),
          ),
        );

        final widgets = selfAndDescendantWidgetsOf(
          find.byType(MarkdownBody),
          tester,
        );
        expectWidgetTypes(widgets, <Type>[
          MarkdownBody,
          Column,
          Column,
          Wrap,
          Text,
          RichText,
          SizedBox,
          Column,
          Wrap,
          Text,
          RichText,
        ]);

        expect(
          (widgets.firstWhere((Widget w) => w is RichText) as RichText).textAlign,
          TextAlign.center,
        );
        expect(
          (widgets.last as RichText).textAlign,
          TextAlign.start,
          reason: 'default alignment if none is set in stylesheet',
        );
      },
    );

    testWidgets(
      'should align formatted text',
      (WidgetTester tester) async {
        final theme = ThemeData.light().copyWith(textTheme: textTheme);
        final style = MarkdownStyleSheet.fromTheme(theme).copyWith(
          textAlign: WrapAlignment.spaceBetween,
        );

        const data = 'hello __my formatted text__';
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              styleSheet: style,
            ),
          ),
        );

        final text = tester.widgetList(find.byType(RichText)).single as RichText;
        expect(text.textAlign, TextAlign.justify);
      },
    );

    testWidgets(
      'should align selectable text',
      (WidgetTester tester) async {
        final theme = ThemeData.light().copyWith(textTheme: textTheme);
        final style = MarkdownStyleSheet.fromTheme(theme).copyWith(
          textAlign: WrapAlignment.spaceBetween,
        );

        const data = 'hello __my formatted text__';
        await tester.pumpWidget(
          boilerplate(
            MediaQuery(
              data: const MediaQueryData(),
              child: MarkdownBody(
                data: data,
                styleSheet: style,
                selectable: true,
              ),
            ),
          ),
        );

        final text = tester.widgetList(find.byType(SelectableText)).single as SelectableText;
        expect(text.textAlign, TextAlign.justify);
      },
    );
  });
}

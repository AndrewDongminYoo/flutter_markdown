// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:flutter_markdown/flutter_markdown.dart';
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
        final style = MarkdownStyleSheet.fromTheme(theme).copyWith(textAlign: WrapAlignment.spaceBetween);

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
        final style = MarkdownStyleSheet.fromTheme(theme).copyWith(textAlign: WrapAlignment.spaceBetween);

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

    testWidgets(
      'should apply spaceEvenly alignment to text',
      (WidgetTester tester) async {
        final theme = ThemeData.light().copyWith(textTheme: textTheme);
        final style = MarkdownStyleSheet.fromTheme(theme).copyWith(textAlign: WrapAlignment.spaceEvenly);

        const data = 'hello world this is a test';
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
      'should apply spaceEvenly alignment to headers',
      (WidgetTester tester) async {
        final theme = ThemeData.light().copyWith(textTheme: textTheme);
        final style = MarkdownStyleSheet.fromTheme(theme).copyWith(
          h1Align: WrapAlignment.spaceEvenly,
          h2Align: WrapAlignment.spaceEvenly,
        );

        const data = '# Header One\n## Header Two';
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              styleSheet: style,
            ),
          ),
        );

        final widgets = selfAndDescendantWidgetsOf(
          find.byType(MarkdownBody),
          tester,
        );

        final richTextWidgets = widgets.whereType<RichText>().toList();
        expect(richTextWidgets.length, 2);

        // 첫 번째 RichText (h1)는 spaceEvenly 정렬이 적용되어 justify로 변환됨
        expect(richTextWidgets[0].textAlign, TextAlign.justify);

        // 두 번째 RichText (h2)도 spaceEvenly 정렬이 적용되어 justify로 변환됨
        expect(richTextWidgets[1].textAlign, TextAlign.justify);
      },
    );

    testWidgets(
      'should apply spaceEvenly alignment to selectable headers',
      (WidgetTester tester) async {
        final theme = ThemeData.light().copyWith(textTheme: textTheme);
        final style = MarkdownStyleSheet.fromTheme(theme).copyWith(h1Align: WrapAlignment.spaceEvenly);

        const data = '# Selectable Header with SpaceEvenly';
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

        final selectableText = tester.widgetList(find.byType(SelectableText)).single as SelectableText;
        expect(selectableText.textAlign, TextAlign.justify);
      },
    );
  });
}

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
  group('Hard Line Breaks', () {
    testWidgets(
      // Example 654 from GFM.
      'two spaces at end of line',
      (WidgetTester tester) async {
        const data = 'foo  \nbar';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\nbar');
      },
    );

    testWidgets(
      // Example 655 from GFM.
      'backslash at end of line',
      (WidgetTester tester) async {
        const data = 'foo\\\nbar';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\nbar');
      },
    );

    testWidgets(
      // Example 656 from GFM.
      'more than two spaces at end of line',
      (WidgetTester tester) async {
        const data = 'foo       \nbar';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\nbar');
      },
    );

    testWidgets(
      // Example 657 from GFM.
      'leading spaces at beginning of next line are ignored',
      (WidgetTester tester) async {
        const data = 'foo  \n     bar';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\nbar');
      },
    );

    testWidgets(
      // Example 658 from GFM.
      'leading spaces at beginning of next line are ignored',
      (WidgetTester tester) async {
        const data = 'foo\\\n     bar';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\nbar');
      },
    );

    testWidgets(
      // Example 659 from GFM.
      'two spaces line break inside emphasis',
      (WidgetTester tester) async {
        const data = '*foo  \nbar*';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final textFinder = find.byType(Text);
        expect(textFinder, findsOneWidget);

        final textWidget = textFinder.evaluate().first.widget as Text;
        final text = textWidget.textSpan!.toPlainText();
        expect(text, 'foo\nbar');

        // There should be three spans of text.
        final textSpan = textWidget.textSpan! as TextSpan;
        expect(textSpan, isNotNull);
        expect(textSpan.children!.length == 3, isTrue);

        // First text span has italic style with normal weight.
        final firstSpan = textSpan.children![0];
        expectTextSpanStyle(
          firstSpan as TextSpan,
          FontStyle.italic,
          FontWeight.normal,
        );

        // Second span is just the newline character with no font style or weight.

        // Third text span has italic style with normal weight.
        final thirdSpan = textSpan.children![2];
        expectTextSpanStyle(
          thirdSpan as TextSpan,
          FontStyle.italic,
          FontWeight.normal,
        );
      },
    );

    testWidgets(
      // Example 660 from GFM.
      'backslash line break inside emphasis',
      (WidgetTester tester) async {
        const data = '*foo\\\nbar*';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final textFinder = find.byType(Text);
        expect(textFinder, findsOneWidget);

        final textWidget = textFinder.evaluate().first.widget as Text;
        final text = textWidget.textSpan!.toPlainText();
        expect(text, 'foo\nbar');

        // There should be three spans of text.
        final textSpan = textWidget.textSpan! as TextSpan;
        expect(textSpan, isNotNull);
        expect(textSpan.children!.length == 3, isTrue);

        // First text span has italic style with normal weight.
        final firstSpan = textSpan.children![0];
        expectTextSpanStyle(
          firstSpan as TextSpan,
          FontStyle.italic,
          FontWeight.normal,
        );

        // Second span is just the newline character with no font style or weight.

        // Third text span has italic style with normal weight.
        final thirdSpan = textSpan.children![2];
        expectTextSpanStyle(
          thirdSpan as TextSpan,
          FontStyle.italic,
          FontWeight.normal,
        );
      },
    );

    testWidgets(
      // Example 661 from GFM.
      'two space line break does not occur in code span',
      (WidgetTester tester) async {
        const data = '`code  \nspan`';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final textFinder = find.byType(Text);
        expect(textFinder, findsOneWidget);

        final textWidget = textFinder.evaluate().first.widget as Text;
        final text = textWidget.textSpan!.toPlainText();
        expect(text, 'code   span');

        final textSpan = textWidget.textSpan! as TextSpan;
        expect(textSpan, isNotNull);
        expect(textSpan.style, isNotNull);
        expect(textSpan.style!.fontFamily == 'monospace', isTrue);
      },
    );

    testWidgets(
      // Example 662 from GFM.
      'backslash line break does not occur in code span',
      (WidgetTester tester) async {
        const data = '`code\\\nspan`';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final textFinder = find.byType(Text);
        expect(textFinder, findsOneWidget);

        final textWidget = textFinder.evaluate().first.widget as Text;
        final text = textWidget.textSpan!.toPlainText();
        expect(text, r'code\ span');

        final textSpan = textWidget.textSpan! as TextSpan;
        expect(textSpan, isNotNull);
        expect(textSpan.style, isNotNull);
        expect(textSpan.style!.fontFamily == 'monospace', isTrue);
      },
    );

    testWidgets(
      // Example 665 from GFM.
      'backslash at end of paragraph is ignored',
      (WidgetTester tester) async {
        const data = r'foo\';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, r'foo\');
      },
    );

    testWidgets(
      // Example 666 from GFM.
      'two spaces at end of paragraph is ignored',
      (WidgetTester tester) async {
        const data = 'foo  ';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo');
      },
    );

    testWidgets(
      // Example 667 from GFM.
      'backslash at end of header is ignored',
      (WidgetTester tester) async {
        const data = r'### foo\';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, r'foo\');
      },
    );

    testWidgets(
      // Example 668 from GFM.
      'two spaces at end of header is ignored',
      (WidgetTester tester) async {
        const data = '### foo  ';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo');
      },
    );
  });

  group('Soft Line Breaks', () {
    testWidgets(
      // Example 669 from GFM.
      'lines of text in paragraph',
      (WidgetTester tester) async {
        const data = 'foo\nbaz';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo baz');
      },
    );

    testWidgets(
      // Example 670 from GFM.
      'spaces at beginning and end of lines of text in paragraph are removed',
      (WidgetTester tester) async {
        const data = 'foo \n baz';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo baz');
      },
    );
  });
}

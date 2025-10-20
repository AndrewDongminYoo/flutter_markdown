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
  group('Blockquote', () {
    testWidgets(
      'simple one word blockquote',
      (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(const MarkdownBody(data: '> quote')));

        final widgets = tester.allWidgets;
        expectTextStrings(widgets, <String>['quote']);
      },
    );

    testWidgets(
      'soft wrapping in blockquote',
      (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(const MarkdownBody(data: '> soft\n> wrap')));

        final widgets = tester.allWidgets;
        expectTextStrings(widgets, <String>['soft wrap']);
      },
    );

    testWidgets(
      'should work with styling',
      (WidgetTester tester) async {
        final theme = ThemeData.light().copyWith(textTheme: textTheme);
        final styleSheet = MarkdownStyleSheet.fromTheme(theme);

        const data = '''
> this is a link: [Markdown guide](https://www.markdownguide.org) and this is **bold** and *italic*''';
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              styleSheet: styleSheet,
            ),
          ),
        );

        final widgets = tester.allWidgets;
        final blockQuoteContainer = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
        final quoteText = tester.widget<Text>(find.byType(Text));
        final styledTextParts = (quoteText.textSpan! as TextSpan).children!.cast<TextSpan>();

        expectTextStrings(
          widgets,
          <String>[
            'this is a link: Markdown guide and this is bold and italic',
          ],
        );
        expect(
          (blockQuoteContainer.decoration as BoxDecoration).color,
          (styleSheet.blockquoteDecoration as BoxDecoration?)!.color,
        );
        expect(
          (blockQuoteContainer.decoration as BoxDecoration).borderRadius,
          (styleSheet.blockquoteDecoration as BoxDecoration?)!.borderRadius,
        );

        /// this is a link
        expect(styledTextParts[0].text, 'this is a link: ');
        expect(
          styledTextParts[0].style!.color,
          theme.textTheme.bodyMedium!.color,
        );

        /// Markdown guide
        expect(styledTextParts[1].text, 'Markdown guide');
        expect(styledTextParts[1].style!.color, Colors.blue);

        /// and this is
        expect(styledTextParts[2].text, ' and this is ');
        expect(
          styledTextParts[2].style!.color,
          theme.textTheme.bodyMedium!.color,
        );

        /// bold
        expect(styledTextParts[3].text, 'bold');
        expect(styledTextParts[3].style!.fontWeight, FontWeight.bold);

        /// and
        expect(styledTextParts[4].text, ' and ');
        expect(
          styledTextParts[4].style!.color,
          theme.textTheme.bodyMedium!.color,
        );

        /// italic
        expect(styledTextParts[5].text, 'italic');
        expect(styledTextParts[5].style!.fontStyle, FontStyle.italic);
      },
    );
  });
}

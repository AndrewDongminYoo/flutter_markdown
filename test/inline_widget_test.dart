// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

// 🌎 Project imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'helpers/utils.dart';

void main() => defineTests();

void defineTests() {
  group('InlineWidget', () {
    testWidgets(
      'Test inline widget',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: 'Hello, foo bar',
              builders: <String, MarkdownElementBuilder>{
                'sub': SubscriptBuilder(),
              },
              extensionSet: md.ExtensionSet(
                <md.BlockSyntax>[],
                <md.InlineSyntax>[SubscriptSyntax()],
              ),
            ),
          ),
        );

        final textWidget = tester.firstWidget<Text>(find.byType(Text));
        final span = textWidget.textSpan! as TextSpan;

        final part1 = span.children![0] as TextSpan;
        expect(part1.toPlainText(), 'Hello, ');

        final part2 = span.children![1] as WidgetSpan;
        expect(part2.alignment, PlaceholderAlignment.middle);
        expect(part2.child, isA<Text>());
        expect((part2.child as Text).data, 'foo');

        final part3 = span.children![2] as TextSpan;
        expect(part3.toPlainText(), ' bar');
      },
    );
  });
}

class SubscriptBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return Text.rich(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Text(element.textContent),
      ),
    );
  }
}

class SubscriptSyntax extends md.InlineSyntax {
  SubscriptSyntax() : super(_pattern);

  static const String _pattern = '(foo)';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('sub', match[1]!));
    return true;
  }
}

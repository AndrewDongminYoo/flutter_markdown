// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Custom Syntax', () {
    testWidgets(
      'Custom block element',
      (WidgetTester tester) async {
        const blockContent = 'note block';
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: '[!NOTE] $blockContent',
              extensionSet: md.ExtensionSet.none,
              blockSyntaxes: <md.BlockSyntax>[NoteSyntax()],
              builders: <String, MarkdownElementBuilder>{
                'note': NoteBuilder(),
              },
            ),
          ),
        );
        final container =
            tester.widgetList(find.byType(ColoredBox)).first as ColoredBox;
        expect(container.color, Colors.red);
        expect(container.child, isInstanceOf<Text>());
        expect((container.child! as Text).data, blockContent);
      },
    );

    testWidgets(
      'Block with custom tag',
      (WidgetTester tester) async {
        const textBefore = 'Before ';
        const textAfter = ' After';
        const blockContent = 'Custom content rendered in a ColoredBox';

        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data:
                  '$textBefore\n{{custom}}\n$blockContent\n{{/custom}}\n$textAfter',
              extensionSet: md.ExtensionSet.none,
              blockSyntaxes: <md.BlockSyntax>[CustomTagBlockSyntax()],
              builders: <String, MarkdownElementBuilder>{
                'custom': CustomTagBlockBuilder(),
              },
            ),
          ),
        );

        final container =
            tester.widgetList(find.byType(ColoredBox)).first as ColoredBox;
        expect(container.color, Colors.red);
        expect(container.child, isInstanceOf<Text>());
        expect((container.child! as Text).data, blockContent);
      },
    );

    testWidgets(
      'visitElementAfterWithContext is handled correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: r'# This is a header with some \color1{color} in it',
              extensionSet: md.ExtensionSet.none,
              inlineSyntaxes: <md.InlineSyntax>[InlineTextColorSyntax()],
              builders: <String, MarkdownElementBuilder>{
                'inlineTextColor': InlineTextColorElementBuilder(),
              },
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        final rootSpan = textWidget.textSpan! as TextSpan;
        final firstSpan = rootSpan.children![0] as TextSpan;
        final secondSpan = rootSpan.children![1] as TextSpan;
        final thirdSpan = rootSpan.children![2] as TextSpan;

        expect(secondSpan.style!.color, Colors.red);
        expect(secondSpan.style!.fontSize, firstSpan.style!.fontSize);
        expect(secondSpan.style!.fontSize, thirdSpan.style!.fontSize);
      },
    );
  });
}

class SubscriptSyntax extends md.InlineSyntax {
  SubscriptSyntax() : super(_pattern);

  static const String _pattern = '_([0-9]+)';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('sub', match[1]!));
    return true;
  }
}

class WikilinkSyntax extends md.InlineSyntax {
  WikilinkSyntax() : super(_pattern);

  static const String _pattern = r'\[\[(.*?)\]\]';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final link = match[1]!;
    final el =
        md.Element('wikilink', <md.Element>[md.Element.text('span', link)])
          ..attributes['href'] = link.replaceAll(' ', '_');

    parser.addNode(el);
    return true;
  }
}

class ContainerSyntax extends md.InlineSyntax {
  ContainerSyntax() : super(_pattern);

  static const String _pattern = 'container';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(
      md.Element.text('container', ''),
    );
    return true;
  }
}

// Note: The implementation of inline span is incomplete, it does not handle
// bold, italic, ... text with a colored block.
// This would not work: `\color1{Text with *bold* text}`
class InlineTextColorSyntax extends md.InlineSyntax {
  InlineTextColorSyntax() : super(r'\\color([1-9]){(.*?)}');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final colorId = match.group(1)!;
    final textContent = match.group(2)!;
    final node = md.Element.text(
      'inlineTextColor',
      textContent,
    )..attributes['color'] = colorId;

    parser
      ..addNode(node)
      ..addNode(md.Text(''));
    return true;
  }
}

class InlineTextColorElementBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final innerText = element.textContent;
    final color = element.attributes['color'] ?? '';

    final contentColors = <String, Color>{
      '1': Colors.red,
      '2': Colors.green,
      '3': Colors.blue,
    };
    final contentColor = contentColors[color];

    return Text.rich(
      TextSpan(
        text: innerText,
        style: parentStyle?.copyWith(color: contentColor),
      ),
    );
  }
}

class NoteBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    return ColoredBox(
      color: Colors.red,
      child: Text(text.text, style: preferredStyle),
    );
  }

  @override
  bool isBlockElement() {
    return true;
  }
}

class NoteSyntax extends md.BlockSyntax {
  @override
  md.Node? parse(md.BlockParser parser) {
    final line = parser.current;
    parser.advance();
    return md.Element('note', <md.Node>[md.Text(line.content.substring(8))]);
  }

  @override
  RegExp get pattern => RegExp(r'^\[!NOTE] ');
}

class CustomTagBlockBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    if (element.tag == 'custom') {
      final content = element.attributes['content']!;
      return ColoredBox(
        color: Colors.red,
        child: Text(content, style: preferredStyle),
      );
    }
    return const SizedBox.shrink();
  }
}

class CustomTagBlockSyntax extends md.BlockSyntax {
  @override
  bool canParse(md.BlockParser parser) {
    return parser.current.content.startsWith('{{custom}}');
  }

  @override
  RegExp get pattern => RegExp(r'\{\{custom\}\}([\s\S]*?)\{\{/custom\}\}');

  @override
  md.Node parse(md.BlockParser parser) {
    parser.advance();

    final buffer = StringBuffer();
    while (
        !parser.current.content.startsWith('{{/custom}}') && !parser.isDone) {
      buffer.writeln(parser.current.content);
      parser.advance();
    }

    if (!parser.isDone) {
      parser.advance();
    }

    final content = buffer.toString().trim();
    final element = md.Element.empty('custom');
    element.attributes['content'] = content;
    return element;
  }
}

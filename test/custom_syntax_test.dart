// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Custom Syntax', () {
    testWidgets(
      'Subscript',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: 'H_2O',
              extensionSet: md.ExtensionSet.none,
              inlineSyntaxes: <md.InlineSyntax>[SubscriptSyntax()],
              builders: <String, MarkdownElementBuilder>{
                'sub': SubscriptBuilder(),
              },
            ),
          ),
        );

        final widgets = tester.allWidgets;
        expectTextStrings(widgets, <String>['H₂O']);
      },
    );

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
        final container = tester.widgetList(find.byType(ColoredBox)).first as ColoredBox;
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
              data: '$textBefore\n{{custom}}\n$blockContent\n{{/custom}}\n$textAfter',
              extensionSet: md.ExtensionSet.none,
              blockSyntaxes: <md.BlockSyntax>[CustomTagBlockSyntax()],
              builders: <String, MarkdownElementBuilder>{
                'custom': CustomTagBlockBuilder(),
              },
            ),
          ),
        );

        final container = tester.widgetList(find.byType(ColoredBox)).first as ColoredBox;
        expect(container.color, Colors.red);
        expect(container.child, isInstanceOf<Text>());
        expect((container.child! as Text).data, blockContent);
      },
    );

    testWidgets(
      'link for wikistyle',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: 'This is a [[wiki link]]',
              extensionSet: md.ExtensionSet.none,
              inlineSyntaxes: <md.InlineSyntax>[WikilinkSyntax()],
              builders: <String, MarkdownElementBuilder>{
                'wikilink': WikilinkBuilder(),
              },
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        final span = (textWidget.textSpan! as TextSpan).children![1] as TextSpan;

        expect(span.children, null);
        expect(span.recognizer.runtimeType, equals(TapGestureRecognizer));
      },
    );

    testWidgets(
      'WidgetSpan in Text.rich is handled correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: 'container is a widget that allows to customize its child',
              extensionSet: md.ExtensionSet.none,
              inlineSyntaxes: <md.InlineSyntax>[ContainerSyntax()],
              builders: <String, MarkdownElementBuilder>{
                'container': ContainerBuilder(),
              },
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        final textSpan = textWidget.textSpan! as TextSpan;
        final widgetSpan = textSpan.children![0] as WidgetSpan;
        expect(widgetSpan.child, isInstanceOf<Container>());
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

  testWidgets(
    'TextSpan and WidgetSpan as children in Text.rich are handled correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        boilerplate(
          Markdown(
            data: 'this test replaces a string with a container',
            extensionSet: md.ExtensionSet.none,
            inlineSyntaxes: <md.InlineSyntax>[ContainerSyntax()],
            builders: <String, MarkdownElementBuilder>{
              'container': ContainerBuilder2(),
            },
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      final textSpan = textWidget.textSpan! as TextSpan;
      final start = textSpan.children![0] as TextSpan;
      expect(start.text, 'this test replaces a string with a ');
      final foo = textSpan.children![1] as TextSpan;
      expect(foo.text, 'foo');
      final widgetSpan = textSpan.children![2] as WidgetSpan;
      expect(widgetSpan.child, isInstanceOf<Container>());
    },
  );

  testWidgets(
    'Custom rendering of tags without children',
    (WidgetTester tester) async {
      const data = '![alt](/assets/images/logo.png)';
      await tester.pumpWidget(
        boilerplate(
          Markdown(
            data: data,
            builders: <String, MarkdownElementBuilder>{
              'img': ImgBuilder(),
            },
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsNothing);
      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, 'foo');
    },
  );
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

class SubscriptBuilder extends MarkdownElementBuilder {
  static const List<String> _subscripts = <String>[
    '₀',
    '₁',
    '₂',
    '₃',
    '₄',
    '₅',
    '₆',
    '₇',
    '₈',
    '₉',
  ];

  @override
  Widget visitElementAfter(md.Element element, _) {
    // We don't currently have a way to control the vertical alignment of text spans.
    // See https://github.com/flutter/flutter/issues/10906#issuecomment-385723664
    final textContent = element.textContent;
    final buffer = StringBuffer();
    for (var i = 0; i < textContent.length; i++) {
      buffer.write(_subscripts[int.parse(textContent[i])]);
    }
    return Text.rich(TextSpan(text: buffer.toString()));
  }
}

class WikilinkSyntax extends md.InlineSyntax {
  WikilinkSyntax() : super(_pattern);

  static const String _pattern = r'\[\[(.*?)\]\]';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final link = match[1]!;
    final el = md.Element('wikilink', <md.Element>[md.Element.text('span', link)])
      ..attributes['href'] = link.replaceAll(' ', '_');

    parser.addNode(el);
    return true;
  }
}

class WikilinkBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, _) {
    final recognizer = TapGestureRecognizer()..onTap = () {};
    addTearDown(recognizer.dispose);
    return Text.rich(
      TextSpan(text: element.textContent, recognizer: recognizer),
    );
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

class ContainerBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, _) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          WidgetSpan(
            child: Container(),
          ),
        ],
      ),
    );
  }
}

class ContainerBuilder2 extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, _) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          const TextSpan(text: 'foo'),
          WidgetSpan(
            child: Container(),
          ),
        ],
      ),
    );
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

class ImgBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Text('foo', style: preferredStyle);
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
    while (!parser.current.content.startsWith('{{/custom}}') && !parser.isDone) {
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

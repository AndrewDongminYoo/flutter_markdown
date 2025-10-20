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
  group('Scrollable', () {
    testWidgets(
      'code block',
      (WidgetTester tester) async {
        const data = "```\nvoid main() {\n  print('Hello World!');\n}\n```";

        await tester.pumpWidget(
          boilerplate(
            const MediaQuery(
              data: MediaQueryData(),
              child: MarkdownBody(data: data),
            ),
          ),
        );

        final widgets = tester.allWidgets;
        final scrollViews = widgets.whereType<SingleChildScrollView>();
        expect(scrollViews, isNotEmpty);
        expect(scrollViews.first.controller, isNotNull);
      },
    );

    testWidgets(
      'two code blocks use different scroll controllers',
      (WidgetTester tester) async {
        const data = "```\nvoid main() {\n  print('Hello World!');\n}\n```"
            '\n'
            "```\nvoid main() {\n  print('Hello World!');\n}\n```";

        await tester.pumpWidget(
          boilerplate(
            const MediaQuery(
              data: MediaQueryData(),
              child: MarkdownBody(data: data),
            ),
          ),
        );

        final widgets = tester.allWidgets;
        final scrollViews = widgets.whereType<SingleChildScrollView>();
        expect(scrollViews, hasLength(2));
        expect(scrollViews.first.controller, isNotNull);
        expect(scrollViews.last.controller, isNotNull);
        expect(
          scrollViews.first.controller,
          isNot(equals(scrollViews.last.controller)),
        );
      },
    );

    testWidgets(
      'controller',
      (WidgetTester tester) async {
        final controller = ScrollController(initialScrollOffset: 209);
        addTearDown(controller.dispose);

        await tester.pumpWidget(boilerplate(Markdown(controller: controller, data: '')));

        double realOffset() {
          return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
        }

        expect(controller.offset, equals(209.0));
        expect(realOffset(), equals(controller.offset));
      },
    );

    testWidgets(
      'Scrollable wrapping',
      (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(const Markdown(data: '')));

        final widgets = selfAndDescendantWidgetsOf(
          find.byType(Markdown),
          tester,
        ).toList();
        expectWidgetTypes(widgets.take(2), <Type>[
          Markdown,
          ListView,
        ]);
        expectWidgetTypes(widgets.reversed.take(2).toList().reversed, <Type>[
          SliverPadding,
          SliverList,
        ]);
      },
    );

    testWidgets(
      'table with fixed column width',
      (WidgetTester tester) async {
        const data = '|Header 1|Header 2|Header 3|'
            '\n|-----|-----|-----|'
            '\n|Col 1|Col 2|Col 3|';
        await tester.pumpWidget(
          boilerplate(
            MediaQuery(
              data: const MediaQueryData(),
              child: MarkdownBody(
                data: data,
                styleSheet: MarkdownStyleSheet(tableColumnWidth: const FixedColumnWidth(150)),
              ),
            ),
          ),
        );

        final widgets = tester.allWidgets;
        final scrollViews = widgets.whereType<SingleChildScrollView>();
        expect(scrollViews, isNotEmpty);
        expect(scrollViews.first.controller, isNotNull);
      },
    );

    testWidgets(
      'table with intrinsic column width',
      (WidgetTester tester) async {
        const data = '|Header 1|Header 2|Header 3|'
            '\n|-----|-----|-----|'
            '\n|Col 1|Col 2|Col 3|';
        await tester.pumpWidget(
          boilerplate(
            MediaQuery(
              data: const MediaQueryData(),
              child: MarkdownBody(
                data: data,
                styleSheet: MarkdownStyleSheet(tableColumnWidth: const IntrinsicColumnWidth()),
              ),
            ),
          ),
        );

        final widgets = tester.allWidgets;
        final scrollViews = widgets.whereType<SingleChildScrollView>();
        expect(scrollViews, isNotEmpty);
        expect(scrollViews.first.controller, isNotNull);
      },
    );

    testWidgets(
      'two tables use different scroll controllers',
      (WidgetTester tester) async {
        const data = '|Header 1|Header 2|Header 3|'
            '\n|-----|-----|-----|'
            '\n|Col 1|Col 2|Col 3|'
            '\n'
            '\n|Header 1|Header 2|Header 3|'
            '\n|-----|-----|-----|'
            '\n|Col 1|Col 2|Col 3|';

        await tester.pumpWidget(
          boilerplate(
            MediaQuery(
              data: const MediaQueryData(),
              child: MarkdownBody(
                data: data,
                styleSheet: MarkdownStyleSheet(tableColumnWidth: const FixedColumnWidth(150)),
              ),
            ),
          ),
        );

        final widgets = tester.allWidgets;
        final scrollViews = widgets.whereType<SingleChildScrollView>();
        expect(scrollViews, hasLength(2));
        expect(scrollViews.first.controller, isNotNull);
        expect(scrollViews.last.controller, isNotNull);
        expect(
          scrollViews.first.controller,
          isNot(equals(scrollViews.last.controller)),
        );
      },
    );
  });
}

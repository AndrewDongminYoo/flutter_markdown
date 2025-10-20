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
  group('Uri Data Scheme', () {
    testWidgets(
      'should work with image in uri data scheme',
      (WidgetTester tester) async {
        const data = '![alt](data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs=)';
        await tester.pumpWidget(boilerplate(const Markdown(data: data)));

        final widgets = tester.allWidgets;
        final image = widgets.firstWhere((Widget widget) => widget is Image) as Image;
        expect(image.image.runtimeType, MemoryImage);
      },
    );

    testWidgets(
      'should work with base64 text in uri data scheme',
      (WidgetTester tester) async {
        const imageData = '![alt](data:text/plan;base64,Rmx1dHRlcg==)';
        await tester.pumpWidget(boilerplate(const Markdown(data: imageData)));

        final widget = tester.widget<Text>(find.byType(Text));
        expect(widget.runtimeType, Text);
        expect(widget.data, 'Flutter');
      },
    );

    testWidgets(
      'should work with text in uri data scheme',
      (WidgetTester tester) async {
        const imageData = '![alt](data:text/plan,Hello%2C%20Flutter)';
        await tester.pumpWidget(boilerplate(const Markdown(data: imageData)));

        final widget = tester.widget<Text>(find.byType(Text));
        expect(widget.runtimeType, Text);
        expect(widget.data, 'Hello, Flutter');
      },
    );

    testWidgets(
      'should work with empty uri data scheme',
      (WidgetTester tester) async {
        const imageData = '![alt](data:,)';
        await tester.pumpWidget(boilerplate(const Markdown(data: imageData)));

        final widget = tester.widget<Text>(find.byType(Text));
        expect(widget.runtimeType, Text);
        expect(widget.data, '');
      },
    );

    testWidgets(
      'should work with unsupported mime types of uri data scheme',
      (WidgetTester tester) async {
        const data = '![alt](data:application/javascript,var%20test=1)';
        await tester.pumpWidget(boilerplate(const Markdown(data: data)));

        final widgets = tester.allWidgets;
        final widget = widgets.firstWhere((Widget widget) => widget is SizedBox) as SizedBox;
        expect(widget.runtimeType, SizedBox);
      },
    );
  });
}

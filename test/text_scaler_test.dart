// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Text Scaler', () {
    testWidgets(
      'should use style textScaler in RichText',
      (WidgetTester tester) async {
        const scaler = TextScaler.linear(2);
        const data = 'Hello';
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              styleSheet: MarkdownStyleSheet(textScaler: scaler),
              data: data,
            ),
          ),
        );

        final richText = tester.widget<RichText>(find.byType(RichText));
        expect(richText.textScaler, scaler);
      },
    );

    testWidgets(
      'should use MediaQuery textScaler in RichText',
      (WidgetTester tester) async {
        const scaler = TextScaler.linear(2);
        const data = 'Hello';
        await tester.pumpWidget(
          boilerplate(
            const MediaQuery(
              data: MediaQueryData(textScaler: scaler),
              child: MarkdownBody(
                data: data,
              ),
            ),
          ),
        );

        final richText = tester.widget<RichText>(find.byType(RichText));
        expect(richText.textScaler, scaler);
      },
    );

    testWidgets(
      'should use MediaQuery textScaler in SelectableText.rich',
      (WidgetTester tester) async {
        const scaler = TextScaler.linear(2);
        const data = 'Hello';
        await tester.pumpWidget(
          boilerplate(
            const MediaQuery(
              data: MediaQueryData(textScaler: scaler),
              child: MarkdownBody(
                data: data,
                selectable: true,
              ),
            ),
          ),
        );

        final selectableText = tester.widget<SelectableText>(find.byType(SelectableText));
        expect(selectableText.textScaler, scaler);
      },
    );
  });
}

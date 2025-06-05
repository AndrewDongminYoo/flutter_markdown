// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'image_test_mocks.dart';
import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Image', () {
    setUp(() {
      // Only needs to be done once since the HttpClient generated
      // by this override is cached as a static singleton.
      io.HttpOverrides.global = TestHttpOverrides();
    });

    testWidgets(
      'should not interrupt styling',
      (WidgetTester tester) async {
        const data = '_textbefore ![alt](https://img) textafter_';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final texts = tester.widgetList<Text>(find.byType(Text));
        final firstTextWidget = texts.first;
        final firstTextSpan = firstTextWidget.textSpan! as TextSpan;
        final image = tester.widget<Image>(find.byType(Image));
        final networkImage = image.image as NetworkImage;
        final secondTextWidget = texts.last;
        final secondTextSpan = secondTextWidget.textSpan! as TextSpan;

        expect(firstTextSpan.text, 'textbefore ');
        expect(firstTextSpan.style!.fontStyle, FontStyle.italic);
        expect(networkImage.url, 'https://img');
        expect(secondTextSpan.text, ' textafter');
        expect(secondTextSpan.style!.fontStyle, FontStyle.italic);
      },
    );

    testWidgets(
      'should work with a link',
      (WidgetTester tester) async {
        const data = '![alt](https://img#50x50)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final image = tester.widget<Image>(find.byType(Image));
        final networkImage = image.image as NetworkImage;
        expect(networkImage.url, 'https://img');
        expect(image.width, 50);
        expect(image.height, 50);
      },
    );

    testWidgets(
      'should work with relative remote image',
      (WidgetTester tester) async {
        const data = '![alt](/img.png)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(
              data: data,
              imageDirectory: 'https://localhost',
            ),
          ),
        );

        final widgets = tester.allWidgets;
        final image = widgets.firstWhere((Widget widget) => widget is Image) as Image;

        expect(image.image is NetworkImage, isTrue);
        expect((image.image as NetworkImage).url, 'https://localhost/img.png');
      },
    );

    testWidgets(
      'local files should be files on non-web',
      (WidgetTester tester) async {
        const data = '![alt](http.png)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final widgets = tester.allWidgets;
        final image = widgets.firstWhere((Widget widget) => widget is Image) as Image;

        expect(image.image is FileImage, isTrue);
      },
      skip: kIsWeb,
    );

    testWidgets(
      'local files should be network on web',
      (WidgetTester tester) async {
        const data = '![alt](http.png)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final widgets = tester.allWidgets;
        final image = widgets.firstWhere((Widget widget) => widget is Image) as Image;

        expect(image.image is NetworkImage, isTrue);
      },
      skip: !kIsWeb,
    );

    testWidgets(
      'should work with resources',
      (WidgetTester tester) async {
        TestWidgetsFlutterBinding.ensureInitialized();
        const data = '![alt](resource:assets/logo.png)';
        await tester.pumpWidget(
          boilerplate(
            MaterialApp(
              home: DefaultAssetBundle(
                bundle: TestAssetBundle(),
                child: Center(
                  child: Container(
                    color: Colors.white,
                    width: 500,
                    child: const Markdown(
                      data: data,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final image = tester.allWidgets.whereType<Image>() as Image;

        expect(image.image is AssetImage, isTrue);
        expect((image.image as AssetImage).assetName, 'assets/logo.png');

        // Force the asset image to be rasterized so it can be compared.
        await tester.runAsync(() async {
          final element = tester.element(find.byType(Markdown));
          await precacheImage(image.image, element);
        });

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Container),
          matchesGoldenFile(
            'assets/images/golden/image_test/resource_asset_logo.png',
          ),
        );
      },
      skip: kIsWeb, // Goldens are platform-specific.
    );

    testWidgets(
      'should work with local image files',
      (WidgetTester tester) async {
        const data = '![alt](img.png#50x50)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final image = tester.widget<Image>(find.byType(Image));
        final fileImage = image.image as FileImage;
        expect(fileImage.file.path, 'img.png');
        expect(image.width, 50);
        expect(image.height, 50);
      },
      skip: kIsWeb,
    );

    testWidgets(
      'should show properly next to text',
      (WidgetTester tester) async {
        const data = 'Hello ![alt](img#50x50)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final text = tester.widget<Text>(find.byType(Text));
        final textSpan = text.textSpan! as TextSpan;
        expect(textSpan.text, 'Hello ');
        expect(textSpan.style, isNotNull);
      },
    );

    testWidgets(
      'should work when nested in a link',
      (WidgetTester tester) async {
        final tapTexts = <String>[];
        final tapResults = <String?>[];
        const data = '[![alt](https://img#50x50)](href)';
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: data,
              onTapLink: (String text, String? value, String title) {
                tapTexts.add(text);
                tapResults.add(value);
              },
            ),
          ),
        );

        final detector = tester.widget<GestureDetector>(find.byType(GestureDetector));
        detector.onTap!();

        expect(tapTexts.length, 1);
        expect(tapTexts, everyElement('alt'));
        expect(tapResults.length, 1);
        expect(tapResults, everyElement('href'));
      },
    );

    testWidgets(
      'should work when nested in a link with text',
      (WidgetTester tester) async {
        final tapTexts = <String>[];
        final tapResults = <String?>[];
        const data = '[Text before ![alt](https://img#50x50) text after](href)';
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: data,
              onTapLink: (String text, String? value, String title) {
                tapTexts.add(text);
                tapResults.add(value);
              },
            ),
          ),
        );

        final detector = tester.widget<GestureDetector>(find.byType(GestureDetector));
        detector.onTap!();

        final texts = tester.widgetList<Text>(find.byType(Text));
        final firstTextWidget = texts.first;
        final firstSpan = firstTextWidget.textSpan! as TextSpan;
        (firstSpan.recognizer as TapGestureRecognizer?)!.onTap!();

        final lastTextWidget = texts.last;
        final lastSpan = lastTextWidget.textSpan! as TextSpan;
        (lastSpan.recognizer as TapGestureRecognizer?)!.onTap!();

        expect(firstSpan.children, null);
        expect(firstSpan.text, 'Text before ');
        expect(firstSpan.recognizer.runtimeType, equals(TapGestureRecognizer));

        expect(lastSpan.children, null);
        expect(lastSpan.text, ' text after');
        expect(lastSpan.recognizer.runtimeType, equals(TapGestureRecognizer));

        expect(tapTexts.length, 3);
        expect(tapTexts, everyElement('Text before alt text after'));
        expect(tapResults.length, 3);
        expect(tapResults, everyElement('href'));
      },
    );

    testWidgets(
      'should work alongside different links',
      (WidgetTester tester) async {
        final tapTexts = <String>[];
        final tapResults = <String?>[];
        const data = '[Link before](firstHref)[![alt](https://img#50x50)](imageHref)[link after](secondHref)';

        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: data,
              onTapLink: (String text, String? value, String title) {
                tapTexts.add(text);
                tapResults.add(value);
              },
            ),
          ),
        );

        final texts = tester.widgetList<Text>(find.byType(Text));
        final firstTextWidget = texts.first;
        final firstSpan = firstTextWidget.textSpan! as TextSpan;
        (firstSpan.recognizer as TapGestureRecognizer?)!.onTap!();

        final detector = tester.widget<GestureDetector>(find.byType(GestureDetector));
        detector.onTap!();

        final lastTextWidget = texts.last;
        final lastSpan = lastTextWidget.textSpan! as TextSpan;
        (lastSpan.recognizer as TapGestureRecognizer?)!.onTap!();

        expect(firstSpan.children, null);
        expect(firstSpan.text, 'Link before');
        expect(firstSpan.recognizer.runtimeType, equals(TapGestureRecognizer));

        expect(lastSpan.children, null);
        expect(lastSpan.text, 'link after');
        expect(lastSpan.recognizer.runtimeType, equals(TapGestureRecognizer));

        expect(tapTexts.length, 3);
        expect(tapTexts, <String>['Link before', 'alt', 'link after']);
        expect(tapResults.length, 3);
        expect(tapResults, <String>['firstHref', 'imageHref', 'secondHref']);
      },
    );

    testWidgets(
      'should gracefully handle image URLs with empty scheme',
      (WidgetTester tester) async {
        const data = '![alt](://img#x50)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        expect(find.byType(Image), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'should gracefully handle image URLs with invalid scheme',
      (WidgetTester tester) async {
        const data = '![alt](ttps://img#x50)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        // On the web, any URI with an unrecognized scheme is treated as a network image.
        // Thus the error builder of the Image widget is called.
        // On non-web, any URI with an unrecognized scheme is treated as a file image.
        // However, constructing a file from an invalid URI will throw an exception.
        // Thus the Image widget is never created, nor is its error builder called.
        if (kIsWeb) {
          expect(find.byType(Image), findsOneWidget);
        } else {
          expect(find.byType(Image), findsNothing);
        }

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'should gracefully handle width parsing failures',
      (WidgetTester tester) async {
        const data = '![alt](https://img#x50)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final image = tester.widget<Image>(find.byType(Image));
        final networkImage = image.image as NetworkImage;
        expect(networkImage.url, 'https://img');
        expect(image.width, null);
        expect(image.height, 50);
      },
    );

    testWidgets(
      'should gracefully handle height parsing failures',
      (WidgetTester tester) async {
        const data = ' ![alt](https://img#50x)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final image = tester.widget<Image>(find.byType(Image));
        final networkImage = image.image as NetworkImage;
        expect(networkImage.url, 'https://img');
        expect(image.width, 50);
        expect(image.height, null);
      },
    );

    testWidgets(
      'custom image builder',
      (WidgetTester tester) async {
        const data = '![alt](https://img.png)';
        Widget builder(Uri uri, String? title, String? alt) => Image.asset('assets/logo.png');

        await tester.pumpWidget(
          boilerplate(
            MaterialApp(
              home: DefaultAssetBundle(
                bundle: TestAssetBundle(),
                child: Center(
                  child: Container(
                    color: Colors.white,
                    width: 500,
                    child: Markdown(
                      data: data,
                      imageBuilder: builder,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final widgets = tester.allWidgets;
        final image = widgets.firstWhere((Widget widget) => widget is Image) as Image;

        expect(image.image.runtimeType, AssetImage);
        expect((image.image as AssetImage).assetName, 'assets/logo.png');

        // Force the asset image to be rasterized so it can be compared.
        await tester.runAsync(() async {
          final element = tester.element(find.byType(Markdown));
          await precacheImage(image.image, element);
        });

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Container),
          matchesGoldenFile(
            'assets/images/golden/image_test/custom_builder_asset_logo.png',
          ),
        );
        imageCache.clear();
      },
      skip: kIsWeb, // Goldens are platform-specific.
    );

    testWidgets(
      'custom image builder test width and height',
      (WidgetTester tester) async {
        const double height = 200;
        const double width = 100;
        const data = '![alt](https://img.png#${width}x$height)';
        Widget builder(MarkdownImageConfig config) => Image.asset(
              'assets/logo.png',
              width: config.width,
              height: config.height,
            );

        await tester.pumpWidget(
          boilerplate(
            MaterialApp(
              home: DefaultAssetBundle(
                bundle: TestAssetBundle(),
                child: Center(
                  child: Container(
                    color: Colors.white,
                    width: 500,
                    child: Markdown(
                      data: data,
                      sizedImageBuilder: builder,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final widgets = tester.allWidgets;
        final image = widgets.firstWhere((Widget widget) => widget is Image) as Image;

        expect(image.image.runtimeType, AssetImage);
        expect((image.image as AssetImage).assetName, 'assets/logo.png');
        expect(image.width, width);
        expect(image.height, height);

        await tester.runAsync(() async {
          final element = tester.element(find.byType(Markdown));
          await precacheImage(image.image, element);
        });

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Container),
          matchesGoldenFile(
            'assets/images/golden/image_test/custom_image_builder_test.png',
          ),
        );
        imageCache.clear();
      },
      skip: kIsWeb,
    );
  });
}

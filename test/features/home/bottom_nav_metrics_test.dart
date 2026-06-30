import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/home/models/bottom_nav_metrics.dart';

void main() {
  group('BottomNavMetrics', () {
    testWidgets('scales from the design baseline at reference width', (
      WidgetTester tester,
    ) async {
      late BottomNavMetrics metrics;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: Builder(
              builder: (context) {
                metrics = BottomNavMetrics.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(metrics.barHeight, closeTo(62, 1));
      expect(metrics.iconSize, closeTo(22, 1));
      expect(metrics.buttonSize, closeTo(54, 1));
      expect(metrics.fabSize, closeTo(58, 1));
      expect(metrics.fabIconSize, closeTo(26, 1));
      expect(metrics.horizontalPadding, closeTo(8, 1));
      expect(metrics.bottomSafePadding, 4);
    });

    testWidgets('uses device bottom inset for gesture navigation', (
      WidgetTester tester,
    ) async {
      late BottomNavMetrics metrics;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              padding: EdgeInsets.only(bottom: 34),
            ),
            child: Builder(
              builder: (context) {
                metrics = BottomNavMetrics.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(metrics.bottomSafePadding, 34);
      expect(metrics.totalBarHeight, closeTo(62 + 34, 1));
    });

    testWidgets('scales down on narrow screens', (WidgetTester tester) async {
      late BottomNavMetrics narrow;
      late BottomNavMetrics reference;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: Builder(
              builder: (context) {
                narrow = BottomNavMetrics.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: Builder(
              builder: (context) {
                reference = BottomNavMetrics.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(narrow.barHeight, lessThan(reference.barHeight));
      expect(narrow.iconSize, lessThan(reference.iconSize));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/features/home/presentation/home_feature_grid.dart';

void main() {
  testWidgets('renders feature cards with equal dimensions', (tester) async {
    final features = [
      for (var index = 0; index < 4; index++)
        HomeFeature(
          key: ValueKey('feature-$index'),
          title: 'Feature $index',
          description: 'A short description',
          icon: Icons.auto_awesome_outlined,
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          onTap: () {},
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: HomeFeatureGrid(features: features),
            ),
          ),
        ),
      ),
    );

    final sizes = [
      for (var index = 0; index < features.length; index++)
        tester.getSize(find.byKey(ValueKey('feature-$index'))),
    ];

    expect(sizes.toSet(), hasLength(1));
    expect(sizes.first.width, greaterThan(0));
    expect(sizes.first.height, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}

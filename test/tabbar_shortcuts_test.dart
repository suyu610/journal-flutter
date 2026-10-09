import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/app_tab_item.dart';
import 'package:journal/pages/tabbar_layout/custom_bottom_bar.dart';
import 'package:showcaseview/showcaseview.dart';

const _colors = AppThemeColors(
  backgroundColor: Colors.white,
  primaryText: Colors.black,
  secondaryText: Colors.grey,
  cardBackground: Colors.white,
  chartLine: Colors.black,
  chartPalette: [],
  navActive: Colors.black,
  navInactive: Colors.grey,
  mainButtonBg: Colors.black,
  mainButtonIcon: Colors.white,
  brandColor: Colors.black,
  onBrandColor: Colors.white,
  dangerColor: Colors.red,
  outlineBorder: Colors.grey,
);

void main() {
  test('tab settings edit a copy without changing the saved item', () {
    final original = AppTabItem(
      id: 'feature',
      label: '功能',
      icon: Icons.star_outline,
      routeName: '/feature',
      isEnabled: false,
    );
    final draft = original.copy()..isEnabled = true;
    expect(original.isEnabled, isFalse);
    expect(draft.routeName, '/feature');
  });

  testWidgets('more than five enabled tabs stay reachable on a narrow screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tabs = List.generate(
      8,
      (index) => AppTabItem(
        id: 'feature_$index',
        label: '功能 $index',
        icon: Icons.star_outline,
        routeName: '/feature_$index',
      ),
    );
    int? tappedIndex;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: const [_colors]),
      home: Scaffold(
        bottomNavigationBar: CustomBottomBar(
          tabs: tabs,
          currentIndex: 0,
          onTap: (index, _) => tappedIndex = index,
        ),
      ),
    ));

    expect(
        tester
            .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
            .scrollDirection,
        Axis.horizontal);
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('功能 7'));
    expect(tappedIndex, 7);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guide anchors stay mounted in a long customized tab bar',
      (tester) async {
    ShowcaseView.register(enableAutoScroll: true);
    addTearDown(() => ShowcaseView.get().unregister());
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tabs = List.generate(
      8,
      (index) => AppTabItem(
        id: 'feature_$index',
        label: '功能 $index',
        icon: Icons.star_outline,
        routeName: '/feature_$index',
      ),
    );
    final lastGuideKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: const [_colors]),
      home: Scaffold(
        bottomNavigationBar: CustomBottomBar(
          tabs: tabs,
          currentIndex: 0,
          guideKeys: {'feature_7': lastGuideKey},
          onTap: (_, __) {},
        ),
      ),
    ));

    expect(find.byType(Showcase), findsOneWidget);
    expect(tester.widget<Showcase>(find.byType(Showcase)).showcaseKey,
        same(lastGuideKey));
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected tab is scrolled into view after reordering',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final tabs = List.generate(
      8,
      (index) => AppTabItem(
        id: 'feature_$index',
        label: '功能 $index',
        icon: Icons.star_outline,
        routeName: '/feature_$index',
      ),
    );

    Widget bar(int selected) => MaterialApp(
          theme: ThemeData(extensions: const [_colors]),
          home: Scaffold(
            bottomNavigationBar: CustomBottomBar(
              tabs: tabs,
              currentIndex: selected,
              onTap: (_, __) {},
            ),
          ),
        );

    await tester.pumpWidget(bar(7));
    await tester.pumpAndSettle();
    expect(find.byTooltip('功能 7'), findsOneWidget);

    await tester.pumpWidget(bar(0));
    await tester.pumpAndSettle();
    expect(find.byTooltip('功能 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

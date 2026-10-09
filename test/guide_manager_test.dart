import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:journal/services/guide_manager.dart';
import 'package:journal/util/sp_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.put<SharedPreferences>(await SharedPreferences.getInstance());
  });

  tearDown(Get.reset);

  testWidgets('guide shows once and can be replayed', (tester) async {
    ShowcaseView.register(
      disableMovingAnimation: true,
      disableScaleAnimation: true,
    );
    addTearDown(() => ShowcaseView.get().unregister());

    late BuildContext pageContext;
    final targetKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        pageContext = context;
        return Scaffold(
          body: Center(
            child: Showcase(
              key: targetKey,
              title: '快速记账',
              description: '添加账单',
              child: const Icon(Icons.add),
            ),
          ),
        );
      }),
    ));

    GuideManager.show(pageContext, featureId: 'welcome', keys: [targetKey]);
    await tester.pump();
    expect(ShowcaseView.get().isShowcaseRunning, isTrue);
    expect(SpUtil.hasShownGuide('welcome'), isTrue);

    ShowcaseView.get().dismiss();
    await tester.pump();
    GuideManager.show(pageContext, featureId: 'welcome', keys: [targetKey]);
    await tester.pump();
    expect(ShowcaseView.get().isShowcaseRunning, isFalse);

    GuideManager.show(
      pageContext,
      featureId: 'welcome',
      keys: [targetKey],
      force: true,
    );
    await tester.pump();
    expect(ShowcaseView.get().isShowcaseRunning, isTrue);
    ShowcaseView.get().dismiss();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });
}

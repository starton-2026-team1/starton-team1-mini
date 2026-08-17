import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/carrot_market_app.dart';
import 'package:frontend/features/main_navigation/widgets/main_bottom_navigation_bar.dart';

void main() {
  testWidgets('메인 페이지에 하단 내비게이션을 표시한다', (tester) async {
    await tester.pumpWidget(const CarrotMarketApp());

    expect(find.byType(MainBottomNavigationBar), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('커뮤니티'), findsOneWidget);
    expect(find.text('동네지도'), findsOneWidget);
    expect(find.text('채팅'), findsOneWidget);
    expect(find.text('나의 당근'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('하단 메뉴를 선택하면 선택 상태가 변경된다', (tester) async {
    await tester.pumpWidget(const CarrotMarketApp());

    await tester.tap(find.text('채팅'));
    await tester.pump();

    final navigationBar = tester.widget<MainBottomNavigationBar>(
      find.byType(MainBottomNavigationBar),
    );
    expect(navigationBar.currentIndex, 3);
  });
}

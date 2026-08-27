import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/app_filter_chip_bar.dart';

void main() {
  testWidgets('한글 필터 라벨에 글자 수만큼 최소 너비를 확보한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppFilterChipBar<String>(
            items: const ['전체', '경매', '중고거래', '부동산', '알바'],
            selectedItem: '전체',
            labelBuilder: (item) => item,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    for (final label in ['전체', '경매', '중고거래', '부동산', '알바']) {
      final textWidth = tester.getSize(find.text(label)).width;
      final chipWidth = tester
          .getSize(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(ChoiceChip),
            ),
          )
          .width;
      expect(chipWidth, greaterThan(textWidth));
      expect(chipWidth, greaterThanOrEqualTo(label.runes.length * 16 + 32));
    }
  });
}

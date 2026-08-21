import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/product/models/product_sell_draft.dart';

void main() {
  test('내 물건 팔기 임시저장 데이터를 JSON으로 변환하고 복원한다', () {
    const draft = ProductSellDraft(
      title: '자전거',
      description: '상태가 좋아요',
      price: '30000',
      place: '용현동',
      imagePaths: ['/tmp/bicycle.jpg'],
    );

    final restored = ProductSellDraft.fromJson(draft.toJson());

    expect(restored.title, draft.title);
    expect(restored.description, draft.description);
    expect(restored.price, draft.price);
    expect(restored.place, draft.place);
    expect(restored.imagePaths, draft.imagePaths);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auction/controllers/auction_create_controller.dart';

void main() {
  test('입력값이 변경될 때만 임시저장 상태가 활성화된다', () {
    final controller = AuctionCreateController();
    addTearDown(controller.dispose);

    expect(controller.isDirty, isFalse);

    controller.titleController.text = '자전거';
    expect(controller.isDirty, isTrue);

    controller.markSaved();
    expect(controller.isDirty, isFalse);

    controller.setExtensionCount(2);
    expect(controller.isDirty, isTrue);
  });

  test('필수 입력값이 없으면 제목 오류를 반환한다', () {
    final controller = AuctionCreateController();
    addTearDown(controller.dispose);

    expect(controller.validate(), '제목을 입력해 주세요.');
  });

  test('종료 시간이 시작 시간보다 빠르면 오류를 반환한다', () {
    final controller = AuctionCreateController();
    addTearDown(controller.dispose);
    controller.titleController.text = '자전거';
    controller.descriptionController.text = '상태가 좋아요';
    controller.placeController.text = '서울역 1번 출구';
    controller.startingPriceController.text = '10000';
    controller.bidIncrementController.text = '1000';
    controller.setStartsAt(DateTime(2026, 8, 20, 12));
    controller.setEndsAt(DateTime(2026, 8, 20, 11));

    expect(controller.validate(), '종료 시간은 시작 시간보다 늦어야 해요.');
  });

  test('바로 입찰 가격은 시작 가격보다 높아야 한다', () {
    final controller = AuctionCreateController();
    addTearDown(controller.dispose);
    controller.titleController.text = '자전거';
    controller.descriptionController.text = '상태가 좋아요';
    controller.placeController.text = '서울역 1번 출구';
    controller.startingPriceController.text = '10000';
    controller.bidIncrementController.text = '1000';
    controller.buyNowPriceController.text = '9000';
    controller.setStartsAt(DateTime(2026, 8, 20, 12));
    controller.setEndsAt(DateTime(2026, 8, 20, 13));

    expect(controller.validate(), '바로 입찰 가격은 시작 가격보다 높아야 해요.');
  });

  test('유효한 입력값을 경매 등록 모델로 변환한다', () {
    final controller = AuctionCreateController();
    addTearDown(controller.dispose);
    controller.titleController.text = ' 자전거 ';
    controller.descriptionController.text = ' 상태가 좋아요 ';
    controller.placeController.text = ' 서울역 1번 출구 ';
    controller.startingPriceController.text = '10000';
    controller.bidIncrementController.text = '1000';
    controller.buyNowPriceController.text = '50000';
    controller.setStartsAt(DateTime(2026, 8, 20, 12));
    controller.setEndsAt(DateTime(2026, 8, 20, 13));
    controller.setExtensionCount(3);

    expect(controller.validate(), isNull);
    final form = controller.toForm();
    expect(form.title, '자전거');
    expect(form.startingPrice, 10000);
    expect(form.buyNowPrice, 50000);
    expect(form.extensionCount, 3);
  });
}

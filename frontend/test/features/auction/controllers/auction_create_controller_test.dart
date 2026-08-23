import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auction/controllers/auction_create_controller.dart';
import 'package:image_picker/image_picker.dart';

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
    controller.startingPriceController.text = '10000';
    controller.bidIncrementController.text = '1000';
    final startsAt = controller.now.add(const Duration(hours: 2));
    controller.setStartsAt(startsAt);
    controller.setEndsAt(startsAt.subtract(const Duration(hours: 1)));

    expect(controller.validate(), '종료 시간은 시작 시간보다 늦어야 해요.');
  });

  test('유효한 입력값을 경매 등록 모델로 변환한다', () {
    final controller = AuctionCreateController();
    addTearDown(controller.dispose);
    controller.titleController.text = ' 자전거 ';
    controller.descriptionController.text = ' 상태가 좋아요 ';
    controller.startingPriceController.text = '10000';
    controller.bidIncrementController.text = '1000';
    final startsAt = controller.now.add(const Duration(hours: 1));
    controller.setStartsAt(startsAt);
    controller.setEndsAt(startsAt.add(const Duration(hours: 1)));
    controller.setExtensionCount(3);
    controller.setImageFiles([XFile('/tmp/bicycle.jpg')]);

    expect(controller.validate(), isNull);
    final form = controller.toForm();
    expect(form.title, '자전거');
    expect(form.startingPrice, 10000);
    expect(form.extensionCount, 3);
    expect(form.imageFiles.single.path, '/tmp/bicycle.jpg');
  });

  test('상품 사진이 없으면 사진 오류를 반환한다', () {
    final controller = AuctionCreateController();
    addTearDown(controller.dispose);
    controller.titleController.text = '자전거';
    controller.descriptionController.text = '상태가 좋아요';
    controller.startingPriceController.text = '10000';
    controller.bidIncrementController.text = '1000';
    final startsAt = controller.now.add(const Duration(hours: 1));
    controller.setStartsAt(startsAt);
    controller.setEndsAt(startsAt.add(const Duration(hours: 1)));

    expect(controller.validate(), '상품 사진을 한 장 이상 등록해 주세요.');
  });
}

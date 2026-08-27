import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/product/controllers/product_sell_controller.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  test('입력값이 변경될 때만 임시저장 상태가 활성화된다', () {
    final controller = ProductSellController();
    addTearDown(controller.dispose);

    expect(controller.isDirty, isFalse);

    controller.titleController.text = '자전거';
    expect(controller.isDirty, isTrue);

    controller.markSaved();
    expect(controller.isDirty, isFalse);
  });

  test('필수 입력값이 없으면 등록 모델을 만들지 않는다', () {
    final controller = ProductSellController();
    addTearDown(controller.dispose);

    final form = controller.buildForm();

    expect(form, isNull);
    expect(controller.errors.keys, contains(ProductSellField.images));
    expect(controller.errors.keys, contains(ProductSellField.title));
    expect(controller.errors.keys, contains(ProductSellField.price));
  });

  test('유효한 판매 입력값을 등록 모델로 변환한다', () {
    final controller = ProductSellController();
    addTearDown(controller.dispose);
    controller.setImages([XFile('/tmp/product.jpg')]);
    controller.titleController.text = '의자 팔아요';
    controller.descriptionController.text = '상태 좋은 의자입니다.';
    controller.priceController.text = '30000';
    controller.placeController.text = '용현동';

    final form = controller.buildForm();

    expect(form, isNotNull);
    expect(form!.title, '의자 팔아요');
    expect(form.price, 30000);
  });
}

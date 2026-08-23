import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';
import 'package:frontend/shared/widgets/app_snack_bar.dart';
import 'package:image_picker/image_picker.dart';

import '../data/product_api.dart';
import '../../auction/widgets/auction_form_section.dart';
import '../../auction/widgets/auction_draft_dialog.dart';
import '../../auction/widgets/auction_image_picker.dart';
import '../controllers/product_sell_controller.dart';
import '../models/product_sell_draft.dart';
import '../models/product_sell_form.dart';
import '../services/product_sell_draft_storage.dart';

class ProductSellPage extends StatefulWidget {
  const ProductSellPage({this.onSubmitted, super.key});

  final ValueChanged<ProductSellForm>? onSubmitted;

  @override
  State<ProductSellPage> createState() => _ProductSellPageState();
}

class _ProductSellPageState extends State<ProductSellPage> {
  final _controller = ProductSellController();
  final _draftStorage = ProductSellDraftStorage();
  final _productApi = ProductApi();
  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    _restoreDraft();
  }

  @override
  void dispose() {
    _controller.dispose();
    _productApi.close();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final form = _controller.buildForm();

    if (form == null) {
      showAppSnackBar(context, '필수 입력값을 확인해 주세요.');
      return;
    }

    try {
      await _productApi.createProduct(form);

      widget.onSubmitted?.call(form);

      await _draftStorage.clear();

      if (!mounted) return;

      _controller.markSaved();
      setState(() => _canPop = true);

      showAppSnackBar(context, '상품이 등록되었습니다.');

      Navigator.of(context).pop(form);
    } catch (error) {
      if (!mounted) return;

      debugPrint('상품 등록 오류: $error');

      showAppSnackBar(context, '상품 등록에 실패했습니다: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestClose();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.transparent,
          centerTitle: true,
          leading: IconButton(
            onPressed: _requestClose,
            icon: const Icon(Icons.close, size: 30),
          ),
          title: const Text(
            '전국에 올리기',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          actions: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return TextButton(
                  onPressed: _controller.isDirty ? _saveDraft : null,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    disabledForegroundColor: AppColors.border,
                  ),
                  child: const Text('임시저장', style: TextStyle(fontSize: 16)),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                      children: [
                        AuctionImagePicker(
                          imageFiles: _controller.imageFiles,
                          onChanged: _controller.setImages,
                          onMessage: (message) =>
                              showAppSnackBar(context, message),
                          errorText:
                              _controller.errors[ProductSellField.images],
                        ),
                        const SizedBox(height: 30),
                        AuctionFormSection(
                          title: '제목',
                          child: AuctionTextField(
                            controller: _controller.titleController,
                            hintText: '제목을 입력해주세요.',
                            errorText:
                                _controller.errors[ProductSellField.title],
                            onChanged: (_) =>
                                _controller.clearError(ProductSellField.title),
                          ),
                        ),
                        const SizedBox(height: 28),
                        AuctionFormSection(
                          title: '자세한 설명',
                          child: AuctionTextField(
                            controller: _controller.descriptionController,
                            hintText:
                                '전국에 올릴 게시글 내용을 작성해 주세요. '
                                '(판매 금지 물품은 게시가 제한될 수 있어요.)\n\n'
                                '신뢰할 수 있는 거래를 위해 자세히 적어주세요.',
                            maxLines: 7,
                            errorText: _controller
                                .errors[ProductSellField.description],
                            onChanged: (_) => _controller.clearError(
                              ProductSellField.description,
                            ),
                          ),
                        ),
                        const SizedBox(height: 34),
                        _PriceSection(controller: _controller),
                        const SizedBox(height: 32),
                        AuctionFormSection(
                          title: '거래 희망 장소',
                          child: AuctionTextField(
                            controller: _controller.placeController,
                            hintText: '거래 희망 장소를 입력해 주세요.',
                            suffixIcon: const Icon(
                              Icons.place_outlined,
                              color: AppColors.textSecondary,
                            ),
                            errorText:
                                _controller.errors[ProductSellField.place],
                            onChanged: (_) =>
                                _controller.clearError(ProductSellField.place),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '작성 완료',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveDraft() async {
    FocusScope.of(context).unfocus();
    await _draftStorage.save(_createDraft());
    if (!mounted) return;
    _controller.markSaved();
    showAppSnackBar(context, '게시글을 임시저장했어요.', bottomMargin: 92);
  }

  Future<void> _requestClose() async {
    FocusScope.of(context).unfocus();
    if (!_controller.isDirty) {
      _popPage();
      return;
    }

    final choice = await showAuctionDraftDialog(
      context: context,
      message: '작성 중인 게시글을 저장할까요?',
      primaryLabel: '저장하기',
      secondaryLabel: '저장 안 함',
    );
    if (!mounted || choice == null) return;

    if (choice == AuctionDraftChoice.primary) {
      await _draftStorage.save(_createDraft());
      if (!mounted) return;
      _controller.markSaved();
    }
    _popPage();
  }

  ProductSellDraft _createDraft() {
    return ProductSellDraft(
      title: _controller.titleController.text,
      description: _controller.descriptionController.text,
      price: _controller.priceController.text,
      place: _controller.placeController.text,
      imagePaths: _controller.imageFiles.map((image) => image.path).toList(),
    );
  }

  Future<void> _restoreDraft() async {
    final draft = await _draftStorage.load();
    if (draft == null || !mounted) return;

    _controller.titleController.text = draft.title;
    _controller.descriptionController.text = draft.description;
    _controller.priceController.text = draft.price;
    _controller.placeController.text = draft.place;
    _controller.setImages(draft.imagePaths.take(10).map(XFile.new).toList());
    _controller.markSaved();
  }

  void _popPage() {
    setState(() => _canPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({required this.controller});

  final ProductSellController controller;

  @override
  Widget build(BuildContext context) {
    return AuctionFormSection(
      title: '가격',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuctionTextField(
            controller: controller.priceController,
            hintText: '가격을 입력해주세요.',
            prefixText: '₩ ',
            keyboardType: TextInputType.number,
            inputFormatters: [ProductSellController.priceFormatter],
            errorText: controller.errors[ProductSellField.price],
            onChanged: (_) => controller.clearError(ProductSellField.price),
          ),
        ],
      ),
    );
  }
}

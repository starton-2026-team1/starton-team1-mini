import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../controllers/auction_create_controller.dart';
import '../models/auction_create_form.dart';
import '../models/auction_draft.dart';
import '../services/auction_draft_storage.dart';
import '../widgets/auction_date_picker.dart';
import '../widgets/auction_date_time_field.dart';
import '../widgets/auction_draft_dialog.dart';
import '../widgets/auction_form_section.dart';
import '../widgets/auction_time_picker.dart';

class AuctionCreatePage extends StatefulWidget {
  const AuctionCreatePage({this.onSubmitted, super.key});

  final ValueChanged<AuctionCreateForm>? onSubmitted;

  @override
  State<AuctionCreatePage> createState() => _AuctionCreatePageState();
}

class _AuctionCreatePageState extends State<AuctionCreatePage> {
  final _controller = AuctionCreateController();
  final _draftStorage = AuctionDraftStorage();
  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    _restoreDraft();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            '전국에 경매 올리기',
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
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                    children: [
                      _ImagePicker(onTap: () => _showMessage('사진 선택.')),
                      const SizedBox(height: 30),
                      AuctionFormSection(
                        title: '제목',
                        child: AuctionTextField(
                          controller: _controller.titleController,
                          hintText: '제목을 입력해 주세요.',
                          errorText:
                              _controller.errors[AuctionCreateField.title],
                          onChanged: (_) =>
                              _controller.clearError(AuctionCreateField.title),
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
                              '신뢰할 수 있는 거래를 위해 자세히 적어주세요. '
                              '과학기술정보통신부, 한국인터넷진흥원과 함께 해요.',
                          maxLines: 7,
                          errorText: _controller
                              .errors[AuctionCreateField.description],
                          onChanged: (_) => _controller.clearError(
                            AuctionCreateField.description,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
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
                              _controller.errors[AuctionCreateField.place],
                          onChanged: (_) =>
                              _controller.clearError(AuctionCreateField.place),
                        ),
                      ),
                      const SizedBox(height: 36),
                      _buildAuctionSettings(),
                    ],
                  ),
                ),
              ),
              _SubmitButton(onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuctionSettings() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuctionFormSection(
              title: '시작 가격',
              child: AuctionTextField(
                controller: _controller.startingPriceController,
                hintText: '시작 가격을 입력해 주세요.',
                prefixText: '₩ ',
                keyboardType: TextInputType.number,
                inputFormatters: [AuctionCreateController.priceFormatter],
                errorText: _controller.errors[AuctionCreateField.startingPrice],
                onChanged: (_) =>
                    _controller.clearError(AuctionCreateField.startingPrice),
              ),
            ),
            const SizedBox(height: 24),
            AuctionFormSection(
              title: '최소 입찰 단위',
              child: AuctionTextField(
                controller: _controller.bidIncrementController,
                hintText: '최소 입찰 단위를 입력해 주세요.',
                prefixText: '₩ ',
                keyboardType: TextInputType.number,
                inputFormatters: [AuctionCreateController.priceFormatter],
                errorText: _controller.errors[AuctionCreateField.bidIncrement],
                onChanged: (_) =>
                    _controller.clearError(AuctionCreateField.bidIncrement),
              ),
            ),
            const SizedBox(height: 24),
            AuctionFormSection(
              title: '바로 입찰 가격',
              child: AuctionTextField(
                controller: _controller.buyNowPriceController,
                hintText: '선택 입력',
                prefixText: '₩ ',
                keyboardType: TextInputType.number,
                inputFormatters: [AuctionCreateController.priceFormatter],
                errorText: _controller.errors[AuctionCreateField.buyNowPrice],
                onChanged: (_) =>
                    _controller.clearError(AuctionCreateField.buyNowPrice),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '입력한 가격으로 즉시 낙찰할 수 있어요.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            AuctionFormSection(
              title: '경매 시간',
              child: Row(
                children: [
                  Expanded(
                    child: AuctionDateTimeField(
                      label: '시작 시간',
                      value: _controller.startsAt,
                      onTap: () => _pickDateTime(true),
                      errorText:
                          _controller.errors[AuctionCreateField.startsAt],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AuctionDateTimeField(
                      label: '끝나는 시간',
                      value: _controller.endsAt,
                      onTap: () => _pickDateTime(false),
                      errorText: _controller.errors[AuctionCreateField.endsAt],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AuctionFormSection(
              title: '자동 연장 횟수',
              child: DropdownButtonFormField<int>(
                initialValue: _controller.extensionCount,
                decoration: _inputDecoration(),
                items: List.generate(
                  6,
                  (index) => DropdownMenuItem(
                    value: index,
                    child: Text(index == 0 ? '자동 연장 안 함' : '$index회'),
                  ),
                ),
                onChanged: (value) => _controller.setExtensionCount(value ?? 0),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '마감 직전 입찰이 들어오면 종료 시간을 연장해요.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.textSecondary),
      ),
    );
  }

  Future<void> _pickDateTime(bool isStart) async {
    final current = DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final lastDate = today.add(const Duration(days: 27));
    final initial = isStart
        ? (_controller.startsAt ?? current)
        : (_controller.endsAt ?? current.add(const Duration(hours: 1)));
    final initialDay = DateTime(initial.year, initial.month, initial.day);
    final calendarInitialDate = initialDay.isBefore(today)
        ? today
        : initialDay.isAfter(lastDate)
        ? lastDate
        : initialDay;
    final date = await showAuctionDatePicker(
      context: context,
      initialDate: calendarInitialDate,
      firstDate: today,
      lastDate: lastDate,
    );
    if (date == null || !mounted) return;
    final time = await showAuctionTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    final value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (isStart) {
      _controller.setStartsAt(value);
    } else {
      _controller.setEndsAt(value);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final error = _controller.validate();
    if (error != null) {
      return;
    }
    widget.onSubmitted?.call(_controller.toForm());
    _showMessage('경매 글 작성이 완료됐어요.');
  }

  Future<void> _saveDraft() async {
    FocusScope.of(context).unfocus();
    await _draftStorage.save(_createDraft());
    if (!mounted) return;
    _controller.markSaved();
    _showMessage('게시글을 임시저장했어요.');
  }

  Future<void> _requestClose() async {
    FocusScope.of(context).unfocus();
    if (!_controller.isDirty) {
      _popPage();
      return;
    }

    final choice = await showAuctionDraftDialog(
      context: context,
      message: '작성 중인 경매 글을 저장할까요?',
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

  AuctionDraft _createDraft() {
    return AuctionDraft(
      title: _controller.titleController.text,
      description: _controller.descriptionController.text,
      place: _controller.placeController.text,
      startingPrice: _controller.startingPriceController.text,
      bidIncrement: _controller.bidIncrementController.text,
      buyNowPrice: _controller.buyNowPriceController.text,
      startsAt: _controller.startsAt,
      endsAt: _controller.endsAt,
      extensionCount: _controller.extensionCount,
      acceptPriceOffers: _controller.acceptPriceOffers,
    );
  }

  void _popPage() {
    setState(() => _canPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _restoreDraft() async {
    final draft = await _draftStorage.load();
    if (draft == null || !mounted) return;

    _controller.titleController.text = draft.title;
    _controller.descriptionController.text = draft.description;
    _controller.placeController.text = draft.place;
    _controller.startingPriceController.text = draft.startingPrice;
    _controller.bidIncrementController.text = draft.bidIncrement;
    _controller.buyNowPriceController.text = draft.buyNowPrice;
    if (draft.startsAt != null) _controller.setStartsAt(draft.startsAt!);
    if (draft.endsAt != null) _controller.setEndsAt(draft.endsAt!);
    _controller.setExtensionCount(draft.extensionCount);
    _controller.setAcceptPriceOffers(draft.acceptPriceOffers);
    _controller.markSaved();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 112),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: AppColors.textSecondary, size: 27),
              SizedBox(height: 2),
              Text(
                '0/10',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '작성 완료',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

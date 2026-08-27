import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/theme/app_colors.dart';
import '../pages/auction_image_gallery_page.dart';

class AuctionImagePicker extends StatefulWidget {
  const AuctionImagePicker({
    required this.imageFiles,
    required this.onChanged,
    required this.onMessage,
    this.errorText,
    this.maxCount = 10,
    super.key,
  });

  final List<XFile> imageFiles;
  final ValueChanged<List<XFile>> onChanged;
  final ValueChanged<String> onMessage;
  final String? errorText;
  final int maxCount;

  @override
  State<AuctionImagePicker> createState() => _AuctionImagePickerState();
}

class _AuctionImagePickerState extends State<AuctionImagePicker> {
  final _imagePicker = ImagePicker();

  Future<void> _openGallery() async {
    if (widget.imageFiles.length >= widget.maxCount) {
      widget.onMessage('사진은 최대 ${widget.maxCount}장까지 등록할 수 있어요.');
      return;
    }
    final remainingCount = widget.maxCount - widget.imageFiles.length;
    // 웹은 사진 보관함 권한이 없으므로 브라우저 파일 선택창을 사용한다.
    final selected = kIsWeb
        ? await _imagePicker.pickMultiImage(limit: remainingCount)
        : await Navigator.push<List<XFile>>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AuctionImageGalleryPage(remainingCount: remainingCount),
            ),
          );
    if (!mounted || selected == null || selected.isEmpty) return;
    widget.onChanged([...widget.imageFiles, ...selected]);
  }

  void _removeImage(int index) {
    final files = [...widget.imageFiles]..removeAt(index);
    widget.onChanged(files);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.imageFiles.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == 0) return _buildAddButton();
              return _buildPreview(index - 1);
            },
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: const TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: _openGallery,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.errorText == null
                ? AppColors.border
                : AppColors.error,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.textSecondary,
              size: 27,
            ),
            const SizedBox(height: 3),
            Text(
              '${widget.imageFiles.length}/${widget.maxCount}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(int index) {
    return SizedBox(
      width: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FutureBuilder<Uint8List>(
                future: widget.imageFiles[index].readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.memory(snapshot.data!, fit: BoxFit.cover);
                  }
                  if (snapshot.hasError) {
                    return const ColoredBox(
                      color: AppColors.surfaceMuted,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textSecondary,
                      ),
                    );
                  }
                  return const ColoredBox(
                    color: AppColors.surfaceMuted,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
          if (index == 0) const _PrimaryImageLabel(),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () => _removeImage(index),
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 15,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryImageLabel extends StatelessWidget {
  const _PrimaryImageLabel();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: const BoxDecoration(
          color: AppColors.black54,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        alignment: Alignment.center,
        child: const Text(
          '대표 사진',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app_snack_bar.dart';

class AuctionImageGalleryPage extends StatefulWidget {
  const AuctionImageGalleryPage({required this.remainingCount, super.key});

  final int remainingCount;

  @override
  State<AuctionImageGalleryPage> createState() =>
      _AuctionImageGalleryPageState();
}

class _AuctionImageGalleryPageState extends State<AuctionImageGalleryPage> {
  final _imagePicker = ImagePicker();
  final List<AssetEntity> _assets = [];
  final List<AssetEntity> _selected = [];
  PermissionState? _permissionState;
  bool _isLoading = true;
  bool _isCompleting = false;
  String? _loadError;

  bool get _canAccessPhotos =>
      _permissionState == PermissionState.authorized ||
      _permissionState == PermissionState.limited;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoad();
  }

  Future<void> _requestPermissionAndLoad() async {
    try {
      final permission = await PhotoManager.requestPermissionExtend().timeout(
        const Duration(seconds: 10),
      );
      if (!mounted) return;
      setState(() {
        _permissionState = permission;
        _isLoading = false;
      });
      if (_canAccessPhotos) await _loadRecentPhotos();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _permissionState = PermissionState.denied;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecentPhotos() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          orders: const [
            OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      ).timeout(const Duration(seconds: 8));
      final assets = albums.isEmpty
          ? <AssetEntity>[]
          : await albums.first
                .getAssetListPaged(page: 0, size: 200)
                .timeout(const Duration(seconds: 8));
      if (!mounted) return;
      setState(() {
        _assets
          ..clear()
          ..addAll(assets);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = '사진을 불러오지 못했어요.';
        _isLoading = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 88,
      );
      if (!mounted || photo == null) return;
      Navigator.pop(context, [photo.path]);
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(context, '카메라 권한을 확인해 주세요.');
    }
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selected.contains(asset)) {
        _selected.remove(asset);
      } else if (_selected.length < widget.remainingCount) {
        _selected.add(asset);
      } else {
        showAppSnackBar(context, '사진은 ${widget.remainingCount}장 더 선택할 수 있어요.');
      }
    });
  }

  Future<void> _completeSelection() async {
    if (_selected.isEmpty || _isCompleting) return;
    setState(() => _isCompleting = true);
    final paths = <String>[];
    for (final asset in _selected) {
      final file = await asset.originFile;
      if (file != null) paths.add(file.path);
    }
    if (!mounted) return;
    if (paths.isEmpty) {
      setState(() => _isCompleting = false);
      showAppSnackBar(context, '선택한 사진을 불러오지 못했어요.');
      return;
    }
    Navigator.pop(context, paths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 30),
        ),
        centerTitle: true,
        title: const Text(
          '최근 항목',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _selected.isEmpty || _isCompleting
                ? null
                : _completeSelection,
            child: Text(
              _selected.isEmpty ? '완료' : '완료 ${_selected.length}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_canAccessPhotos) {
      return _PermissionGuide(onRetry: _requestPermissionAndLoad);
    }

    return Column(
      children: [
        if (_loadError != null)
          Material(
            color: AppColors.surfaceMuted,
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(_loadError!),
              trailing: TextButton(
                onPressed: _loadRecentPhotos,
                child: const Text('다시 시도'),
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: _assets.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _CameraTile(onTap: _takePhoto);
              final asset = _assets[index - 1];
              final selectedIndex = _selected.indexOf(asset);
              return _PhotoTile(
                asset: asset,
                selectionNumber: selectedIndex < 0 ? null : selectedIndex + 1,
                onTap: () => _toggleSelection(asset),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PermissionGuide extends StatelessWidget {
  const _PermissionGuide({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 52,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 18),
            const Text(
              '사진을 등록하려면 사진 접근 권한이 필요해요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                await PhotoManager.openSetting();
              },
              child: const Text('설정에서 권한 허용'),
            ),
            TextButton(onPressed: onRetry, child: const Text('다시 확인')),
          ],
        ),
      ),
    );
  }
}

class _CameraTile extends StatelessWidget {
  const _CameraTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const ColoredBox(
        color: AppColors.surfaceMuted,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 38, color: AppColors.textPrimary),
            SizedBox(height: 6),
            Text('카메라', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.asset,
    required this.onTap,
    this.selectionNumber,
  });

  final AssetEntity asset;
  final VoidCallback onTap;
  final int? selectionNumber;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<Uint8List?>(
            future: asset.thumbnailDataWithSize(
              const ThumbnailSize.square(360),
              quality: 85,
            ),
            builder: (context, snapshot) {
              final bytes = snapshot.data;
              if (bytes == null) {
                return const ColoredBox(color: AppColors.surfaceMuted);
              }
              return Image.memory(
                bytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              );
            },
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectionNumber == null
                    ? AppColors.black10
                    : AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: selectionNumber == null
                  ? null
                  : Text(
                      '$selectionNumber',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

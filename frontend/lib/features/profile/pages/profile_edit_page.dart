import 'package:flutter/material.dart';
import 'package:frontend/shared/network/api_exception.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../data/profile_api.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({
    required this.userName,
    required this.profileGateway,
    super.key,
  });

  final String userName;
  final ProfileGateway profileGateway;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nameController;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _canSave {
    final name = _nameController.text.trim();
    return name.isNotEmpty && name != widget.userName && !_isSaving;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName)
      ..addListener(_handleNameChanged);
  }

  void _handleNameChanged() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
    setState(() {});
  }

  Future<void> _save() async {
    if (!_canSave) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final name = await widget.profileGateway.updateName(
        _nameController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop(name);
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } on Object {
      if (mounted) {
        setState(() => _errorMessage = '닉네임을 수정하지 못했어요.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, size: 30),
        ),
        centerTitle: true,
        title: const Text(
          '프로필 수정',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('완료', style: TextStyle(fontSize: 17)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            const Align(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 58,
                    backgroundColor: AppColors.iconMuted,
                    child: Icon(Icons.person, size: 82, color: AppColors.white),
                  ),
                  Positioned(
                    right: -2,
                    bottom: 2,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.white,
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '닉네임',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 13),
            TextField(
              controller: _nameController,
              maxLength: 50,
              autofocus: false,
              decoration: InputDecoration(
                counterText: '',
                errorText: _errorMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: AppColors.textStrong),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../data/profile_api.dart';
import '../widgets/profile_temperature_badge.dart';
import 'profile_edit_page.dart';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({
    required this.userId,
    required this.userName,
    required this.mannerTemperature,
    required this.profileGateway,
    required this.onNameUpdated,
    super.key,
  });

  final int userId;
  final String userName;
  final double mannerTemperature;
  final ProfileGateway profileGateway;
  final ValueChanged<String> onNameUpdated;

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late String _userName;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
  }

  Future<void> _editProfile() async {
    final name = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ProfileEditPage(
          userName: _userName,
          profileGateway: widget.profileGateway,
        ),
      ),
    );

    if (name == null || !mounted) {
      return;
    }

    setState(() => _userName = name);
    widget.onNameUpdated(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceMuted,
        surfaceTintColor: AppColors.transparent,
        centerTitle: true,
        title: const Text(
          '프로필',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.ios_share_outlined, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _ProfileInformationCard(
            userId: widget.userId,
            userName: _userName,
            onEdit: _editProfile,
          ),
          const SizedBox(height: 12),
          _MannerTemperatureCard(mannerTemperature: widget.mannerTemperature),
          const SizedBox(height: 12),
          const _ActivityCard(),
        ],
      ),
    );
  }
}

class _ProfileInformationCard extends StatelessWidget {
  const _ProfileInformationCard({
    required this.userId,
    required this.userName,
    required this.onEdit,
  });

  final int userId;
  final String userName;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.iconMuted,
                  child: Icon(Icons.person, size: 54, color: AppColors.white),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '#$userId · 최근 활동',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _VerificationRow(
              icon: Icons.verified_user_outlined,
              label: '휴대폰 본인인증 완료',
            ),
            const SizedBox(height: 14),
            const _VerificationRow(icon: Icons.location_on, label: '동네 인증 사용자'),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onEdit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceMuted,
                  foregroundColor: AppColors.textStrong,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '프로필 수정',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  const _VerificationRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

class _MannerTemperatureCard extends StatelessWidget {
  const _MannerTemperatureCard({required this.mannerTemperature});

  final double mannerTemperature;

  @override
  Widget build(BuildContext context) {
    final progress = (mannerTemperature / 100).clamp(0.0, 1.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '매너온도',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProfileTemperatureBadge(temperature: mannerTemperature),
                const Text('😊', style: TextStyle(fontSize: 44)),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: AppColors.surfaceMuted,
                color: AppColors.temperature,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '재거래 희망률 100%',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '판매물품 0',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

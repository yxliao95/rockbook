import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gym_model.dart';
import '../../provider/app_state_provider.dart';
import '../../services/fake_data_service.dart';
import '../common/image_avatar.dart';

class GymInfoPage extends ConsumerWidget {
  const GymInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? selectedGymId = ref.watch(selectedGymIdProvider);
    final Gym? gym = FakeDataService.instance.getGymById(selectedGymId!);

    if (gym == null) {
      return const Scaffold(body: Center(child: Text('Error: No gym selected or gym not found.')));
    } else {
      return SafeArea(
        child: GymPageFrame(gym: gym), // 使用 GymPageFrame 组件
      );
    }
  }
}

class GymPageFrame extends ConsumerWidget {
  final Gym gym;
  const GymPageFrame({super.key, required this.gym});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section 1: logo + name + info
            _HeaderSection(gym: gym),
            const Divider(height: 32),
            // Section 2: 公告轮播
            const Padding(
              padding: EdgeInsetsDirectional.only(top: 8.0, start: 8.0),
              child: Row(children: [Text('公告')]),
            ),
            _GymAnnouncementSection(gym: gym),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Gym gym;
  const _HeaderSection({required this.gym});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ImageAvatar(url: gym.logoUrl, size: 72, shape: BoxShape.rectangle, borderRadiusValue: 12),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gym.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              // 你之前的模型字段叫 shortIntro，而不是 info
              Text(gym.subTitle, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _GymAnnouncementSection extends StatefulWidget {
  final Gym gym;
  const _GymAnnouncementSection({super.key, required this.gym});

  @override
  State<_GymAnnouncementSection> createState() => _GymAnnouncementSectionState();
}

class _GymAnnouncementSectionState extends State<_GymAnnouncementSection> {
  @override
  Widget build(BuildContext context) {
    final List<String>? announcements = widget.gym.announcements;
    final double height = MediaQuery.sizeOf(context).height;

    if (announcements == null || announcements.isEmpty) {
      return const SizedBox(); // 没有公告时不渲染任何内容
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: CarouselView(
        scrollDirection: Axis.horizontal,
        itemExtent: 330,
        shrinkExtent: 330,
        children: announcements.map((text) => _AnnouncementCard(content: text)).toList(),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final String content;
  const _AnnouncementCard({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.campaign, size: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(content, style: theme.textTheme.bodyLarge, maxLines: 4, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

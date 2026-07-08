import 'package:flutter/material.dart';

import '../../../core/widgets/user_profile_avatar.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.greeting,
    required this.displayName,
    required this.onProfileTap,
    this.photoUrl,
    super.key,
  });

  final String greeting;
  final String? displayName;
  final String? photoUrl;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final initial = displayName == null || displayName!.isEmpty
        ? 'S'
        : displayName![0].toUpperCase();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: Theme.of(context).textTheme.bodySmall),
              Text(
                'Every Rupee Counts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: 'Open settings',
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkResponse(
              onTap: onProfileTap,
              customBorder: const CircleBorder(),
              child: UserProfileAvatar(
                initial: initial,
                photoUrl: photoUrl,
                dimension: 36,
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

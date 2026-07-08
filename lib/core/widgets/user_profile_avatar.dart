import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class UserProfileAvatar extends StatelessWidget {
  const UserProfileAvatar({
    required this.initial,
    this.photoUrl,
    this.dimension = 40,
    this.textStyle,
    super.key,
  });

  final String initial;
  final String? photoUrl;
  final double dimension;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final imageUrl = photoUrl?.trim();

    return ClipOval(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.mint, AppColors.mintDark],
          ),
        ),
        child: SizedBox.square(
          dimension: dimension,
          child: imageUrl == null || imageUrl.isEmpty
              ? _AvatarInitial(initial: initial, textStyle: textStyle)
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      _AvatarInitial(initial: initial, textStyle: textStyle),
                ),
        ),
      ),
    );
  }
}

class _AvatarInitial extends StatelessWidget {
  const _AvatarInitial({required this.initial, this.textStyle});

  final String initial;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style:
            textStyle ??
            Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

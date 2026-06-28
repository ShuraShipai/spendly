import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PennyMark extends StatelessWidget {
  const PennyMark({this.size = 120, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final eyeSize = size * 0.035;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: size * 0.07,
            child: Container(
              width: size * 0.5,
              height: size * 0.08,
              decoration: BoxDecoration(
                color: AppColors.mintDark.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              color: AppColors.coin,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.coinBorder,
                width: size * 0.03,
              ),
            ),
          ),
          Positioned(
            top: size * 0.28,
            child: Icon(
              Icons.currency_rupee_rounded,
              size: size * 0.2,
              color: AppColors.warning,
            ),
          ),
          Positioned(
            top: size * 0.48,
            left: size * 0.4,
            child: _Eye(size: eyeSize),
          ),
          Positioned(
            top: size * 0.48,
            right: size * 0.4,
            child: _Eye(size: eyeSize),
          ),
          Positioned(
            top: size * 0.58,
            child: SizedBox(
              width: size * 0.22,
              height: size * 0.1,
              child: CustomPaint(painter: _SmilePainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.coinInk,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(dimension: size),
    );
  }
}

class _SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.coinInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.25)
      ..quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width,
        size.height * 0.25,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

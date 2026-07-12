import 'package:flutter/material.dart';

import '../theme/geoprag_colors.dart';

/// Variante de contraste da marca, conforme seção 01 do guia:
/// [dark] para uso sobre fundos claros, [light] para uso sobre fundos
/// escuros/verdes (ex.: tela de login, header da sidebar).
enum GeopragMarkVariant { dark, light }

/// A gota estilizada com linha de água interna — o símbolo do GeoPrag.
/// Não literaliza o inseto (borrachudo); remete a córrego e controle
/// biológico, conforme descrito no guia de marca.
class GeopragMark extends StatelessWidget {
  final double size;
  final GeopragMarkVariant variant;

  const GeopragMark({
    super.key,
    this.size = 32,
    this.variant = GeopragMarkVariant.dark,
  });

  @override
  Widget build(BuildContext context) {
    final dropColor = variant == GeopragMarkVariant.dark
        ? GeopragColors.green900
        : GeopragColors.white;
    final lineColor = variant == GeopragMarkVariant.dark
        ? GeopragColors.white
        : GeopragColors.green900;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DropletPainter(dropColor: dropColor, lineColor: lineColor),
      ),
    );
  }
}

/// Marca completa (símbolo + wordmark "geoprag"), como no guia (seção 01).
class GeopragLogo extends StatelessWidget {
  final double markSize;
  final GeopragMarkVariant variant;

  const GeopragLogo({
    super.key,
    this.markSize = 28,
    this.variant = GeopragMarkVariant.dark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = variant == GeopragMarkVariant.dark
        ? const Color(0xFF14181B)
        : GeopragColors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GeopragMark(size: markSize, variant: variant),
        SizedBox(width: markSize * 0.4),
        Text(
          'geoprag',
          style: TextStyle(
            fontSize: markSize * 0.82,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _DropletPainter extends CustomPainter {
  final Color dropColor;
  final Color lineColor;

  const _DropletPainter({required this.dropColor, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final dropPath = Path()
      ..moveTo(w * 0.5, 0)
      ..cubicTo(w * 0.5, h * 0.18, w * 0.94, h * 0.48, w * 0.94, h * 0.66)
      ..arcToPoint(
        Offset(w * 0.06, h * 0.66),
        radius: Radius.circular(w * 0.47),
        clockwise: true,
      )
      ..cubicTo(w * 0.06, h * 0.48, w * 0.5, h * 0.18, w * 0.5, 0)
      ..close();

    canvas.drawPath(dropPath, Paint()..color = dropColor);

    final linePath = Path()
      ..moveTo(w * 0.26, h * 0.64)
      ..quadraticBezierTo(w * 0.5, h * 0.76, w * 0.74, h * 0.64);

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.07
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _DropletPainter oldDelegate) {
    return oldDelegate.dropColor != dropColor || oldDelegate.lineColor != lineColor;
  }
}

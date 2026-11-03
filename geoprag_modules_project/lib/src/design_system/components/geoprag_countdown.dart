import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/geoprag_colors.dart';

/// Contador regressivo em destaque ("Expira em MM:SS"), usado nas telas de
/// verificação de código dos fluxos de recuperação de senha (janela de 15
/// minutos definida na política de recuperação de senhas).
class GeopragCountdown extends StatefulWidget {
  final Duration duration;
  final VoidCallback onExpired;

  const GeopragCountdown({
    super.key,
    required this.duration,
    required this.onExpired,
  });

  @override
  State<GeopragCountdown> createState() => _GeopragCountdownState();
}

class _GeopragCountdownState extends State<GeopragCountdown> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    if (_remaining.inSeconds <= 1) {
      timer.cancel();
      setState(() => _remaining = Duration.zero);
      widget.onExpired();
      return;
    }
    setState(() => _remaining -= const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: GeopragColors.statusDenuncia.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Expira em $minutes:$seconds',
        style: const TextStyle(
          color: GeopragColors.statusDenuncia,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/geoprag_colors.dart';

/// Regra de força de senha exibida na checklist de recriação de senha.
class GeopragPasswordRule {
  final String label;
  final bool Function(String password) isSatisfied;

  const GeopragPasswordRule({required this.label, required this.isSatisfied});

  static final minLength = GeopragPasswordRule(
    label: 'Mínimo 10 caracteres',
    isSatisfied: (password) => password.length >= 10,
  );

  static final upperAndNumber = GeopragPasswordRule(
    label: 'Letra maiúscula e número',
    isSatisfied: (password) =>
        password.contains(RegExp(r'[A-Z]')) && password.contains(RegExp(r'[0-9]')),
  );

  static List<GeopragPasswordRule> defaults() => [minLength, upperAndNumber];
}

/// Checklist de requisitos de senha forte, conforme telas de "recriação de
/// senha" dos três fluxos de recuperação. Marca em verde os requisitos já
/// cumpridos pelo valor digitado em [password].
class GeopragPasswordRequirements extends StatelessWidget {
  final String password;
  final List<GeopragPasswordRule>? rules;

  const GeopragPasswordRequirements({super.key, required this.password, this.rules});

  bool get allSatisfied =>
      (rules ?? GeopragPasswordRule.defaults()).every((r) => r.isSatisfied(password));

  @override
  Widget build(BuildContext context) {
    final activeRules = rules ?? GeopragPasswordRule.defaults();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: activeRules.map((rule) {
        final satisfied = rule.isSatisfied(password);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                satisfied ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: satisfied ? GeopragColors.statusEmDia : Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Text(
                rule.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: satisfied ? GeopragColors.statusEmDia : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

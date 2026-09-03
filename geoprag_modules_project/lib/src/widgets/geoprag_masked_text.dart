import 'package:flutter/material.dart';

/// Exibe um conteúdo textual sensível (CPF, e-mail, etc.) parcialmente
/// oculto por padrão — mostrando só o início e o final —, com um botão para
/// alternar a exibição completa, no mesmo padrão de campos de senha.
class GeopragMaskedText extends StatefulWidget {
  final String value;
  final TextStyle? style;
  final int visibleStart;
  final int visibleEnd;

  const GeopragMaskedText({
    super.key,
    required this.value,
    this.style,
    this.visibleStart = 3,
    this.visibleEnd = 2,
  });

  @override
  State<GeopragMaskedText> createState() => _GeopragMaskedTextState();
}

class _GeopragMaskedTextState extends State<GeopragMaskedText> {
  bool _visivel = false;

  String get _mascarado {
    final valor = widget.value;
    final ocultos = valor.length - widget.visibleStart - widget.visibleEnd;
    if (ocultos <= 0) return valor;
    return valor.substring(0, widget.visibleStart) +
        '•' * ocultos +
        valor.substring(valor.length - widget.visibleEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            _visivel ? widget.value : _mascarado,
            style: widget.style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(_visivel ? Icons.visibility_off : Icons.visibility),
          iconSize: 18,
          tooltip: _visivel ? 'Ocultar' : 'Exibir',
          onPressed: () => setState(() => _visivel = !_visivel),
        ),
      ],
    );
  }
}

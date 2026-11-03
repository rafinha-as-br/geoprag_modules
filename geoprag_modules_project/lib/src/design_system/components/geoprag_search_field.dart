import 'package:flutter/material.dart';

/// Campo de busca padrão para o slot `filter` de `BaseListScreenModel` —
/// mantém seu próprio `TextEditingController` (estado efêmero de UI, não
/// vazado para o Cubit) e delega o texto digitado a [onChanged], que a tela
/// usa para filtrar a listagem de verdade (nunca decorativo).
class GeopragSearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const GeopragSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  @override
  State<GeopragSearchField> createState() => _GeopragSearchFieldState();
}

class _GeopragSearchFieldState extends State<GeopragSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: widget.onChanged,
    );
  }
}

import 'package:flutter/material.dart';

/// Dropdown de filtro padrão para o slot `filter` de `BaseListScreenModel` —
/// mantém a opção selecionada como estado efêmero de UI (não vazado para o
/// Cubit) e delega a escolha a [onChanged], que a tela usa para filtrar a
/// listagem de verdade (nunca decorativo).
class GeopragFilterDropdown extends StatefulWidget {
  final String label;
  final List<String> options;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const GeopragFilterDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<GeopragFilterDropdown> createState() => _GeopragFilterDropdownState();
}

class _GeopragFilterDropdownState extends State<GeopragFilterDropdown> {
  late String _selected = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: _selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final option in widget.options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selected = value);
        widget.onChanged(value);
      },
    );
  }
}

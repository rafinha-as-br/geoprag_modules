import 'package:flutter/material.dart';

/// Dropdown obrigatório genérico, reaproveitado pelos `BaseFormController`s
/// do pacote em vez de cada um reimplementar o mesmo
/// `DropdownButtonFormField` com validator de seleção obrigatória
/// (GEOPRAG-105).
DropdownButtonFormField<String> dropdownObrigatorio({
  required String? valor,
  required List<DropdownMenuItem<String>> items,
  required ValueChanged<String?> onChanged,
  required String mensagemErro,
}) => DropdownButtonFormField<String>(
  initialValue: valor,
  items: items,
  onChanged: onChanged,
  validator: (valor) => valor == null ? mensagemErro : null,
);

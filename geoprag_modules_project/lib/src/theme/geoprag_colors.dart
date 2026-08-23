import 'package:flutter/material.dart';

/// Paleta oficial da identidade visual do GeoPrag (Guia de marca V1).
///
/// Verde institucional é a base da marca; azul é o suporte hídrico.
/// As cores funcionais (verde/vermelho/amarelo) carregam o significado de
/// status do produto e não devem ser substituídas por tons decorativos.
class GeopragColors {
  GeopragColors._();

  // Marca
  static const Color green900 = Color(0xFF17392C);
  static const Color green800 = Color(0xFF1F4D3D);
  static const Color green500 = Color(0xFF4A8F6A);
  static const Color blue600 = Color(0xFF2F6690);
  static const Color neutralLight = Color(0xFFEEF2EE);

  // Funcional — status do produto
  static const Color statusEmDia = Color(0xFF2F7A58);
  static const Color statusAtrasado = Color(0xFFC0392B);
  static const Color statusDenuncia = Color(0xFFE0A300);

  static const Color white = Color(0xFFFFFFFF);
}

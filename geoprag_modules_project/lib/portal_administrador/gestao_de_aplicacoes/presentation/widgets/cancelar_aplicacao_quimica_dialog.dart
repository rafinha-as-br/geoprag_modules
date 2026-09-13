import 'package:flutter/material.dart';

/// Confirmação de "Cancelar Aplicação Química" (GEOPRAG-109): encerra o
/// ciclo vigente de um ponto ativo, levando-o a Inativa imediatamente.
///
/// Ordem deliberada — bloco verde "Nada é apagado" **antes** do âmbar "O
/// que muda": desfaz a impressão destrutiva do nome da ação antes de listar
/// as consequências reais. O botão secundário nunca se chama "Cancelar" —
/// seria ambíguo com a própria ação (cancelar o diálogo vs. cancelar a
/// aplicação química).
///
/// Devolve `true` se confirmado, `false` se voltar.
Future<bool> showCancelarAplicacaoQuimicaDialog(BuildContext context) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancelar aplicação química'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BlocoDeAviso(
              cor: Colors.green,
              titulo: 'Nada é apagado',
              texto: 'O histórico de aplicações já realizadas neste ponto é '
                  'preservado.',
            ),
            const SizedBox(height: 12),
            _BlocoDeAviso(
              cor: Colors.orange,
              titulo: 'O que muda',
              texto: 'O ponto passa para Inativa imediatamente, encerrando o '
                  'ciclo vigente. Datas futuras já agendadas são canceladas.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Voltar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Cancelar aplicação química'),
        ),
      ],
    ),
  );
  return confirmado ?? false;
}

class _BlocoDeAviso extends StatelessWidget {
  const _BlocoDeAviso({
    required this.cor,
    required this.titulo,
    required this.texto,
  });

  final MaterialColor cor;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.shade50,
        border: Border.all(color: cor.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(color: cor.shade900, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(texto, style: TextStyle(color: cor.shade900, fontSize: 13)),
        ],
      ),
    );
  }
}

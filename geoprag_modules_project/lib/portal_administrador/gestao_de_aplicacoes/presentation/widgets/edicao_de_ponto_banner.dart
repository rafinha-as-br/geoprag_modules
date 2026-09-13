import 'package:flutter/material.dart';

/// Faixa que explica por que a edição completa está liberada ou travada
/// (GEOPRAG-109) — substitui o `EditWindowBanner` do wireframe original
/// (contador regressivo de 15 minutos), decisão de Rafinha de 2026-08-30:
/// sem contador, só a condição atual do cadastro.
class EdicaoDePontoBanner extends StatelessWidget {
  const EdicaoDePontoBanner({super.key, required this.liberada});

  final bool liberada;

  @override
  Widget build(BuildContext context) {
    final cor = liberada ? Colors.green : Colors.orange;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.shade50,
        border: Border.all(color: cor.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            liberada ? Icons.lock_open : Icons.lock_outline,
            color: cor.shade800,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  liberada ? 'Edição liberada' : 'Cadastro travado',
                  style: TextStyle(color: cor.shade900, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  liberada
                      ? 'Este ponto ainda não tem agendamento nem execução '
                            'registrada — todos os campos podem ser editados.'
                      : 'Este ponto já teve um agendamento ou execução '
                            'registrada em algum momento. A partir daí, o '
                            'cadastro trava permanentemente — só o nome '
                            'continua editável.',
                  style: TextStyle(color: cor.shade900, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

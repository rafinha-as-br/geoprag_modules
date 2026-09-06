import 'package:flutter/material.dart';

/// Um aplicador candidato a receber um ponto, com o suficiente para o
/// `AtribuirAplicadorDialog` decidir o que mostrar — sem acoplar este
/// diálogo ao ViewModel do módulo de Aplicadores.
class AplicadorParaAtribuir {
  final String id;
  final String nome;
  final String bairro;

  /// Quantos pontos já estão atribuídos a este aplicador — usado para
  /// destacar em âmbar quando a carga já está alta (GEOPRAG-110).
  final int quantidadePontosAtribuidos;

  const AplicadorParaAtribuir({
    required this.id,
    required this.nome,
    required this.bairro,
    required this.quantidadePontosAtribuidos,
  });
}

/// A partir de quantos pontos já atribuídos o aplicador é destacado em
/// âmbar na lista de busca — a issue pede "destaque se a contagem for
/// alta" sem definir o número; 5 é um valor de partida razoável para o
/// tamanho de município deste projeto, documentado aqui para ser fácil de
/// ajustar quando houver dado real de carga de trabalho.
const int limiteDeCargaAltaDoAplicador = 5;

/// Busca por nome + escolhe um aplicador para atribuir a um ponto
/// (GEOPRAG-110). Devolve o `id` escolhido via `Navigator.pop`, ou `null`
/// se cancelado.
class AtribuirAplicadorDialog extends StatefulWidget {
  const AtribuirAplicadorDialog({super.key, required this.aplicadores});

  final List<AplicadorParaAtribuir> aplicadores;

  @override
  State<AtribuirAplicadorDialog> createState() =>
      _AtribuirAplicadorDialogState();
}

class _AtribuirAplicadorDialogState extends State<AtribuirAplicadorDialog> {
  String _busca = '';
  String? _selecionadoId;

  List<AplicadorParaAtribuir> get _filtrados {
    if (_busca.isEmpty) return widget.aplicadores;
    final buscaLower = _busca.toLowerCase();
    return widget.aplicadores
        .where((a) => a.nome.toLowerCase().contains(buscaLower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;
    return AlertDialog(
      title: const Text('Atribuir aplicador'),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nome...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (valor) => setState(() => _busca = valor.trim()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtrados.isEmpty
                  ? const Center(child: Text('Nenhum aplicador encontrado.'))
                  : ListView.builder(
                      itemCount: filtrados.length,
                      itemBuilder: (context, index) {
                        final aplicador = filtrados[index];
                        final cargaAlta =
                            aplicador.quantidadePontosAtribuidos >=
                            limiteDeCargaAltaDoAplicador;
                        final selecionado = _selecionadoId == aplicador.id;
                        return ListTile(
                          selected: selecionado,
                          onTap: () =>
                              setState(() => _selecionadoId = aplicador.id),
                          leading: Icon(
                            selecionado
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                          ),
                          title: Text(aplicador.nome),
                          subtitle: Text(
                            '${aplicador.bairro} · '
                            '${aplicador.quantidadePontosAtribuidos} ponto(s) atribuído(s)',
                            style: TextStyle(
                              color: cargaAlta
                                  ? Colors.orange.shade800
                                  : Colors.black54,
                              fontWeight: cargaAlta
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _selecionadoId == null
              ? null
              : () => Navigator.of(context).pop(_selecionadoId),
          child: const Text('Atribuir'),
        ),
      ],
    );
  }
}

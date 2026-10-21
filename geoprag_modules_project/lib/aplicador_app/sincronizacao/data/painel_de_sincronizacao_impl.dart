import '../../local/item_da_outbox.dart';
import '../../local/registro_da_fila.dart';
import '../core/painel_de_sincronizacao.dart';
import '../core/registro_sincronizavel.dart';
import 'servico_de_sincronizacao_acompanhado.dart';

/// [PainelDeSincronizacao] sobre os registros da outbox e o
/// [ServicoDeSincronizacaoAcompanhado].
class PainelDeSincronizacaoImpl implements PainelDeSincronizacao {
  PainelDeSincronizacaoImpl({
    required RegistrosDaFilaDao registros,
    required ServicoDeSincronizacaoAcompanhado servico,
  }) : _registros = registros,
       _servico = servico;

  final RegistrosDaFilaDao _registros;
  final ServicoDeSincronizacaoAcompanhado _servico;

  @override
  Stream<void> get aoMudar => _servico.aoMudar;

  @override
  Future<SituacaoDaSincronizacao> carregar() async {
    final registros = await _registros.registrosParaExibir();
    return SituacaoDaSincronizacao(
      registros: [
        for (final registro in registros)
          RegistroSincronizavel(
            id: registro.item.id,
            pontoId: registro.item.pontoId,
            pontoNome: registro.pontoNome,
            registradoEm: registro.item.criadoEm,
            situacao: _situacaoDe(registro.item.estado),
            motivo: registro.item.estado == EstadoDoItemDaOutbox.rejeitado
                ? motivoLegivelDaRejeicao(registro.item.ultimoErro)
                : null,
          ),
      ],
      ultimaSincronizacao: await _servico.ultimaBemSucedida(),
    );
  }

  @override
  Future<bool> sincronizarAgora() async =>
      (await _servico.sincronizar()).concluida;

  static SituacaoDoRegistro _situacaoDe(EstadoDoItemDaOutbox estado) =>
      switch (estado) {
        EstadoDoItemDaOutbox.pendente ||
        EstadoDoItemDaOutbox.enviando => SituacaoDoRegistro.pendente,
        EstadoDoItemDaOutbox.enviado => SituacaoDoRegistro.enviado,
        EstadoDoItemDaOutbox.rejeitado => SituacaoDoRegistro.rejeitado,
      };
}

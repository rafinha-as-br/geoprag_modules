import 'dart:io';

import 'package:geoprag_modules/aplicador_app/local/local.dart';
import 'package:geoprag_modules/src/api/sync/registro_dtos.dart';
import 'package:geoprag_modules/src/entities/aplicacao.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Banco SQLite em memória (sem aparelho) com o esquema real do app.
Future<BancoLocal> abrirBancoEmMemoria({
  List<Migracao> migracoes = migracoesDoEsquema,
}) {
  sqfliteFfiInit();
  return BancoLocal.abrir(
    fabrica: databaseFactoryFfi,
    caminho: inMemoryDatabasePath,
    migracoes: migracoes,
  );
}

/// Banco em arquivo temporário, para testar fechar e reabrir.
Future<({String caminho, Directory pasta})> arquivoTemporarioDeBanco() async {
  sqfliteFfiInit();
  final pasta = await Directory.systemTemp.createTemp('geoprag_banco_');
  return (caminho: '${pasta.path}/geoprag.db', pasta: pasta);
}

Future<BancoLocal> abrirBancoEmArquivo(
  String caminho, {
  List<Migracao> migracoes = migracoesDoEsquema,
}) => BancoLocal.abrir(
  fabrica: databaseFactoryFfi,
  caminho: caminho,
  migracoes: migracoes,
);

final DateTime agoraDeTeste = DateTime.utc(2026, 10, 20, 15);

Subponto subpontoDeTeste(
  String id, {
  DateTime? realizadoEm,
  double latitude = -26.9,
  double longitude = -48.9,
}) => Subponto(
  id: id,
  latitude: latitude,
  longitude: longitude,
  realizadoEm: realizadoEm ?? agoraDeTeste,
  registradoEm: (realizadoEm ?? agoraDeTeste).add(const Duration(minutes: 1)),
);

PontoDeAplicacao pontoDeTeste(
  String id, {
  String nome = 'Córrego Gasparinho',
  String? aplicadorId = 'aplicador-1',
  EstadoPontoDeAplicacao estado = EstadoPontoDeAplicacao.ativa,
  bool comAgendamento = true,
  List<Subponto> subpontos = const [],
}) => PontoDeAplicacao(
  id: id,
  nome: nome,
  identificador: '#$id',
  bairro: 'Centro',
  endereco: 'Rua das Flores',
  numeroReferencia: 'Ao lado da ponte',
  descricaoDoTrecho: 'Margem esquerda',
  larguraMetros: 3.5,
  profundidadeMetros: 0.8,
  velocidadeMetrosPorSegundo: 0.4,
  dosagemMl: 120,
  distanciaEntreSubpontosMetros: 150,
  quantidadeDeSubpontos: 3,
  aplicadorId: aplicadorId,
  estado: estado,
  estadoAnterior: null,
  agendamento: comAgendamento
      ? Agendamento(
          dataInicio: DateTime(2026, 10, 25),
          intervaloDias: 7,
          quantidadeRecorrencias: 2,
          datas: [
            DataAgendada(id: '$id-d1', data: DateTime(2026, 10, 25)),
            DataAgendada(
              id: '$id-d2',
              data: DateTime(2026, 11, 1),
              status: StatusDataAgendada.concluida,
            ),
          ],
        )
      : null,
  subpontos: subpontos,
);

Aplicacao aplicacaoDeTeste(
  String id, {
  String pontoId = 'ponto-1',
  List<Subponto> subpontos = const [],
}) => Aplicacao(
  id: id,
  pontoId: pontoId,
  aplicadorId: 'aplicador-1',
  dataAgendadaId: '$pontoId-d1',
  produtoId: 'produto-1',
  realizadoEm: DateTime(2026, 10, 25, 9, 30),
  localizacao: const LocalizacaoCapturada(latitude: -26.91, longitude: -48.92),
  subpontos: subpontos,
);

/// Item da outbox de um subponto da [aplicacao], como o repositório o criaria.
ItemDaOutbox itemDoSubponto(
  Aplicacao aplicacao,
  Subponto subponto, {
  DateTime? criadoEm,
}) => ItemDaOutbox.paraSubponto(
  ItemDeRegistroDto(
    id: subponto.id,
    aplicacaoId: aplicacao.id,
    pontoId: aplicacao.pontoId,
    dataAgendadaId: aplicacao.dataAgendadaId,
    produtoId: aplicacao.produtoId,
    latitude: subponto.latitude,
    longitude: subponto.longitude,
    realizadoEm: subponto.realizadoEm,
  ),
  criadoEm: criadoEm ?? agoraDeTeste,
);

/// Versão do esquema gravada no arquivo (`PRAGMA user_version`).
Future<int> versaoDoBanco(Database db) async {
  final linhas = await db.rawQuery('PRAGMA user_version');
  return linhas.single['user_version']! as int;
}

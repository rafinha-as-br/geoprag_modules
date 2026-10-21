/// Uma etapa do esquema do banco local: os comandos que levam o banco da
/// versão anterior à [versao].
class Migracao {
  const Migracao(this.versao, this.comandos);

  /// Versão do esquema depois desta migração (1, 2, 3…).
  final int versao;
  final List<String> comandos;
}

/// Nome do arquivo do banco no aparelho.
const String nomeDoArquivoDoBanco = 'geoprag.db';

/// Migrações do banco local, em ordem de versão. Banco novo roda todas; banco
/// existente roda só as que ainda não rodou. **Nunca edite uma migração já
/// publicada**: acrescente a próxima.
///
/// Instantes são texto ISO-8601 em UTC (precisão total); as colunas `*_ms`
/// guardam o mesmo instante em milissegundos para ordenar sem depender do
/// offset.
const List<Migracao> migracoesDoEsquema = [
  Migracao(1, [
    '''
CREATE TABLE pontos (
  id TEXT PRIMARY KEY,
  identificador TEXT NOT NULL,
  nome TEXT NOT NULL,
  bairro TEXT NOT NULL,
  endereco TEXT NOT NULL,
  numero_referencia TEXT NOT NULL,
  descricao_do_trecho TEXT NOT NULL,
  largura_metros REAL NOT NULL,
  profundidade_metros REAL NOT NULL,
  velocidade_metros_por_segundo REAL NOT NULL,
  dosagem_ml REAL NOT NULL,
  distancia_entre_subpontos_metros REAL NOT NULL,
  quantidade_de_subpontos INTEGER NOT NULL,
  aplicador_id TEXT,
  estado TEXT NOT NULL,
  estado_anterior TEXT,
  agendamento_data_inicio TEXT,
  agendamento_intervalo_dias INTEGER,
  agendamento_quantidade_recorrencias INTEGER
)''',
    'CREATE INDEX idx_pontos_aplicador ON pontos (aplicador_id)',
    '''
CREATE TABLE datas_agendadas (
  id TEXT PRIMARY KEY,
  ponto_id TEXT NOT NULL REFERENCES pontos (id) ON DELETE CASCADE,
  data TEXT NOT NULL,
  status TEXT NOT NULL,
  ordem INTEGER NOT NULL
)''',
    'CREATE INDEX idx_datas_agendadas_ponto ON datas_agendadas (ponto_id, ordem)',
    // Sem chave estrangeira para `pontos`: a aplicação feita em campo sobrevive
    // ao ponto, que o servidor pode retirar do aplicador.
    '''
CREATE TABLE aplicacoes (
  id TEXT PRIMARY KEY,
  ponto_id TEXT NOT NULL,
  aplicador_id TEXT NOT NULL,
  data_agendada_id TEXT NOT NULL,
  produto_id TEXT NOT NULL,
  realizado_em TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL
)''',
    'CREATE INDEX idx_aplicacoes_ponto ON aplicacoes (ponto_id)',
    // `aplicacao_id` nulo: subponto que veio do servidor no pull.
    '''
CREATE TABLE subpontos (
  id TEXT PRIMARY KEY,
  ponto_id TEXT NOT NULL,
  aplicacao_id TEXT REFERENCES aplicacoes (id),
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  realizado_em TEXT NOT NULL,
  realizado_em_ms INTEGER NOT NULL,
  registrado_em TEXT NOT NULL
)''',
    'CREATE INDEX idx_subpontos_ponto ON subpontos (ponto_id, realizado_em_ms)',
    'CREATE INDEX idx_subpontos_aplicacao ON subpontos (aplicacao_id)',
    '''
CREATE TABLE outbox (
  id TEXT PRIMARY KEY,
  tipo TEXT NOT NULL,
  ponto_id TEXT NOT NULL,
  payload TEXT NOT NULL,
  estado TEXT NOT NULL,
  tentativas INTEGER NOT NULL DEFAULT 0,
  ultimo_erro TEXT,
  criado_em TEXT NOT NULL,
  criado_em_ms INTEGER NOT NULL,
  ultima_tentativa_em TEXT
)''',
    'CREATE INDEX idx_outbox_estado ON outbox (estado, criado_em_ms)',
    'CREATE INDEX idx_outbox_ponto ON outbox (ponto_id)',
  ]),
];

/// Nomes das tabelas do esquema, para os DAOs não repetirem texto solto.
abstract final class Tabelas {
  static const String pontos = 'pontos';
  static const String datasAgendadas = 'datas_agendadas';
  static const String aplicacoes = 'aplicacoes';
  static const String subpontos = 'subpontos';
  static const String outbox = 'outbox';
}

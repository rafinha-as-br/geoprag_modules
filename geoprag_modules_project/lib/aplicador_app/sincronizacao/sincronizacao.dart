/// Envio da outbox, pull e reconciliação dos pontos (GEOPRAG-190 e 202). Fica
/// fora de `geoprag_modules.dart`: depende do `connectivity_plus` e só o App
/// Aplicador o usa.
library;

export 'core/monitor_de_conexao.dart';
export 'core/resultado_da_sincronizacao.dart';
export 'core/servico_de_sincronizacao.dart';
export 'data/cursor_do_pull.dart';
export 'data/dispositivo_id.dart';
export 'data/gatilhos_de_sincronizacao.dart';
export 'data/espera_crescente.dart';
export 'data/monitor_de_conexao_connectivity.dart';
export 'data/reconciliador_do_pull.dart';
export 'data/servico_de_sincronizacao_impl.dart';

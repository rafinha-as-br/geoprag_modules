/// Envio da outbox ao servidor (GEOPRAG-190). Fica fora de
/// `geoprag_modules.dart`: depende do `connectivity_plus` e só o App Aplicador
/// o usa.
library;

export 'core/monitor_de_conexao.dart';
export 'core/servico_de_sincronizacao.dart';
export 'data/dispositivo_id.dart';
export 'data/gatilhos_de_sincronizacao.dart';
export 'data/monitor_de_conexao_connectivity.dart';
export 'data/servico_de_sincronizacao_impl.dart';

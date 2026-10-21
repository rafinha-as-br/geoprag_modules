/// Envio da outbox, pull e reconciliação dos pontos (GEOPRAG-190 e 202). Fica
/// fora de `geoprag_modules.dart`: depende do `connectivity_plus` e só o App
/// Aplicador o usa.
library;

export 'core/monitor_de_conexao.dart';
export 'core/painel_de_sincronizacao.dart';
export 'core/registro_sincronizavel.dart';
export 'core/resultado_da_sincronizacao.dart';
export 'core/servico_de_sincronizacao.dart';
export 'data/dispositivo_id.dart';
export 'data/gatilhos_de_sincronizacao.dart';
export 'data/espera_crescente.dart';
export 'data/monitor_de_conexao_connectivity.dart';
export 'data/painel_de_sincronizacao_impl.dart';
export 'data/reconciliador_do_pull.dart';
export 'data/servico_de_sincronizacao_acompanhado.dart';
export 'data/servico_de_sincronizacao_impl.dart';
export 'data/ultima_sincronizacao.dart';
export 'presentation/botao_sincronizar_agora.dart';
export 'presentation/resumo_da_sincronizacao.dart';
export 'presentation/sincronizacao_cubit.dart';
export 'presentation/sincronizacao_screen.dart';
export 'presentation/sincronizacao_state.dart';
export 'presentation/textos_da_sincronizacao.dart';

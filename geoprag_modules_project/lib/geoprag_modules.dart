library geoprag_modules;

export 'src/application/admin_portal_runtime.dart';
export 'src/features/atrasos/atrasos.dart';
export 'src/features/auditoria/auditoria.dart';
export 'src/features/homologacao/homologacao.dart';

export 'src/design_system/theme/geoprag_colors.dart';
export 'src/design_system/theme/geoprag_status.dart';
export 'src/design_system/theme/geoprag_theme.dart';
export 'src/design_system/components/geoprag_logo.dart';
export 'src/design_system/components/geoprag_status_badge.dart';
export 'src/design_system/components/geoprag_otp_input.dart';
export 'src/design_system/components/geoprag_countdown.dart';
export 'src/design_system/components/geoprag_password_requirements.dart';
export 'src/design_system/components/geoprag_cpf_input.dart';
export 'src/design_system/components/geoprag_sexo_input.dart';
export 'src/design_system/components/geoprag_data_nascimento_input.dart';
export 'src/design_system/components/geoprag_numero_inteiro_input.dart';
export 'src/design_system/components/geoprag_numero_decimal_input.dart';
export 'src/design_system/components/geoprag_texto_input.dart';
export 'src/core/authorization/capacidade.dart';

export 'aplicador_app/core/aplicador_navigator.dart';
export 'aplicador_app/auth/autenticacao.dart';
export 'aplicador_app/aplicacoes/aplicacoes.dart';
export 'aplicador_app/inventory/inventario.dart';
export 'aplicador_app/reports/denuncia_de_foco.dart';
export 'aplicador_app/tenant/tenant.dart';
// aplicador_app/local/local.dart (SQLite) fica de fora de propósito: o portal web
// importa este arquivo e não deve carregar o sqflite. Os apps importam direto.

export 'portal_administrador/autenticacao/core/admin_navigator.dart';
export 'portal_administrador/autenticacao/autenticacao.dart';
export 'portal_administrador/widgets/admin_scaffold.dart';
export 'portal_administrador/widgets/sidebar_menu.dart';
export 'portal_administrador/dashboard/dashboard.dart';
export 'portal_administrador/tenant/tenant.dart';
export 'src/features/aplicacoes/domain/ponto_de_aplicacao.dart';
export 'src/core/network/api_client.dart';
export 'src/core/network/api_client_provider.dart';
export 'src/core/network/api_config.dart';
export 'src/core/network/api_exceptions.dart';
export 'src/core/security/sessao_de_tokens.dart';
export 'src/core/security/armazenamento_seguro.dart';
export 'src/core/security/sessao_segura.dart';
export 'src/features/aplicacoes/domain/atraso_de_aplicacao.dart';
export 'portal_administrador/gestao_de_aplicacoes/gestao_de_aplicacoes.dart';
export 'portal_administrador/gerenciamento_de_aplicadores/gerenciamento_de_aplicadores.dart';
export 'portal_administrador/gerenciamento_de_administradores/gerenciamento_de_administradores.dart';
export 'portal_administrador/inventory_and_bidding/controle_de_estoque.dart';
export 'portal_administrador/distributions/distribuicoes.dart';
export 'portal_administrador/reports_management/gestao_de_denuncias.dart';

export 'src/features/aplicacoes/domain/aplicacao.dart';
export 'src/core/ids/gerador_de_id.dart';

// Camada de API: DTOs de sincronização (envio em lote e pull) e mapeadores (GEOPRAG-188).
export 'src/features/sincronizacao/data/registro_dtos.dart';
export 'src/features/sincronizacao/data/pull_dtos.dart';
export 'src/features/sincronizacao/data/sync_mappers.dart';

// Camada de API: DTOs de autenticação e seus mapeadores (GEOPRAG-186).
export 'src/features/autenticacao/data/usuario_dto.dart';
export 'src/features/autenticacao/data/login_dtos.dart';
export 'src/features/autenticacao/data/auth_mappers.dart';

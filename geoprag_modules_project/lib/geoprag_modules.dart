library geoprag_modules;

export 'src/theme/geoprag_colors.dart';
export 'src/theme/geoprag_status.dart';
export 'src/theme/geoprag_theme.dart';
export 'src/widgets/geoprag_logo.dart';
export 'src/widgets/geoprag_status_badge.dart';
export 'src/widgets/geoprag_otp_input.dart';
export 'src/widgets/geoprag_countdown.dart';
export 'src/widgets/geoprag_password_requirements.dart';
export 'src/widgets/geoprag_cpf_input.dart';
export 'src/widgets/geoprag_sexo_input.dart';
export 'src/widgets/geoprag_data_nascimento_input.dart';
export 'src/widgets/geoprag_numero_inteiro_input.dart';
export 'src/widgets/geoprag_numero_decimal_input.dart';
export 'src/widgets/geoprag_texto_input.dart';
export 'src/permissions/capacidade.dart';

export 'aplicador_app/core/aplicador_navigator.dart';
export 'aplicador_app/auth/autenticacao.dart';
export 'aplicador_app/aplicacoes/aplicacoes.dart';
export 'aplicador_app/inventory/inventario.dart';
export 'aplicador_app/reports/denuncia_de_foco.dart';
export 'aplicador_app/tenant/tenant.dart';

export 'portal_administrador/autenticacao/core/admin_navigator.dart';
export 'portal_administrador/autenticacao/autenticacao.dart';
export 'portal_administrador/widgets/admin_scaffold.dart';
export 'portal_administrador/widgets/sidebar_menu.dart';
export 'portal_administrador/dashboard/dashboard.dart';
export 'portal_administrador/tenant/tenant.dart';
export 'src/entities/ponto_de_aplicacao.dart';
export 'src/api/api_client.dart';
export 'src/api/api_client_provider.dart';
export 'src/api/api_config.dart';
export 'src/api/api_exceptions.dart';
export 'src/api/sessao_de_tokens.dart';
export 'src/api/armazenamento_seguro.dart';
export 'src/api/sessao_segura.dart';
export 'portal_administrador/gestao_de_aplicacoes/gestao_de_aplicacoes.dart';
export 'portal_administrador/gerenciamento_de_aplicadores/gerenciamento_de_aplicadores.dart';
export 'portal_administrador/gerenciamento_de_administradores/gerenciamento_de_administradores.dart';
export 'portal_administrador/inventory_and_bidding/controle_de_estoque.dart';
export 'portal_administrador/distributions/distribuicoes.dart';
export 'portal_administrador/reports_management/gestao_de_denuncias.dart';

export 'src/entities/aplicacao.dart';
export 'src/services/gerador_de_id.dart';

// Camada de API: DTOs de sincronização (envio em lote e pull) e mapeadores (GEOPRAG-188).
export 'src/api/sync/registro_dtos.dart';
export 'src/api/sync/pull_dtos.dart';
export 'src/api/sync/sync_mappers.dart';

// Camada de API: DTOs de autenticação e seus mapeadores (GEOPRAG-186).
export 'src/api/auth/usuario_dto.dart';
export 'src/api/auth/login_dtos.dart';
export 'src/api/auth/auth_mappers.dart';

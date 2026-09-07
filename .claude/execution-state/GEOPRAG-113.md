Estado: EM_EXECUÇÃO
Issue: GEOPRAG-113 — Contrato de trilha de auditoria de eventos (sem tela)
Repositório: geoprag_modules
Branch: feat/GEOPRAG-113-claude (nova, criada a partir de develop)

Objetivo: entidade EventoAuditoria (append-only) + interface
EventoAuditoriaRepository + mock em memória, contrato pronto para uma API
futura (GEOPRAG-114, sem repositório ainda). Sem tela — a emissão real fica
para GEOPRAG-38/109/110/101 e a issue do App Aplicador, conforme cada uma
landar.

Decisões de design:
- Entidade + interface + impl mock, todos em lib/src/auditoria/ (shared
  entre portal_administrador e aplicador_app, seguindo o precedente de
  TenantRepository em lib/src/entities/tenant_config.dart). Diferente do
  tenant, aqui um único impl mock serve os dois apps (sem fixture data
  divergente entre eles), então não duplico em core/data por app.
- autor: AutorEvento sealed (AutorUsuario{email,perfil} |
  AutorAplicadorEmCampo{aplicadorId}) — perfil como String solta, não
  AdminRole, para não acoplar lib/src a portal_administrador (mesmo cuidado
  do GEOPRAG-112).
- tipo: String livre (não enum) — os tipos concretos são decisão de quem
  emite (issues futuras), enumerar agora seria especulação.
- Repositório: só registrar() + listarTodos() — suficiente para testar que
  o mock acumula; qualquer query mais específica (por ponto, por lote) fica
  para quando a tela de histórico (fora de escopo aqui) precisar dela.
- Sem copyWith/== em EventoAuditoria — evento é criado uma vez e nunca
  mutado/comparado por valor no fluxo real.

Concluído:
- lib/src/auditoria/evento_auditoria.dart (AutorEvento sealed + EventoAuditoria,
  com assert de invariante dataHoraRegistro >= dataHoraOcorrencia)
- lib/src/auditoria/evento_auditoria_repository.dart (interface)
- lib/src/auditoria/evento_auditoria_repository_impl.dart (mock em memória,
  lista global mockEventosAuditoria, mesmo padrão de mockAdminAccounts)
- test/src/auditoria/evento_auditoria_repository_impl_test.dart (5 testes)

Autorevisão flutter-development-standards: sem violações.
Code review automatizado: /code-review sem achados; ponytail-review achou 1
(List.unmodifiable() em vez de .toList(), fora do padrão do repo) — corrigido.
Gate de qualidade: flutter analyze limpo; flutter test completo (727 testes)
passando.

Próxima ação: commit + push + abrir PR.

Estado: EM_EXECUÇÃO

Issue: GEOPRAG-128 — Centralizar títulos das App Bars das telas
Repo: geoprag_modules
Branch: feat/GEOPRAG-128-claude (nova, a partir de develop)

Causa raiz: `GeopragTheme.light()` (lib/src/theme/geoprag_theme.dart:52)
define `appBarTheme: AppBarTheme(..., centerTitle: false, ...)` — tema único
compartilhado por portal_administrador (web) e aplicador_app (mobile).
Confirmado via grep que nenhuma tela sobrescreve `centerTitle` individualmente
(única ocorrência do termo no lib/ é essa linha do tema) — trocar para
`true` centraliza o título em toda AppBar do app automaticamente, sem
precisar tocar tela por tela.

Fix: `centerTitle: false` → `centerTitle: true`.

Próxima ação: aplicar o fix, rodar testes (varredura por telas com AppBar já
cobertas por testes existentes), autorevisão/code review, commit.

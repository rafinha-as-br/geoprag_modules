# Changelog

Todas as mudanças notáveis deste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto segue o [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

## [0.1.0-rc.1] - 2026-09-12

Primeira pre-release do pacote.

### Adicionado
- Fluxos de autenticação (login, recuperação de senha, feedback de sucesso/falha, reconhecimento de tenant/prefeitura) para Portal Administrador e App Aplicador.
- Templates de tela reutilizáveis (lista/dashboard, detalhe, formulário, cartão, informativa) usados em todo o produto.
- Módulo de Gerenciamento de Administradores (cargos, criação restrita, desativação/reativação, promoção/rebaixamento).
- Renomeação de "Gestão de Aplicadores" para "Gerenciamento de Aplicadores"; terminologia "bairro/trecho" substituída por "ponto de aplicação"/"subponto".
- Endereço completo no cadastro de usuário, obrigatório para o Aplicador.
- Filtro por status e ações em massa no dashboard de Aplicadores.

### Corrigido
- Overflow e ausência de rolagem em telas de detalhe.

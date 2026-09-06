# Execution State — GEOPRAG-38

## Estado
EM_EXECUÇÃO

## Objetivo atual / contexto de retomada
Entidade unificada `PontoDeAplicacao` (+ `Subponto`, 5 estados com
invariantes) em `lib/src/entities/` e módulo
`portal_administrador/gestao_de_aplicacoes` com 4 telas, sobre os templates
Base*Screen. Concluídos: implementação, autorevisão, code review, gate de
qualidade (analyze limpo, 60 testes novos passando, zero regressão medida
contra a `develop`).

## Próxima ação
Commitar e dar push em geoprag_modules; depois espelhar rotas/navegação em
app_administrador (branch `feat/GEOPRAG-38-claude` lá também) e abrir os
dois PRs.

## Não repetir
- Não reaproveitar `feat/GEOPRAG-38` (branch antiga, escopo superado).
- Não migrar consumidores de `src/entities/aplicacao.dart` — ver bloqueios.
- Não adicionar widget test de tela que use `AdminScaffold`: o `SidebarMenu`
  dispara um assert do Flutter (ListTile dentro de ColoredBox) que já derruba
  74 testes na `develop`. Bug pré-existente, issue própria.

## Decisões técnicas
- Entidade fora do barrel raiz: `PontoDeAplicacao` colidiria com a classe
  homônima de `aplicador_app/application_points`.
- Repositório do portal com prefixo `Admin`, pelo mesmo motivo.
- Vazão é getter derivado; só os 3 parâmetros brutos são persistidos.
- Sem barra de ações na tela de detalhe: ativar/agendar/atribuir/desativar
  são da issue de ações individuais; botões inertes seriam decorativos.
- Alerta do dashboard = ponto `ativa` sem nenhuma execução registrada
  (interpretação de "atrasados sem registro" sem modelar agendamento).

## Bloqueios / decisões pendentes de Rafinha
- Unificação de `Aplicacao`: entregue a fusão conceitual na entidade nova,
  mas os 9 consumidores da `Aplicacao` legada (mapa_hidrologico e
  aplicador_app/applications) não foram migrados — são telas fora do escopo
  desta issue e "execuções realizadas" está declarado vazio aqui. Precisa da
  decisão dele sobre migrar em GEOPRAG-40 ou issue própria.

## Última atualização
2026-09-05

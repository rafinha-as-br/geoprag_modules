# GEOPRAG-109

Estado: EM_EXECUÇÃO
Repositório: geoprag_modules (+ app_administrador, rota `/aplicacoes/ponto/:id/editar`)
Branch: feat/GEOPRAG-109-claude, criada a partir de **feat/GEOPRAG-110-claude**
(que já inclui a 101) — decisão deliberada: o predicado `podeEditarCadastroCompleto`
depende do campo `agendamento` (adicionado na GEOPRAG-101) e reaproveita o
helper `_cancelarDatasPendentes` (GEOPRAG-101) e o padrão de ações
individuais já montado na GEOPRAG-110 (Cubit com `AcaoFeedback`/`processando`,
diálogos abertos pela tela, nunca pelo Cubit). Quando 101/110 mergearem, a
base deste PR pode ser re-apontada para develop.

## Objetivo atual / contexto de retomada
1. Predicado `podeEditarCadastroCompleto` no domínio: editável quando não há
   agendamento nem execução registrada (decisão de Rafinha 2026-08-30,
   substitui a janela de 15min do doc de objetivo original) — só o nome
   continua editável mesmo travado.
2. Tela de Edição (BaseFormScreen, mesmos campos da Criação — GEOPRAG-38):
   faixa verde "liberada" / âmbar "travada" + campos não-nome bloqueados
   quando travado.
3. Ação "Cancelar Aplicação Química" (só em Ativa): Ativa → Inativa
   imediato, preserva execuções, cancela datas pendentes do agendamento.
   Diálogo: bloco verde "Nada é apagado" ANTES do âmbar "O que muda"
   (ordem importa); botão de confirmar nunca se chama "Cancelar".
4. Rota `/aplicacoes/ponto/:id/editar` em app_administrador.

## Próxima ação
Implementação (geoprag_modules + rota/navigator em app_administrador),
autorevisão e code review concluídos (achado real corrigido: formatação de
número duplicada entre visualizacao_de_ponto_screen.dart e o novo Cubit de
edição, consolidada em form_validators.dart). Gate de qualidade passou em
ambos os repositórios (app_administrador verificado com override local
temporário de pubspec, removido antes do commit). Próxima ação: commit +
push + abrir PR nos dois repositórios (5.5/5.6).

## Decisões técnicas
- `cancelarAplicacaoQuimica()` reaproveita `_cancelarDatasPendentes`
  (privada, já existe no arquivo da entidade desde a GEOPRAG-110) — cancela
  datas pendentes do agendamento vigente, igual `desativar()`, mas
  transiciona para `Inativa` (não `desativado`) e não usa `estadoAnterior`
  (Inativa não tem o mesmo fluxo especial de "reativar" — ativa-se de novo
  normalmente via `ativar()`).
- Evento de auditoria (issue de Trilha de Auditoria, não implementada):
  fora de escopo nesta execução — mesmo tratamento dado ao evento de push
  da GEOPRAG-110 (documentar como não implementado, não fingir que existe).

## Bloqueios / decisões pendentes de Rafinha
Nenhum até o momento.

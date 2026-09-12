import '../core/solicitacao_promocao.dart';

/// Solicitações de promoção em memória (GEOPRAG-36) — mesma estratégia de
/// mock compartilhado já usada por `mockAdminAccounts`, enquanto não há
/// repositório `geoprag_api` conectado.
final List<SolicitacaoPromocao> mockSolicitacoesPromocao = [];

int _proximoId = 1;

String proximoIdSolicitacaoPromocao() => 'sp${_proximoId++}';

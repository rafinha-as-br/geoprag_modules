import '../core/foco_recente.dart';
import '../core/resumo_geral.dart';

final ResumoGeral mockResumoGeral = ResumoGeral(
  lotesAVencer: 2,
  corregosComAplicacaoAtrasada: 4,
  denunciasAbertas: 12,
  atualizacoesEstoque: const [
    'Lote BTI-001 perto de vencer (5 dias).',
    'Novo lote BTI-004 recebido hoje.',
  ],
  ultimasAplicacoes: const [
    'Bairro Coloninha: Aplicação realizada.',
    'Bairro Margem Esquerda: Em breve (2 dias).',
    'Bairro Belchior: ATRASADA (20 dias).',
  ],
  focosRecentes: const [
    FocoRecente(
      titulo: 'Foco Alto - Belchior Alto',
      statusDescricao: 'Status: Equipe a Investigar',
    ),
  ],
);

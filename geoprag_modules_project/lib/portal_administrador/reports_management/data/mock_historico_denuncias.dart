import '../core/historico_denuncia.dart';

/// Histórico de auditoria por `denunciaId`, usado para simular a tela de
/// análise/detalhe enquanto não há registro real de auditoria no backend.
final Map<String, List<HistoricoDenuncia>> mockHistoricoDenuncias = {
  'r1': [
    HistoricoDenuncia(
      titulo: 'Criada via App Mobile',
      autor: 'João Silva',
      dataHora: DateTime(2026, 7, 5, 14, 30),
      status: 'Recebida',
    ),
  ],
  'r2': [
    HistoricoDenuncia(
      titulo: 'Criada via App Mobile',
      autor: 'Maria Souza',
      dataHora: DateTime(2026, 7, 3, 9, 15),
      status: 'Recebida',
    ),
    HistoricoDenuncia(
      titulo: 'Equipe designada para investigação',
      autor: 'Equipe de Campo',
      dataHora: DateTime(2026, 7, 4, 10, 0),
      status: 'Equipe a Investigar',
    ),
  ],
  'r4': [
    HistoricoDenuncia(
      titulo: 'Criada via App Mobile',
      autor: 'Ana Costa',
      dataHora: DateTime(2026, 6, 10, 11, 0),
      status: 'Recebida',
    ),
    HistoricoDenuncia(
      titulo: 'Equipe designada para investigação',
      autor: 'Equipe de Campo',
      dataHora: DateTime(2026, 6, 11, 8, 30),
      status: 'Equipe a Investigar',
    ),
    HistoricoDenuncia(
      titulo: 'Combate iniciado no local',
      autor: 'Equipe de Campo',
      dataHora: DateTime(2026, 6, 12, 9, 0),
      status: 'Em Combate',
    ),
  ],
};

import '../core/denuncia_de_foco.dart';

final List<DenunciaDeFoco> mockDenunciasDeFoco = [
  DenunciaDeFoco(
    id: '1',
    nivelInfestacao: NivelInfestacaoFoco.alto,
    localDescricao: 'Rua Principal',
    status: StatusDenunciaDeFoco.recebida,
    dataRegistro: DateTime(2026, 7, 5),
  ),
  DenunciaDeFoco(
    id: '2',
    nivelInfestacao: NivelInfestacaoFoco.medio,
    localDescricao: 'Remanso',
    status: StatusDenunciaDeFoco.atendida,
    dataRegistro: DateTime(2026, 6, 20),
  ),
];

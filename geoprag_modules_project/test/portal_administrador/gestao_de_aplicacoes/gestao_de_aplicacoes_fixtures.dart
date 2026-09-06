import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';

/// Ponto de Aplicação de teste com os campos obrigatórios já preenchidos —
/// cada teste sobrescreve só o que a sua asserção olha.
PontoDeAplicacao pontoDeAplicacao({
  String id = 'pa1',
  String identificador = '#GAS1',
  String nome = 'Córrego Gasparinho',
  String bairro = 'Gasparinho',
  EstadoPontoDeAplicacao estado = EstadoPontoDeAplicacao.enderecada,
  String? aplicadorId,
  List<Subponto> subpontos = const [],
  double larguraMetros = 2,
  double profundidadeMetros = 0.5,
  double velocidadeMetrosPorSegundo = 0.4,
  int quantidadeDeSubpontos = 8,
}) {
  return PontoDeAplicacao(
    id: id,
    identificador: identificador,
    nome: nome,
    bairro: bairro,
    endereco: 'Rua Pedro Simon',
    numeroReferencia: 'Em frente ao nº 240',
    descricaoDoTrecho: 'Trecho de 400 m.',
    larguraMetros: larguraMetros,
    profundidadeMetros: profundidadeMetros,
    velocidadeMetrosPorSegundo: velocidadeMetrosPorSegundo,
    dosagemMl: 120,
    distanciaEntreSubpontosMetros: 50,
    quantidadeDeSubpontos: quantidadeDeSubpontos,
    aplicadorId: aplicadorId,
    estado: estado,
    subpontos: subpontos,
  );
}

final Subponto execucaoDeTeste = Subponto(
  latitude: -26.9312,
  longitude: -48.9567,
  realizadoEm: DateTime(2026, 8, 24, 8, 12),
  registradoEm: DateTime(2026, 8, 24, 18, 40),
);

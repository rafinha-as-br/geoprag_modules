/// Tolerância padrão, em dias, para considerar uma aplicação em atraso.
///
/// Única fonte do valor padrão: o cadastro do ponto de aplicação (que pode
/// definir outra tolerância por ponto) e a regra [verificarAtraso] partem
/// daqui.
const int toleranciaPadraoDeAtrasoEmDias = 4;

/// Situação de uma data agendada em relação ao prazo, para fins de aviso.
///
/// É apenas um aviso: nenhuma ação sobre o ponto é bloqueada pelo atraso, e o
/// registro tardio continua permitido.
enum EstadoDeAtraso {
  /// Dentro do prazo (inclusive no último dia da tolerância), ou sem aviso
  /// aplicável.
  emDia,

  /// Passou do último dia da tolerância e o aviso ainda vale.
  emAtraso,
}

/// Regra única de verificação de atraso de uma aplicação, compartilhada pelo
/// Portal Administrador e pelo App Aplicador.
///
/// Função pura, sem UI e sem rede: usa só os argumentos, então funciona
/// offline.
///
/// A contagem é em **dias corridos de calendário** (a hora do dia é ignorada):
/// no último dia da tolerância ([dataPrevista] + [toleranciaEmDias]) o ponto
/// ainda está em dia, e passa a [EstadoDeAtraso.emAtraso] no dia seguinte.
///
/// O dia de calendário é lido dos próprios campos de ano, mês e dia de cada
/// data, sem converter fuso: [dataPrevista] e [dataDeReferencia] precisam vir
/// no mesmo fuso (o local). Quem chama converte antes (`toLocal()`) se tiver
/// um instante em UTC, para a virada do atraso acontecer no dia certo.
///
/// - [dataPrevista]: data prevista da recorrência (uma das datas do
///   agendamento). `null` quando o ponto não tem agendamento vigente — sem
///   data prevista não existe atraso.
/// - [dataDeReferencia]: o "hoje" da verificação.
/// - [toleranciaEmDias]: tolerância do ponto; não pode ser negativa.
/// - [aplicacaoConcluida]: a aplicação dessa recorrência já foi concluída
///   (registro tardio incluído); o aviso deixa de existir.
/// - [alertaRemovidoManualmente]: o administrador removeu o aviso do atraso
///   atual; a remoção vale só para esse atraso, então quem chama passa `true`
///   apenas para a recorrência a que a remoção se refere.
EstadoDeAtraso verificarAtraso({
  required DateTime? dataPrevista,
  required DateTime dataDeReferencia,
  int toleranciaEmDias = toleranciaPadraoDeAtrasoEmDias,
  bool aplicacaoConcluida = false,
  bool alertaRemovidoManualmente = false,
}) {
  if (toleranciaEmDias < 0) {
    throw ArgumentError.value(
      toleranciaEmDias,
      'toleranciaEmDias',
      'A tolerância não pode ser negativa.',
    );
  }
  if (dataPrevista == null || aplicacaoConcluida || alertaRemovidoManualmente) {
    return EstadoDeAtraso.emDia;
  }
  final diasDesdeAPrevista = _soData(
    dataDeReferencia,
  ).difference(_soData(dataPrevista)).inDays;
  return diasDesdeAPrevista > toleranciaEmDias
      ? EstadoDeAtraso.emAtraso
      : EstadoDeAtraso.emDia;
}

/// Descarta a hora e o fuso: em UTC, `difference` conta dias de calendário
/// exatos, sem efeito de horário de verão.
DateTime _soData(DateTime data) =>
    DateTime.utc(data.year, data.month, data.day);

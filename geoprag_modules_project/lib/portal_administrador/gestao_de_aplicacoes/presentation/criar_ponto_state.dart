import '../core/ponto_de_aplicacao.dart';

sealed class CriarPontoState {
  const CriarPontoState();
}

class CriarPontoIdle extends CriarPontoState {
  const CriarPontoIdle();
}

class CriarPontoSalvando extends CriarPontoState {
  const CriarPontoSalvando();
}

class CriarPontoSucesso extends CriarPontoState {
  final AdminPontoDeAplicacao ponto;
  const CriarPontoSucesso(this.ponto);
}

class CriarPontoErro extends CriarPontoState {
  final String message;
  const CriarPontoErro(this.message);
}

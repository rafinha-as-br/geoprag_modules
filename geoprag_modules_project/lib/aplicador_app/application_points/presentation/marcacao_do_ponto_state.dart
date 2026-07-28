import 'ponto_de_aplicacao_view_model.dart';

sealed class MarcacaoDoPontoState {
  const MarcacaoDoPontoState();
}

/// Capturando a leitura de GPS do dispositivo.
class MarcacaoDoPontoCapturando extends MarcacaoDoPontoState {
  const MarcacaoDoPontoCapturando();
}

/// Leitura de GPS capturada e pronta para o aplicador salvar. [salvando]
/// indica que o botão "Salvar Ponto Inicial" foi acionado e o envio para a
/// prefeitura está em andamento.
class MarcacaoDoPontoCapturado extends MarcacaoDoPontoState {
  final CapturaLocalizacaoViewModel captura;
  final bool salvando;

  const MarcacaoDoPontoCapturado(this.captura, {this.salvando = false});
}

/// Ponto (re)marcado com sucesso e enviado para validação da prefeitura.
class MarcacaoDoPontoSalvo extends MarcacaoDoPontoState {
  const MarcacaoDoPontoSalvo();
}

class MarcacaoDoPontoErro extends MarcacaoDoPontoState {
  final String message;
  const MarcacaoDoPontoErro(this.message);
}

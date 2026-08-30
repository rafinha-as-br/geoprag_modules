import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../core/ponto_de_aplicacao.dart';
import '../core/ponto_de_aplicacao_repository.dart';
import 'ponto_de_aplicacao_view_model.dart';

/// Captura a localização GPS do dispositivo e permite salvar a nova
/// localização inicial do ponto de aplicação (GEOPRAG-108), migrado para
/// [BaseFormScreen] — não há campo editável, a leitura de GPS já chega
/// pronta do repositório; "enviar" aqui é confirmar essa leitura.
///
/// [isSubmitting] cobre tanto a captura inicial de GPS quanto o envio do
/// "Salvar Ponto Inicial", reaproveitando o mesmo sinal do template em vez
/// de um estado de carregamento à parte (mesmo critério de
/// `CadastroSaidaCubit`, GEOPRAG-104).
///
/// TODO(GEOPRAG-24): a captura de GPS hoje é simulada via
/// `PontoDeAplicacaoRepository.capturarLocalizacaoAtual`; falta integrar um
/// plugin real de geolocalização (ex.: `geolocator`) neste módulo.
class MarcacaoDoPontoCubit extends BaseFormController {
  MarcacaoDoPontoCubit(this._repository) : super(_initialModel()) {
    _capturarLocalizacao();
  }

  final PontoDeAplicacaoRepository _repository;
  PontoDeAplicacao? _pontoCapturado;

  static BaseFormModel _initialModel() => BaseFormModel(
    title: 'Configure seu Ponto de Aplicação',
    description:
        'Vá fisicamente até o local de início do seu ponto de aplicação e '
        'clique em "Salvar Ponto Inicial". O ponto será enviado para a '
        'prefeitura validar.',
    submitLabel: 'Salvar Ponto Inicial',
    fields: const [],
    isSubmitting: true,
  );

  Future<void> _capturarLocalizacao() async {
    try {
      final ponto = await _repository.capturarLocalizacaoAtual();
      _pontoCapturado = ponto;
      final captura = CapturaLocalizacaoViewModel.fromEntity(ponto);
      emit(
        state.copyWith(
          fields: [
            BaseFormField(
              label: 'Precisão da Leitura de GPS',
              field: Text(
                '${captura.qualidadePrecisao} '
                '(${captura.precisaoMetros.toStringAsFixed(0)}m) — '
                '${captura.coordenadasFormatadas}',
              ),
            ),
          ],
          isSubmitting: false,
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          feedback: AcaoFeedbackErro(e.mensagemAmigavel),
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'MarcacaoDoPontoCubit._capturarLocalizacao',
        e,
        stackTrace,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          feedback: const AcaoFeedbackErro(
            AppErrorMessages.carregamentoGenerico,
          ),
        ),
      );
    }
  }

  @override
  Future<void> onSubmit() async {
    final ponto = _pontoCapturado;
    if (ponto == null) {
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
      return;
    }
    try {
      await _repository.marcarPontoInicial(ponto);
      emitFeedback(
        const AcaoFeedbackSucesso(
          'Localização capturada! Pendente de validação.',
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('MarcacaoDoPontoCubit.onSubmit', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }
}

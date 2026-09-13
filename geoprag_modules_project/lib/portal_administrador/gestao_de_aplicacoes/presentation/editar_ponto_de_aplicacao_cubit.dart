import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/utils/form_validators.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../core/admin_ponto_de_aplicacao_repository.dart';
import 'widgets/edicao_de_ponto_banner.dart';

/// Edição de um Ponto de Aplicação já cadastrado (GEOPRAG-109).
///
/// Mesmos campos de [CriarPontoDeAplicacaoCubit], mas: (1) carrega o ponto
/// existente antes de exibir o formulário; (2) todos os campos exceto
/// [nome] ficam desabilitados quando
/// `PontoDeAplicacao.podeEditarCadastroCompleto` for falso — o predicado
/// mora na entidade, então a mesma regra vale mesmo que alguém chame o
/// Cubit direto (sem passar pela tela); (3) não tem campo de aplicador —
/// isso é ação própria (GEOPRAG-110, Atribuir/Desatribuir), não parte do
/// cadastro.
class EditarPontoDeAplicacaoCubit extends BaseFormController {
  EditarPontoDeAplicacaoCubit(this._repository, this._pontoId)
    : super(_initialModel()) {
    _carregar();
  }

  final AdminPontoDeAplicacaoRepository _repository;
  final String _pontoId;

  final _nomeController = TextEditingController();
  final _bairroController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _numeroReferenciaController = TextEditingController();
  final _descricaoDoTrechoController = TextEditingController();
  final _larguraController = TextEditingController();
  final _profundidadeController = TextEditingController();
  final _velocidadeController = TextEditingController();
  final _dosagemController = TextEditingController();
  final _distanciaController = TextEditingController();
  final _quantidadeDeSubpontosController = TextEditingController();

  bool _podeEditarCadastroCompleto = false;
  bool _carregando = true;

  static BaseFormModel _initialModel() => BaseFormModel(
    title: 'Editar Ponto de Aplicação',
    submitLabel: 'Salvar alterações',
    width: 700,
    fields: const [],
  );

  Future<void> _carregar() async {
    try {
      final ponto = await _repository.buscarPorId(_pontoId);
      _podeEditarCadastroCompleto = ponto.podeEditarCadastroCompleto;
      _nomeController.text = ponto.nome;
      _bairroController.text = ponto.bairro;
      _enderecoController.text = ponto.endereco;
      _numeroReferenciaController.text = ponto.numeroReferencia;
      _descricaoDoTrechoController.text = ponto.descricaoDoTrecho;
      _larguraController.text = formatarNumeroExibicao(ponto.larguraMetros);
      _profundidadeController.text = formatarNumeroExibicao(
        ponto.profundidadeMetros,
      );
      _velocidadeController.text = formatarNumeroExibicao(
        ponto.velocidadeMetrosPorSegundo,
      );
      _dosagemController.text = formatarNumeroExibicao(ponto.dosagemMl);
      _distanciaController.text = formatarNumeroExibicao(
        ponto.distanciaEntreSubpontosMetros,
      );
      _quantidadeDeSubpontosController.text = ponto.quantidadeDeSubpontos
          .toString();
      _carregando = false;
      for (final controller in [
        _larguraController,
        _profundidadeController,
        _velocidadeController,
      ]) {
        controller.addListener(_rebuildFields);
      }
      _rebuildFields();
    } on EntidadeNaoEncontradaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('EditarPontoDeAplicacaoCubit._carregar', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  void _rebuildFields() {
    if (isClosed) return;
    emit(
      state.copyWith(
        fields: _buildFields(),
        banner: EdicaoDePontoBanner(liberada: _podeEditarCadastroCompleto),
      ),
    );
  }

  List<BaseFormField> _buildFields() {
    final travado = !_podeEditarCadastroCompleto;
    return [
      BaseFormField(
        label: 'Nome do ponto',
        field: TextFormField(
          controller: _nomeController,
          validator: (value) =>
              validarObrigatorio(value, 'Informe o nome do ponto.'),
        ),
      ),
      BaseFormField(
        label: 'Bairro',
        field: TextFormField(
          controller: _bairroController,
          enabled: !travado,
          validator: (value) => validarObrigatorio(value, 'Informe o bairro.'),
        ),
      ),
      BaseFormField(
        label: 'Endereço',
        field: TextFormField(
          controller: _enderecoController,
          enabled: !travado,
          validator: (value) =>
              validarObrigatorio(value, 'Informe o endereço.'),
        ),
      ),
      BaseFormField(
        label: 'Número ou ponto de referência',
        field: TextFormField(
          controller: _numeroReferenciaController,
          enabled: !travado,
          validator: (value) =>
              validarObrigatorio(value, 'Informe o número ou uma referência.'),
        ),
      ),
      BaseFormField(
        label: 'Descrição do trecho',
        field: TextFormField(
          controller: _descricaoDoTrechoController,
          enabled: !travado,
          maxLines: 2,
          validator: (value) => validarObrigatorio(value, 'Descreva o trecho.'),
        ),
      ),
      BaseFormField(
        label: 'Largura do trecho (m)',
        field: TextFormField(
          controller: _larguraController,
          enabled: !travado,
          keyboardType: TextInputType.number,
          validator: (value) =>
              validarNumeroPositivo(value, 'Informe a largura em metros.'),
        ),
      ),
      BaseFormField(
        label: 'Profundidade do trecho (m)',
        field: TextFormField(
          controller: _profundidadeController,
          enabled: !travado,
          keyboardType: TextInputType.number,
          validator: (value) =>
              validarNumeroPositivo(value, 'Informe a profundidade em metros.'),
        ),
      ),
      BaseFormField(
        label: 'Velocidade da água (m/s)',
        field: TextFormField(
          controller: _velocidadeController,
          enabled: !travado,
          keyboardType: TextInputType.number,
          validator: (value) =>
              validarNumeroPositivo(value, 'Informe a velocidade em m/s.'),
        ),
      ),
      BaseFormField(
        label: 'Dosagem por aplicação (ml)',
        field: TextFormField(
          controller: _dosagemController,
          enabled: !travado,
          keyboardType: TextInputType.number,
          validator: (value) =>
              validarNumeroPositivo(value, 'Informe a dosagem em ml.'),
        ),
      ),
      BaseFormField(
        label: 'Distância entre subpontos (m)',
        field: TextFormField(
          controller: _distanciaController,
          enabled: !travado,
          keyboardType: TextInputType.number,
          validator: (value) =>
              validarNumeroPositivo(value, 'Informe a distância em metros.'),
        ),
      ),
      BaseFormField(
        label: 'Subpontos por ciclo',
        field: TextFormField(
          controller: _quantidadeDeSubpontosController,
          enabled: !travado,
          keyboardType: TextInputType.number,
          validator: (value) {
            final quantidade = int.tryParse(value ?? '');
            return (quantidade == null || quantidade <= 0)
                ? 'Informe quantos subpontos compõem o ciclo.'
                : null;
          },
        ),
      ),
    ];
  }

  @override
  Future<void> onSubmit() async {
    if (_carregando) return;
    try {
      if (_podeEditarCadastroCompleto) {
        await _repository.editarCadastroCompleto(
          _pontoId,
          nome: _nomeController.text,
          bairro: _bairroController.text,
          endereco: _enderecoController.text,
          numeroReferencia: _numeroReferenciaController.text,
          descricaoDoTrecho: _descricaoDoTrechoController.text,
          larguraMetros: decimalDoFormulario(_larguraController.text)!,
          profundidadeMetros: decimalDoFormulario(
            _profundidadeController.text,
          )!,
          velocidadeMetrosPorSegundo: decimalDoFormulario(
            _velocidadeController.text,
          )!,
          dosagemMl: decimalDoFormulario(_dosagemController.text)!,
          distanciaEntreSubpontosMetros: decimalDoFormulario(
            _distanciaController.text,
          )!,
          quantidadeDeSubpontos: int.parse(
            _quantidadeDeSubpontosController.text,
          ),
        );
      } else {
        await _repository.editarNome(_pontoId, _nomeController.text);
      }
      emitFeedback(
        const AcaoFeedbackSucesso('Ponto de aplicação atualizado com sucesso.'),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } on OperacaoNaoPermitidaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('EditarPontoDeAplicacaoCubit.onSubmit', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  @override
  Future<void> close() {
    for (final controller in [
      _nomeController,
      _bairroController,
      _enderecoController,
      _numeroReferenciaController,
      _descricaoDoTrechoController,
      _larguraController,
      _profundidadeController,
      _velocidadeController,
      _dosagemController,
      _distanciaController,
      _quantidadeDeSubpontosController,
    ]) {
      controller.dispose();
    }
    return super.close();
  }
}

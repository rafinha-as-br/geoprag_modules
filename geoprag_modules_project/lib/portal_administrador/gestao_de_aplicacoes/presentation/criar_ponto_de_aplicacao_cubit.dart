import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/theme/geoprag_colors.dart';
import '../../../src/utils/form_validators.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../gerenciamento_de_aplicadores/core/aplicador.dart';
import '../../gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import '../core/admin_ponto_de_aplicacao_repository.dart';

/// Cadastro de um Ponto de Aplicação novo.
///
/// Não pede latitude/longitude, estado nem data agendada: o ponto é
/// cadastrado por endereço (a coordenada só existe depois da primeira
/// aplicação em campo), e nasce `Endereçada` ou `Direcionada` conforme um
/// aplicador seja escolhido aqui — nunca em operação.
class CriarPontoDeAplicacaoCubit extends BaseFormController {
  CriarPontoDeAplicacaoCubit(this._repository, this._aplicadorRepository)
    : super(_initialModel()) {
    for (final controller in [
      _larguraController,
      _profundidadeController,
      _velocidadeController,
    ]) {
      controller.addListener(_rebuildFields);
    }
    _carregarAplicadores();
  }

  final AdminPontoDeAplicacaoRepository _repository;
  final AplicadorRepository _aplicadorRepository;

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

  List<Aplicador> _aplicadores = [];
  String? _aplicadorId;

  static BaseFormModel _initialModel() => BaseFormModel(
    title: 'Novo Ponto de Aplicação',
    description:
        'O ponto é cadastrado pelo endereço. A localização geográfica é '
        'capturada em campo, na primeira aplicação.',
    submitLabel: 'Cadastrar Ponto',
    width: 700,
    fields: const [],
  );

  Future<void> _carregarAplicadores() async {
    try {
      _aplicadores = await _aplicadorRepository.listar();
      _rebuildFields();
    } catch (e, stackTrace) {
      AppLogger.error(
        'CriarPontoDeAplicacaoCubit._carregarAplicadores',
        e,
        stackTrace,
      );
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  void _rebuildFields() {
    if (isClosed) return;
    emit(state.copyWith(fields: _buildFields()));
  }

  /// Vazão a partir do que já foi digitado — `null` enquanto algum dos três
  /// parâmetros ainda não é um número válido.
  double? get vazaoPrevia {
    final largura = decimalDoFormulario(_larguraController.text);
    final profundidade = decimalDoFormulario(_profundidadeController.text);
    final velocidade = decimalDoFormulario(_velocidadeController.text);
    if (largura == null || profundidade == null || velocidade == null) {
      return null;
    }
    return largura * profundidade * velocidade;
  }

  List<BaseFormField> _buildFields() => [
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
        validator: (value) => validarObrigatorio(value, 'Informe o bairro.'),
      ),
    ),
    BaseFormField(
      label: 'Endereço',
      field: TextFormField(
        controller: _enderecoController,
        validator: (value) => validarObrigatorio(value, 'Informe o endereço.'),
      ),
    ),
    BaseFormField(
      label: 'Número ou ponto de referência',
      field: TextFormField(
        controller: _numeroReferenciaController,
        validator: (value) =>
            validarObrigatorio(value, 'Informe o número ou uma referência.'),
      ),
    ),
    BaseFormField(
      label: 'Descrição do trecho',
      field: TextFormField(
        controller: _descricaoDoTrechoController,
        maxLines: 2,
        validator: (value) =>
            validarObrigatorio(value, 'Descreva o trecho.'),
      ),
    ),
    BaseFormField(
      label: 'Largura do trecho (m)',
      field: TextFormField(
        controller: _larguraController,
        keyboardType: TextInputType.number,
        validator: (value) =>
            validarNumeroPositivo(value, 'Informe a largura em metros.'),
      ),
    ),
    BaseFormField(
      label: 'Profundidade do trecho (m)',
      field: TextFormField(
        controller: _profundidadeController,
        keyboardType: TextInputType.number,
        validator: (value) =>
            validarNumeroPositivo(value, 'Informe a profundidade em metros.'),
      ),
    ),
    BaseFormField(
      label: 'Velocidade da água (m/s)',
      field: TextFormField(
        controller: _velocidadeController,
        keyboardType: TextInputType.number,
        validator: (value) =>
            validarNumeroPositivo(value, 'Informe a velocidade em m/s.'),
      ),
    ),
    BaseFormField(
      label: 'Vazão',
      field: _PreviaDaVazao(vazao: vazaoPrevia),
    ),
    BaseFormField(
      label: 'Dosagem por aplicação (ml)',
      field: TextFormField(
        controller: _dosagemController,
        keyboardType: TextInputType.number,
        validator: (value) =>
            validarNumeroPositivo(value, 'Informe a dosagem em ml.'),
      ),
    ),
    BaseFormField(
      label: 'Distância entre subpontos (m)',
      field: TextFormField(
        controller: _distanciaController,
        keyboardType: TextInputType.number,
        validator: (value) =>
            validarNumeroPositivo(value, 'Informe a distância em metros.'),
      ),
    ),
    BaseFormField(
      label: 'Subpontos por ciclo',
      field: TextFormField(
        controller: _quantidadeDeSubpontosController,
        keyboardType: TextInputType.number,
        validator: (value) {
          final quantidade = int.tryParse(value ?? '');
          return (quantidade == null || quantidade <= 0)
              ? 'Informe quantos subpontos compõem o ciclo.'
              : null;
        },
      ),
    ),
    BaseFormField(
      label: 'Aplicador responsável (opcional)',
      field: DropdownButtonFormField<String?>(
        initialValue: _aplicadorId,
        isExpanded: true,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        items: [
          const DropdownMenuItem<String?>(
            child: Text('Nenhum — cadastrar como Endereçada'),
          ),
          for (final aplicador in _aplicadores)
            DropdownMenuItem<String?>(
              value: aplicador.id,
              child: Text(aplicador.nome),
            ),
        ],
        onChanged: (valor) {
          _aplicadorId = valor;
          _rebuildFields();
        },
      ),
    ),
  ];

  @override
  Future<void> onSubmit() async {
    try {
      await _repository.criar(
        nome: _nomeController.text,
        bairro: _bairroController.text,
        endereco: _enderecoController.text,
        numeroReferencia: _numeroReferenciaController.text,
        descricaoDoTrecho: _descricaoDoTrechoController.text,
        larguraMetros: decimalDoFormulario(_larguraController.text)!,
        profundidadeMetros: decimalDoFormulario(_profundidadeController.text)!,
        velocidadeMetrosPorSegundo: decimalDoFormulario(_velocidadeController.text)!,
        dosagemMl: decimalDoFormulario(_dosagemController.text)!,
        distanciaEntreSubpontosMetros: decimalDoFormulario(_distanciaController.text)!,
        quantidadeDeSubpontos: int.parse(
          _quantidadeDeSubpontosController.text,
        ),
        aplicadorId: _aplicadorId,
      );
      emitFeedback(
        const AcaoFeedbackSucesso('Ponto de aplicação cadastrado com sucesso.'),
      );
    } catch (e, stackTrace) {
      AppLogger.error('CriarPontoDeAplicacaoCubit.onSubmit', e, stackTrace);
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

/// Vazão exibida enquanto o formulário é preenchido — feedback, não campo:
/// o que fica persistido são largura, profundidade e velocidade.
class _PreviaDaVazao extends StatelessWidget {
  const _PreviaDaVazao({required this.vazao});

  final double? vazao;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GeopragColors.blue600.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GeopragColors.blue600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calculada automaticamente',
            style: TextStyle(
              color: GeopragColors.blue600,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vazao == null
                ? 'Informe largura, profundidade e velocidade.'
                : '${vazao!.toStringAsFixed(3)} m³/s',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

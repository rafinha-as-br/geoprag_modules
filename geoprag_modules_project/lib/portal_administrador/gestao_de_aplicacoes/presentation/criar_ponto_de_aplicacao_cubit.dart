import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_numero_decimal_input.dart';
import '../../../src/widgets/geoprag_numero_inteiro_input.dart';
import '../../../src/widgets/geoprag_texto_input.dart';
import '../../gerenciamento_de_aplicadores/core/aplicador.dart';
import '../../gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import '../core/admin_ponto_de_aplicacao_repository.dart';

/// Cadastro de um Ponto de Aplicação novo.
///
/// Não pede latitude/longitude, estado nem data agendada: o ponto é
/// cadastrado por endereço (a coordenada só existe depois da primeira
/// aplicação em campo), e nasce `Endereçada` ou `Direcionada` conforme um
/// aplicador seja escolhido aqui — nunca em operação.
///
/// Campos numéricos e de texto migrados para a biblioteca de inputs
/// reutilizáveis (GEOPRAG-144/145) — cada widget já valida e converte o
/// próprio valor, então o Cubit guarda o resultado tipado (`_largura`,
/// `_quantidadeDeSubpontos`, etc.) em vez de `TextEditingController`s.
class CriarPontoDeAplicacaoCubit extends BaseFormController {
  CriarPontoDeAplicacaoCubit(this._repository, this._aplicadorRepository)
    : super(_initialModel()) {
    _carregarAplicadores();
  }

  final AdminPontoDeAplicacaoRepository _repository;
  final AplicadorRepository _aplicadorRepository;

  String? _nome;
  String? _bairro;
  String? _endereco;
  String? _numeroReferencia;
  String? _descricaoDoTrecho;
  double? _largura;
  double? _profundidade;
  double? _velocidade;
  double? _dosagem;
  double? _distancia;
  int? _quantidadeDeSubpontos;

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
    if (_largura == null || _profundidade == null || _velocidade == null) {
      return null;
    }
    return _largura! * _profundidade! * _velocidade!;
  }

  List<BaseFormField> _buildFields() => [
    BaseFormField(
      label: 'Nome do ponto',
      field: GeopragTextoInput(
        label: 'Nome do ponto',
        initialValue: _nome,
        mensagemObrigatorio: 'Informe o nome do ponto.',
        onChanged: (valor) => _nome = valor,
      ),
    ),
    BaseFormField(
      label: 'Bairro',
      field: GeopragTextoInput(
        label: 'Bairro',
        initialValue: _bairro,
        mensagemObrigatorio: 'Informe o bairro.',
        onChanged: (valor) => _bairro = valor,
      ),
    ),
    BaseFormField(
      label: 'Endereço',
      field: GeopragTextoInput(
        label: 'Endereço',
        initialValue: _endereco,
        mensagemObrigatorio: 'Informe o endereço.',
        onChanged: (valor) => _endereco = valor,
      ),
    ),
    BaseFormField(
      label: 'Número ou ponto de referência',
      field: GeopragTextoInput(
        label: 'Número ou ponto de referência',
        initialValue: _numeroReferencia,
        mensagemObrigatorio: 'Informe o número ou uma referência.',
        onChanged: (valor) => _numeroReferencia = valor,
      ),
    ),
    BaseFormField(
      label: 'Descrição do trecho',
      field: GeopragTextoInput(
        label: 'Descrição do trecho',
        initialValue: _descricaoDoTrecho,
        maxLinhas: 2,
        mensagemObrigatorio: 'Descreva o trecho.',
        onChanged: (valor) => _descricaoDoTrecho = valor,
      ),
    ),
    BaseFormField(
      label: 'Largura do trecho (m)',
      field: GeopragNumeroDecimalInput(
        label: 'Largura do trecho (m)',
        initialValue: _largura,
        mensagemObrigatorio: 'Informe a largura em metros.',
        mensagemInvalido: 'Informe a largura em metros.',
        onChanged: (valor) {
          _largura = valor;
          _rebuildFields();
        },
      ),
    ),
    BaseFormField(
      label: 'Profundidade do trecho (m)',
      field: GeopragNumeroDecimalInput(
        label: 'Profundidade do trecho (m)',
        initialValue: _profundidade,
        mensagemObrigatorio: 'Informe a profundidade em metros.',
        mensagemInvalido: 'Informe a profundidade em metros.',
        onChanged: (valor) {
          _profundidade = valor;
          _rebuildFields();
        },
      ),
    ),
    BaseFormField(
      label: 'Velocidade da água (m/s)',
      field: GeopragNumeroDecimalInput(
        label: 'Velocidade da água (m/s)',
        initialValue: _velocidade,
        mensagemObrigatorio: 'Informe a velocidade em m/s.',
        mensagemInvalido: 'Informe a velocidade em m/s.',
        onChanged: (valor) {
          _velocidade = valor;
          _rebuildFields();
        },
      ),
    ),
    BaseFormField(label: 'Vazão', field: _PreviaDaVazao(vazao: vazaoPrevia)),
    BaseFormField(
      label: 'Dosagem por aplicação (ml)',
      field: GeopragNumeroDecimalInput(
        label: 'Dosagem por aplicação (ml)',
        initialValue: _dosagem,
        mensagemObrigatorio: 'Informe a dosagem em ml.',
        mensagemInvalido: 'Informe a dosagem em ml.',
        onChanged: (valor) => _dosagem = valor,
      ),
    ),
    BaseFormField(
      label: 'Distância entre subpontos (m)',
      field: GeopragNumeroDecimalInput(
        label: 'Distância entre subpontos (m)',
        initialValue: _distancia,
        mensagemObrigatorio: 'Informe a distância em metros.',
        mensagemInvalido: 'Informe a distância em metros.',
        onChanged: (valor) => _distancia = valor,
      ),
    ),
    BaseFormField(
      label: 'Subpontos por ciclo',
      field: GeopragNumeroInteiroInput(
        label: 'Subpontos por ciclo',
        initialValue: _quantidadeDeSubpontos,
        mensagemObrigatorio: 'Informe quantos subpontos compõem o ciclo.',
        mensagemInvalido: 'Informe quantos subpontos compõem o ciclo.',
        onChanged: (valor) => _quantidadeDeSubpontos = valor,
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
        nome: _nome!,
        bairro: _bairro!,
        endereco: _endereco!,
        numeroReferencia: _numeroReferencia!,
        descricaoDoTrecho: _descricaoDoTrecho!,
        larguraMetros: _largura!,
        profundidadeMetros: _profundidade!,
        velocidadeMetrosPorSegundo: _velocidade!,
        dosagemMl: _dosagem!,
        distanciaEntreSubpontosMetros: _distancia!,
        quantidadeDeSubpontos: _quantidadeDeSubpontos!,
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

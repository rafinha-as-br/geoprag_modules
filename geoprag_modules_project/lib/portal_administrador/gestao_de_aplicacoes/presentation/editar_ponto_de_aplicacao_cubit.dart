import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_numero_decimal_input.dart';
import '../../../src/widgets/geoprag_numero_inteiro_input.dart';
import '../../../src/widgets/geoprag_texto_input.dart';
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
///
/// Campos numéricos e de texto migrados para a biblioteca de inputs
/// reutilizáveis (GEOPRAG-144/145) — cada widget já valida e converte o
/// próprio valor, então o Cubit guarda o resultado tipado em vez de
/// `TextEditingController`s.
class EditarPontoDeAplicacaoCubit extends BaseFormController {
  EditarPontoDeAplicacaoCubit(this._repository, this._pontoId)
    : super(_initialModel()) {
    _carregar();
  }

  final AdminPontoDeAplicacaoRepository _repository;
  final String _pontoId;

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
      _nome = ponto.nome;
      _bairro = ponto.bairro;
      _endereco = ponto.endereco;
      _numeroReferencia = ponto.numeroReferencia;
      _descricaoDoTrecho = ponto.descricaoDoTrecho;
      _largura = ponto.larguraMetros;
      _profundidade = ponto.profundidadeMetros;
      _velocidade = ponto.velocidadeMetrosPorSegundo;
      _dosagem = ponto.dosagemMl;
      _distancia = ponto.distanciaEntreSubpontosMetros;
      _quantidadeDeSubpontos = ponto.quantidadeDeSubpontos;
      _carregando = false;
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
          enabled: !travado,
          mensagemObrigatorio: 'Informe o bairro.',
          onChanged: (valor) => _bairro = valor,
        ),
      ),
      BaseFormField(
        label: 'Endereço',
        field: GeopragTextoInput(
          label: 'Endereço',
          initialValue: _endereco,
          enabled: !travado,
          mensagemObrigatorio: 'Informe o endereço.',
          onChanged: (valor) => _endereco = valor,
        ),
      ),
      BaseFormField(
        label: 'Número ou ponto de referência',
        field: GeopragTextoInput(
          label: 'Número ou ponto de referência',
          initialValue: _numeroReferencia,
          enabled: !travado,
          mensagemObrigatorio: 'Informe o número ou uma referência.',
          onChanged: (valor) => _numeroReferencia = valor,
        ),
      ),
      BaseFormField(
        label: 'Descrição do trecho',
        field: GeopragTextoInput(
          label: 'Descrição do trecho',
          initialValue: _descricaoDoTrecho,
          enabled: !travado,
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
          enabled: !travado,
          mensagemObrigatorio: 'Informe a largura em metros.',
          mensagemInvalido: 'Informe a largura em metros.',
          onChanged: (valor) => _largura = valor,
        ),
      ),
      BaseFormField(
        label: 'Profundidade do trecho (m)',
        field: GeopragNumeroDecimalInput(
          label: 'Profundidade do trecho (m)',
          initialValue: _profundidade,
          enabled: !travado,
          mensagemObrigatorio: 'Informe a profundidade em metros.',
          mensagemInvalido: 'Informe a profundidade em metros.',
          onChanged: (valor) => _profundidade = valor,
        ),
      ),
      BaseFormField(
        label: 'Velocidade da água (m/s)',
        field: GeopragNumeroDecimalInput(
          label: 'Velocidade da água (m/s)',
          initialValue: _velocidade,
          enabled: !travado,
          mensagemObrigatorio: 'Informe a velocidade em m/s.',
          mensagemInvalido: 'Informe a velocidade em m/s.',
          onChanged: (valor) => _velocidade = valor,
        ),
      ),
      BaseFormField(
        label: 'Dosagem por aplicação (ml)',
        field: GeopragNumeroDecimalInput(
          label: 'Dosagem por aplicação (ml)',
          initialValue: _dosagem,
          enabled: !travado,
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
          enabled: !travado,
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
          enabled: !travado,
          mensagemObrigatorio: 'Informe quantos subpontos compõem o ciclo.',
          mensagemInvalido: 'Informe quantos subpontos compõem o ciclo.',
          onChanged: (valor) => _quantidadeDeSubpontos = valor,
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
        );
      } else {
        await _repository.editarNome(_pontoId, _nome!);
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
}

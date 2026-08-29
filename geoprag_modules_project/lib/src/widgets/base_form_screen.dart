import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/acao_feedback.dart';
import 'base_screen_feedback.dart';
import 'geoprag_submit_button.dart';

/// Um campo do formulário: o rótulo exibido acima e o widget do campo em si.
///
/// Separar os dois é o que permite ao template posicionar rótulo, espaçamento
/// e campo de forma idêntica em todas as telas — hoje cada uma das 9 telas de
/// formulário monta esse arranjo por conta própria.
class BaseFormField {
  final String label;
  final Widget field;

  const BaseFormField({required this.label, required this.field});
}

/// Tudo que uma tela do arquétipo "formulário de cadastro/criação" exibe:
/// título, texto de apoio, campos, rótulo do botão e o estado do envio.
///
/// O arquétipo (`Center` → `Container(width: 600/700)` → `Card(elevation: 4,
/// radius: 16)` → `Padding(32)` → `Form`) é hoje reimplementado
/// independentemente em 9 telas com 3 níveis de maturidade completamente
/// diferentes sob o mesmo visual: telas funcionais de verdade
/// (`GlobalKey<FormState>`, validators, submit ligado a um Cubit — ex.
/// `cadastro_de_aplicador_screen.dart`), uma tela intermediária com submit
/// não conectado (`cadastro_saida_screen.dart`) e telas puramente
/// decorativas, sem `GlobalKey<FormState>`, sem validators e sem persistência
/// (ex. `cadastro_produto_screen.dart`).
///
/// Este model é o **estado** de [BaseFormController] — não uma camada de
/// estado a mais ao lado do `Cubit` da tela, mas o próprio estado dele.
class BaseFormModel {
  /// Título exibido no topo do card.
  final String title;

  /// Texto acima dos campos (ex.: uma regra de negócio que o usuário precisa
  /// saber antes de preencher), ou `null`.
  final String? description;

  /// Campos do formulário, na ordem de exibição.
  final List<BaseFormField> fields;

  /// Rótulo do botão de envio.
  final String submitLabel;

  /// Largura do card do formulário.
  final double width;

  final bool isSubmitting;

  /// Resultado da última tentativa de envio, no contrato único da GEOPRAG-77.
  final AcaoFeedback? feedback;

  BaseFormModel({
    required this.title,
    required this.fields,
    required this.submitLabel,
    this.description,
    this.width = 600,
    this.isSubmitting = false,
    this.feedback,
  });

  BaseFormModel copyWith({
    List<BaseFormField>? fields,
    bool? isSubmitting,
    AcaoFeedback? feedback,
    bool limparFeedback = false,
  }) {
    return BaseFormModel(
      title: title,
      description: description,
      submitLabel: submitLabel,
      width: width,
      fields: fields ?? this.fields,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      feedback: limparFeedback ? null : (feedback ?? this.feedback),
    );
  }
}

/// Controller reutilizável do arquétipo de formulário de cadastro/criação.
///
/// É um `Cubit` cujo estado é o próprio [BaseFormModel]: o Cubit que a tela já
/// tem continua sendo o controller dela, e não passa a conviver com uma
/// segunda cópia do mesmo estado. Cada tela estende este controller, informa
/// no `super` o que é fixo (título, campos, rótulo do botão) e implementa
/// [onSubmit].
///
/// [onSubmit] é membro obrigatório deste contrato, e não um callback opcional:
/// uma tela que usa [BaseFormScreen] não tem como "parecer" funcional sem de
/// fato estar. Validar o `Form`, marcar `isSubmitting` e liberá-lo ao final é
/// responsabilidade de [submit], aqui, não de cada tela.
///
/// O controller normalmente é dono dos `TextEditingController` dos seus
/// campos: descarte-os no `close()`.
abstract class BaseFormController extends Cubit<BaseFormModel> {
  BaseFormController(super.initialState);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// O que fazer quando o formulário é enviado e a validação passa.
  ///
  /// Não deve lançar: converta a falha em feedback (via
  /// `emitFeedback(AcaoFeedbackErro(...))`) para que o usuário veja uma
  /// mensagem, em vez de deixar a exceção escapar para o toque do botão.
  Future<void> onSubmit();

  /// Valida o formulário e, só então, executa [onSubmit].
  ///
  /// Retorna `false` quando a validação reprova e [onSubmit] não chegou a ser
  /// executado.
  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    // Uma nova tentativa invalida o resultado da anterior — sem isso, o aviso
    // de erro do envio passado seguiria em cena durante o novo envio.
    emit(state.copyWith(isSubmitting: true, limparFeedback: true));
    try {
      await onSubmit();
    } finally {
      if (!isClosed) emit(state.copyWith(isSubmitting: false));
    }
    return true;
  }

  void emitFeedback(AcaoFeedback? feedback) {
    emit(
      feedback == null
          ? state.copyWith(limparFeedback: true)
          : state.copyWith(feedback: feedback),
    );
  }
}

/// Template de corpo de tela para o arquétipo "formulário de cadastro/
/// criação", renderizado inteiramente a partir do estado de um
/// [BaseFormController] fornecido acima na árvore.
///
/// Como os demais templates do pacote, cobre só o corpo da tela:
/// `AdminScaffold`, `AppBar` e rota atual ficam com a tela que compõe este
/// template, não aqui dentro.
class BaseFormScreen<C extends BaseFormController> extends StatefulWidget {
  const BaseFormScreen({super.key});

  @override
  State<BaseFormScreen<C>> createState() => _BaseFormScreenState<C>();
}

class _BaseFormScreenState<C extends BaseFormController>
    extends State<BaseFormScreen<C>> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<C, BaseFormModel>(
      // Sem isso, um aviso de erro renderizado perto do topo do formulário
      // fica fora da tela para quem rolou até o botão de envio — a única
      // pista visível de que algo aconteceu, no caso de erro, já que não há
      // mais um SnackBar cobrindo a tela toda.
      listenWhen: (previous, current) =>
          current.feedback != null && previous.feedback != current.feedback,
      listener: (context, state) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      },
      child: BlocBuilder<C, BaseFormModel>(
        builder: (context, model) => Center(
          child: Container(
            width: model.width,
            padding: const EdgeInsets.all(32.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                // Rola verticalmente — formulários com muitos campos (ex.:
                // endereço completo) passam da altura disponível em telas
                // menores, e o Card/Container não rolam por padrão.
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Form(
                    key: context.read<C>().formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          model.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (model.description != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            model.description!,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                        if (model.feedback != null) ...[
                          const SizedBox(height: 16),
                          BaseScreenFeedback(feedback: model.feedback!),
                        ],
                        const SizedBox(height: 24),
                        for (final field in model.fields) ...[
                          Text(
                            field.label,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          field.field,
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 16),
                        GeopragSubmitButton(
                          label: model.submitLabel,
                          isLoading: model.isSubmitting,
                          onPressed: context.read<C>().submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

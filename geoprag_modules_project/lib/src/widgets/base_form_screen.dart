import 'package:flutter/material.dart';

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

/// Contrato que todo formulário de cadastro/criação do pacote deve ter:
/// título, campos, rótulo do botão e a ação de envio.
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
/// Por isso [onSubmit] é membro obrigatório deste contrato, e não um callback
/// opcional: uma tela que usa [BaseFormScreen] não tem como "parecer"
/// funcional sem de fato estar.
///
/// Quem implementa este contrato na prática é [BaseFormController].
abstract class BaseFormModel {
  /// Título exibido no topo do card.
  String get title;

  /// Texto acima dos campos (ex.: uma regra de negócio que o usuário precisa
  /// saber antes de preencher), ou `null`.
  String? get description;

  /// Campos do formulário, na ordem de exibição.
  List<BaseFormField> get fields;

  /// Rótulo do botão de envio.
  String get submitLabel;

  /// Largura do card do formulário.
  double get width;

  bool get isSubmitting;

  /// Resultado da última tentativa de envio, no contrato único da GEOPRAG-77.
  AcaoFeedback? get feedback;

  /// O que fazer quando o formulário é enviado e a validação passa.
  ///
  /// Não deve lançar: converta a falha em [feedback] (via
  /// `setFeedback(AcaoFeedbackErro(...))`) para que o usuário veja uma
  /// mensagem, em vez de deixar a exceção escapar para o toque do botão.
  Future<void> onSubmit();
}

/// Controller de tela de formulário: estende [BaseFormModel] e passa a
/// notificar a tela a cada mudança, de modo que [BaseFormScreen] possa ser um
/// `StatelessWidget`.
///
/// A tela concreta estende este controller e declara o que é específico dela
/// ([title], [fields], [submitLabel] e [onSubmit]). O ciclo de envio —
/// validar o `Form`, marcar [isSubmitting], chamar [onSubmit] e publicar o
/// [feedback] — é responsabilidade de [submit], aqui, não de cada tela.
///
/// O controller é um `ChangeNotifier` e normalmente é dono dos
/// `TextEditingController` dos seus campos: quem o cria é responsável por
/// chamá-lo em `dispose()` (descartando também esses controllers de texto) —
/// [BaseFormScreen] apenas o consome, nunca assume sua posse.
abstract class BaseFormController extends BaseFormModel with ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  AcaoFeedback? _feedback;

  @override
  bool get isSubmitting => _isSubmitting;

  @override
  AcaoFeedback? get feedback => _feedback;

  @override
  String? get description => null;

  @override
  double get width => 600;

  /// Valida o formulário e, só então, executa [onSubmit].
  ///
  /// Retorna `false` quando a validação reprova e [onSubmit] não chegou a ser
  /// executado.
  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    _isSubmitting = true;
    // Uma nova tentativa invalida o resultado da anterior — sem isso, o aviso
    // de erro do envio passado seguiria em cena durante o novo envio.
    _feedback = null;
    notifyListeners();
    try {
      await onSubmit();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
    return true;
  }

  void setFeedback(AcaoFeedback? feedback) {
    _feedback = feedback;
    notifyListeners();
  }
}

/// Template de corpo de tela para o arquétipo "formulário de cadastro/
/// criação", renderizado inteiramente a partir de um [BaseFormController].
///
/// Como os demais templates do pacote, cobre só o corpo da tela:
/// `AdminScaffold`, `AppBar` e rota atual ficam com a tela que compõe este
/// template, não aqui dentro.
class BaseFormScreen extends StatelessWidget {
  final BaseFormController controller;

  const BaseFormScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Center(
        child: Container(
          width: controller.width,
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      controller.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (controller.description != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        controller.description!,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                    if (controller.feedback != null) ...[
                      const SizedBox(height: 16),
                      BaseScreenFeedback(feedback: controller.feedback!),
                    ],
                    const SizedBox(height: 24),
                    for (final field in controller.fields) ...[
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
                      label: controller.submitLabel,
                      isLoading: controller.isSubmitting,
                      onPressed: controller.submit,
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
    );
  }
}

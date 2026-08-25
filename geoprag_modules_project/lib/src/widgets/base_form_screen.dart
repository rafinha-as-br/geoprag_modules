import 'package:flutter/material.dart';

import '../state/acao_feedback.dart';
import 'geoprag_submit_button.dart';

/// Template de corpo de tela para o arquétipo "formulário de cadastro/
/// criação" (`Center` → `Container(width: 600/700)` → `Card(elevation: 4,
/// radius: 16)` → `Padding(32)` → `Form`), hoje reimplementado
/// independentemente em 9 telas com 3 níveis de maturidade completamente
/// diferentes sob o mesmo visual: telas funcionais de verdade
/// (`GlobalKey<FormState>`, validators, submit ligado a um Cubit — ex.
/// `cadastro_de_aplicador_screen.dart`), uma tela intermediária com submit
/// não conectado (`cadastro_saida_screen.dart`) e telas puramente
/// decorativas sem `GlobalKey<FormState>`, sem validators e sem persistência
/// (ex. `cadastro_produto_screen.dart`) — o padrão visual não deixa a
/// diferença visível.
///
/// Por isso [formKey], [onSubmit] e a validação são parte **obrigatória** do
/// contrato deste template, não um detalhe que cada tela decide implementar
/// ou não: o botão de envio só chama [onSubmit] depois de
/// `formKey.currentState!.validate()` passar, e [onSubmit] é
/// `Future<void> Function()` (não opcional) — uma tela que usa
/// [BaseFormScreen] não tem como "parecer" funcional sem de fato estar.
///
/// [acaoFeedback] segue o contrato único de feedback pós-ação decidido em
/// GEOPRAG-77 ([AcaoFeedback]/[AcaoFeedbackSucesso]/[AcaoFeedbackErro]): a
/// cada novo valor não nulo, este template mostra um `SnackBar` estilizado
/// conforme sucesso ou erro, sem a tela precisar inspecionar a mensagem.
///
/// Este widget só cria o template — nenhuma das 9 telas é migrada para ele
/// aqui (escopo de GEOPRAG-94).
class BaseFormScreen extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String title;
  final Widget fields;
  final Future<void> Function() onSubmit;
  final String submitLabel;
  final bool isSubmitting;
  final AcaoFeedback? acaoFeedback;
  final double width;

  const BaseFormScreen({
    super.key,
    required this.formKey,
    required this.title,
    required this.fields,
    required this.onSubmit,
    required this.submitLabel,
    this.isSubmitting = false,
    this.acaoFeedback,
    this.width = 600,
  });

  @override
  State<BaseFormScreen> createState() => _BaseFormScreenState();
}

class _BaseFormScreenState extends State<BaseFormScreen> {
  @override
  void didUpdateWidget(covariant BaseFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final feedback = widget.acaoFeedback;
    // Comparação por identidade, não por valor: `AcaoFeedback` sobrescreve
    // `==` por (runtimeType, mensagem), então dois submits seguidos com a
    // mesma mensagem genérica (ex.: "Cadastro salvo com sucesso.") seriam
    // considerados o mesmo feedback e a segunda SnackBar nunca apareceria.
    if (feedback != null && !identical(feedback, oldWidget.acaoFeedback)) {
      // showSnackBar não pode ser chamado durante o build (didUpdateWidget
      // roda nesse momento) — adia para o fim do frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mostrarFeedback(feedback);
        }
      });
    }
  }

  void _mostrarFeedback(AcaoFeedback feedback) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(feedback.mensagem),
        backgroundColor: switch (feedback) {
          AcaoFeedbackSucesso() => Colors.green.shade700,
          AcaoFeedbackErro() => Colors.red.shade700,
        },
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }
    await widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.all(32.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: widget.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  widget.fields,
                  const SizedBox(height: 32),
                  GeopragSubmitButton(
                    label: widget.submitLabel,
                    isLoading: widget.isSubmitting,
                    onPressed: _handleSubmit,
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
    );
  }
}

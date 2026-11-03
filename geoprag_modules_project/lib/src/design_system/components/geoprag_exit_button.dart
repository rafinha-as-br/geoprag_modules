import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Guarda o `ValueNotifier` de "alteração não salva" que [GeopragExitButton]
/// observa, e o descarta junto do `State` — reutilizado pelas telas de
/// formulário do Portal Administrador em vez de cada uma repetir o mesmo
/// campo + `dispose()` (GEOPRAG-150).
mixin FormDirtyState<T extends StatefulWidget> on State<T> {
  final dirty = ValueNotifier(false);

  /// Passe como `BaseFormScreen.onChanged`.
  void marcarFormularioAlterado() => dirty.value = true;

  @override
  void dispose() {
    dirty.dispose();
    super.dispose();
  }
}

/// Botão de saída ("X") do `leading` de telas do arquétipo de formulário
/// (GEOPRAG-150): fecha a tela chamando [onExit], pedindo confirmação antes
/// se [isDirty] indicar alteração não salva.
///
/// [isDirty] normalmente vem do [FormDirtyState] misturado ao `State` da
/// tela — este widget não conhece o `Form` em si.
class GeopragExitButton extends StatelessWidget {
  const GeopragExitButton({
    super.key,
    required this.isDirty,
    required this.onExit,
  });

  final ValueListenable<bool> isDirty;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDirty,
      builder: (context, dirty, _) => IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Fechar',
        onPressed: () async {
          if (!dirty) {
            onExit();
            return;
          }
          final descartar = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Descartar alterações?'),
              content: const Text(
                'Há alterações não salvas neste formulário. Ao sair agora, '
                'elas serão perdidas.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Continuar editando'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Descartar e sair'),
                ),
              ],
            ),
          );
          if (descartar ?? false) onExit();
        },
      ),
    );
  }
}

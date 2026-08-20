import 'package:flutter/material.dart';

import '../theme/geoprag_colors.dart';

/// Componente único de tela de carregamento do tenant, unificando
/// `TenantLoadingScreen` (`aplicador_app`) e `AdminTenantLoadingScreen`
/// (`portal_administrador`) — mesmo propósito e estrutura
/// (`Scaffold`→`Center`), hoje implementados separadamente.
///
/// [progress] é o único requisito real que diferencia os dois casos: só o
/// app do aplicador baixa mapa offline e tem um estado de download com
/// progresso. Quando `null`, mostra spinner indeterminado; quando presente,
/// spinner determinístico + texto de porcentagem. O chamador continua
/// resolvendo o próprio `Cubit`/`State` (`TenantState` e `AdminTenantState`
/// são tipos distintos) e repassa o resultado já mapeado — a tela do
/// portal administrador hoje ignora `AdminTenantDownloading.progress` e
/// sempre mostra spinner indeterminado; ao migrar para este componente
/// (GEOPRAG-97), repassar o progresso corrige essa lacuna.
class GeopragTenantLoadingScreen extends StatelessWidget {
  final bool isError;
  final String? errorMessage;
  final double? progress;

  const GeopragTenantLoadingScreen({
    super.key,
    this.isError = false,
    this.errorMessage,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isError
            ? Text(
                'Não foi possível carregar a prefeitura: $errorMessage',
                style: const TextStyle(color: GeopragColors.statusAtrasado),
                textAlign: TextAlign.center,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: GeopragColors.green900,
                    value: progress,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    progress != null
                        ? 'Baixando mapa da prefeitura... ${(progress! * 100).round()}%'
                        : 'Carregando dados da prefeitura...',
                  ),
                ],
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import 'tenant_cubit.dart';
import 'tenant_state.dart';

/// Tela exibida pelo guard de tenant do `go_router` enquanto o
/// [AdminTenantCubit] ainda não emitiu [AdminTenantReady].
class AdminTenantLoadingScreen extends StatelessWidget {
  const AdminTenantLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<AdminTenantCubit, AdminTenantState>(
          builder: (context, state) {
            if (state is AdminTenantError) {
              return Text(
                'Não foi possível carregar a prefeitura: ${state.message}',
                style: TextStyle(color: GeopragColors.statusAtrasado),
                textAlign: TextAlign.center,
              );
            }
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: GeopragColors.green900),
                SizedBox(height: 16),
                Text('Carregando dados da prefeitura...'),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/administrador_repository.dart';
import 'criar_administrador_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/utils/senha_inicial_generator.dart';

/// Submete o formulário de criação de novo administrador (GEOPRAG-36) — o
/// resultado sempre nasce Sub-Administrador, ver [AdministradorRepository].
class CriarAdministradorCubit extends Cubit<CriarAdministradorState> {
  CriarAdministradorCubit(this._repository)
    : super(const CriarAdministradorIdle());

  final AdministradorRepository _repository;

  Future<void> submit({
    required String email,
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String sexo,
  }) async {
    emit(const CriarAdministradorSalvando());
    try {
      final conta = await _repository.criar(
        email: email,
        nome: nome,
        cpf: cpf,
        dataNascimento: dataNascimento,
        sexo: sexo,
      );
      final senhaGerada = gerarSenhaInicial(
        nome: nome,
        dataNascimento: dataNascimento,
      );
      emit(CriarAdministradorSucesso(conta, senhaGerada));
    } on EntidadeDuplicadaException catch (e) {
      emit(CriarAdministradorErro(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('CriarAdministradorCubit.submit', e, stackTrace);
      emit(CriarAdministradorErro(AppErrorMessages.carregamentoGenerico));
    }
  }
}

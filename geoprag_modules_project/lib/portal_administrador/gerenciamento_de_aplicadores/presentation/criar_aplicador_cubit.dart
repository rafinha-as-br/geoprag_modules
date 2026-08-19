import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/aplicador_repository.dart';
import 'criar_aplicador_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/utils/senha_inicial_generator.dart';

/// Submete o formulário de criação de novo Aplicador (GEOPRAG-65) — o
/// cadastro nasce sempre `Ativo`, ver [AplicadorRepository].
class CriarAplicadorCubit extends Cubit<CriarAplicadorState> {
  CriarAplicadorCubit(this._repository) : super(const CriarAplicadorIdle());

  final AplicadorRepository _repository;

  Future<void> submit({
    required String email,
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String sexo,
    required String cep,
    required String rua,
    required String numero,
    String? complemento,
    required String bairro,
    required String cidade,
    required String uf,
  }) async {
    emit(const CriarAplicadorSalvando());
    try {
      final aplicador = await _repository.criar(
        email: email,
        nome: nome,
        cpf: cpf,
        dataNascimento: dataNascimento,
        sexo: sexo,
        cep: cep,
        rua: rua,
        numero: numero,
        complemento: complemento,
        bairro: bairro,
        cidade: cidade,
        uf: uf,
      );
      final senhaGerada = gerarSenhaInicial(
        nome: nome,
        dataNascimento: dataNascimento,
      );
      emit(CriarAplicadorSucesso(aplicador, senhaGerada));
    } on EntidadeDuplicadaException catch (e) {
      emit(CriarAplicadorErro(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('CriarAplicadorCubit.submit', e, stackTrace);
      emit(CriarAplicadorErro(AppErrorMessages.carregamentoGenerico));
    }
  }
}

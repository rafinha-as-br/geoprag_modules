import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/usuario.dart';
import '../../gestao_de_aplicadores/core/aplicador_repository.dart';
import '../core/ponto_de_aplicacao_repository.dart';
import 'criar_ponto_state.dart';
import 'view_models/aplicador_opcao_view_model.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_logger.dart';

/// Submete o formulário de criação de um novo ponto de aplicação (GEOPRAG-38)
/// — não exige aplicador atribuído no momento da criação.
class CriarPontoCubit extends Cubit<CriarPontoState> {
  CriarPontoCubit(this._repository, this._aplicadorRepository)
    : super(const CriarPontoIdle());

  final AdminPontoDeAplicacaoRepository _repository;
  final AplicadorRepository _aplicadorRepository;

  /// Opções para o dropdown de atribuição — carregadas sob demanda pela
  /// tela, fora da máquina de estados de submissão (ver
  /// `PontoDeAplicacaoDetalheCubit.listarAplicadoresDisponiveis`).
  Future<List<AplicadorOpcaoViewModel>> listarAplicadoresDisponiveis() async {
    final aplicadores = await _aplicadorRepository.listar();
    return aplicadores
        .where((aplicador) => aplicador.status == UsuarioStatus.ativo)
        .map(AplicadorOpcaoViewModel.fromEntity)
        .toList();
  }

  Future<void> submit({
    required String bairro,
    required double lat,
    required double lng,
    String? aplicadorId,
  }) async {
    emit(const CriarPontoSalvando());
    try {
      final ponto = await _repository.criar(
        bairro: bairro,
        lat: lat,
        lng: lng,
        aplicadorId: aplicadorId,
      );
      emit(CriarPontoSucesso(ponto));
    } catch (e, stackTrace) {
      AppLogger.error('CriarPontoCubit.submit', e, stackTrace);
      emit(CriarPontoErro(AppErrorMessages.carregamentoGenerico));
    }
  }
}

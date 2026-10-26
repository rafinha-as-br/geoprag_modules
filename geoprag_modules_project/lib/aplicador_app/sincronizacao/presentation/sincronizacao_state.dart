import '../core/registro_sincronizavel.dart';

sealed class SincronizacaoState {
  const SincronizacaoState();
}

class SincronizacaoLoading extends SincronizacaoState {
  const SincronizacaoLoading();
}

class SincronizacaoLoaded extends SincronizacaoState {
  const SincronizacaoLoaded({
    required this.situacao,
    this.sincronizando = false,
    this.aviso,
  });

  final SituacaoDaSincronizacao situacao;

  /// "Sincronizar agora" em andamento.
  final bool sincronizando;

  /// Resultado da última ação manual quando não deu certo.
  final String? aviso;

  SincronizacaoLoaded copiarCom({
    SituacaoDaSincronizacao? situacao,
    bool? sincronizando,
    String? Function()? aviso,
  }) => SincronizacaoLoaded(
    situacao: situacao ?? this.situacao,
    sincronizando: sincronizando ?? this.sincronizando,
    aviso: aviso == null ? this.aviso : aviso(),
  );
}

class SincronizacaoError extends SincronizacaoState {
  const SincronizacaoError(this.message);

  final String message;
}

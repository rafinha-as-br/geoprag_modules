/// Ambiente de compilação do Geoprag.
///
/// O valor vem exclusivamente de `--dart-define=GEOPRAG_ENV=...`; nenhuma
/// URL, segredo ou credencial é derivada desta classe.
enum GeopragBuildEnvironment { desenvolvimento, homologacao, producao }

/// Configuração técnica do ambiente selecionado no build Flutter.
class GeopragBuildEnvironmentConfig {
  const GeopragBuildEnvironmentConfig(this.value);

  /// Lê o `dart-define` do build. Desenvolvimento é o padrão local seguro;
  /// valores desconhecidos falham cedo para não gerar um build ambíguo.
  factory GeopragBuildEnvironmentConfig.doAmbiente() {
    const value = String.fromEnvironment(
      'GEOPRAG_ENV',
      defaultValue: 'desenvolvimento',
    );
    return GeopragBuildEnvironmentConfig.deValor(value);
  }

  /// Constrói uma configuração validada a partir de [rawValue].
  factory GeopragBuildEnvironmentConfig.deValor(String rawValue) {
    final normalized = rawValue.trim().toLowerCase();
    return switch (normalized) {
      'desenvolvimento' || 'development' => const GeopragBuildEnvironmentConfig(
        GeopragBuildEnvironment.desenvolvimento,
      ),
      'homologacao' ||
      'homologação' ||
      'hml' => const GeopragBuildEnvironmentConfig(
        GeopragBuildEnvironment.homologacao,
      ),
      'producao' || 'produção' || 'production' || 'prod' =>
        const GeopragBuildEnvironmentConfig(GeopragBuildEnvironment.producao),
      _ => throw ArgumentError.value(
        rawValue,
        'GEOPRAG_ENV',
        'Use desenvolvimento, homologacao ou producao.',
      ),
    };
  }

  final GeopragBuildEnvironment value;

  bool get isHomologacao => value == GeopragBuildEnvironment.homologacao;

  bool get isProducao => value == GeopragBuildEnvironment.producao;
}

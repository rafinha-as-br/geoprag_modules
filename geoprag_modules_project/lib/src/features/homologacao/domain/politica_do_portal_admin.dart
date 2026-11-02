import '../../../core/environment/build_environment.dart';

/// Áreas funcionais apresentadas no Portal Administrador.
enum SecaoDoPortalAdmin {
  visaoGeral,
  aplicacoes,
  aplicadores,
  estoque,
  distribuicoes,
  denuncias,
  administradores,
}

/// Política de disponibilidade do Portal por ambiente de compilação.
///
/// Esta política controla somente a experiência do cliente. Autenticação,
/// autorização e isolamento de tenant continuam obrigatoriamente no servidor.
class PoliticaDoPortalAdmin {
  const PoliticaDoPortalAdmin(this._environment);

  /// Tenant exclusivo do piloto de Gaspar no ambiente de homologação.
  static const String tenantDeHomologacao = 'gaspar-sc-hml';

  final GeopragBuildEnvironmentConfig _environment;

  bool get isHomologacao => _environment.isHomologacao;

  /// A simulação sem geolocalização existe apenas para o piloto HML.
  bool get permiteSimulacaoDeAplicacao => isHomologacao;

  /// Em produção e desenvolvimento todas as seções atuais continuam
  /// disponíveis. Em HML, somente a Gestão de Aplicações entra no piloto;
  /// inclusive o cadastro administrativo de aplicadores permanece oculto
  /// porque ainda usa dados mockados. A atribuição usa a lista HTTP dentro da
  /// própria Gestão de Aplicações.
  bool permiteSecao(SecaoDoPortalAdmin secao) {
    if (!isHomologacao) return true;
    return switch (secao) {
      SecaoDoPortalAdmin.aplicacoes => true,
      _ => false,
    };
  }

  /// Política para guards das rotas de módulos no aplicativo consumidor.
  ///
  /// O valor deve ser usado apenas para rotas internas de módulos já
  /// conhecidos; login e rotas globais não pertencem a esta decisão.
  bool permiteRotaDeModulo(String location) {
    if (!isHomologacao) return true;
    final path = Uri.tryParse(location)?.path ?? location;
    return switch (path) {
      '/aplicacoes' => true,
      _ when path.startsWith('/aplicacoes/') => true,
      _ => false,
    };
  }

  /// Garante que o tenant recebido no login é o tenant do piloto HML.
  ///
  /// Fora de homologação o servidor é a única fonte de autorização e não há
  /// uma lista de tenants permitidos no cliente.
  void validarTenantDoPortal(String tenantId) {
    if (!isHomologacao) return;
    if (tenantId.trim() != tenantDeHomologacao) {
      throw ArgumentError.value(
        tenantId,
        'tenantId',
        'O Portal em homologação aceita somente o tenant '
            '"$tenantDeHomologacao".',
      );
    }
  }
}

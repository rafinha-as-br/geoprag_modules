import 'bairro.dart';

/// Bairros do município.
abstract interface class BairroRepository {
  /// Todos os bairros, em ordem alfabética.
  Future<List<Bairro>> listar();
}

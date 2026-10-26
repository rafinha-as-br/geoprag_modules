import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/monitor_de_conexao.dart';

/// [MonitorDeConexao] sobre o `connectivity_plus`.
class MonitorDeConexaoConnectivity implements MonitorDeConexao {
  MonitorDeConexaoConnectivity([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<void> get aoConectar => _connectivity.onConnectivityChanged
      .where((tipos) => tipos.any((tipo) => tipo != ConnectivityResult.none))
      .map((_) {});
}

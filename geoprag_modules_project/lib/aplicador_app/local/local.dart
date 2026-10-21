/// Armazenamento local do App Aplicador (GEOPRAG-189): banco SQLite, DAOs e
/// outbox. Fica fora de `geoprag_modules.dart` de propósito: o portal (web) usa
/// esse arquivo e não deve carregar o `sqflite`.
library;

export 'aplicacao_dao.dart';
export 'aplicacao_dao_sqflite.dart';
export 'banco_local.dart';
export 'esquema.dart';
export 'item_da_outbox.dart';
export 'outbox_dao.dart';
export 'outbox_dao_sqflite.dart';
export 'ponto_dao.dart';
export 'ponto_dao_sqflite.dart';

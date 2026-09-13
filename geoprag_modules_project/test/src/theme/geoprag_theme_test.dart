import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/theme/geoprag_theme.dart';

void main() {
  testWidgets('GEOPRAG-128: título da AppBar é centralizado por padrão', (
    tester,
  ) async {
    expect(GeopragTheme.light().appBarTheme.centerTitle, isTrue);
  });
}

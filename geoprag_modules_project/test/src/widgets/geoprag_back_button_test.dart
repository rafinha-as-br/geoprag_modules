import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/widgets/geoprag_back_button.dart';

void main() {
  testWidgets('chama onBack ao ser tocado, sem confirmação nenhuma', (
    tester,
  ) async {
    var backCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GeopragBackButton(onBack: () => backCount++)),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();

    expect(backCount, 1);
  });
}

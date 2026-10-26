import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/comprovante_recebimento_pdf.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/distribuicao_view_model.dart';

void main() {
  DistribuicaoDetalhadaViewModel distribuicao(String status) =>
      DistribuicaoDetalhadaViewModel(
        produtoNome: 'BTI Líquido - Lote L-001',
        quantidade: 2,
        unidade: 'Litros',
        dataEntrega: '01/06/2026',
        responsavel: 'João Silva',
        bairroResponsavel: 'Belchior',
        statusConfirmacao: status,
        confirmadoEm: '02/06/2026 09:30',
      );

  test('gera um PDF válido para recebimento confirmado', () async {
    final bytes = await gerarComprovanteRecebimentoPdf(
      distribuicao('confirmado'),
    );

    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
  });

  test('não gera comprovante sem recebimento confirmado', () {
    expect(
      () => gerarComprovanteRecebimentoPdf(distribuicao('aguardando_aceite')),
      throwsStateError,
    );
  });
}

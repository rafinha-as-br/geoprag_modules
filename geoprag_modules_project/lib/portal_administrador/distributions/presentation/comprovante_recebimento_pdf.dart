import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import 'distribuicao_view_model.dart';

/// Gera o comprovante de recebimento em PDF de uma distribuição com
/// recebimento confirmado (GEOPRAG-166) — equivalente digital da ficha
/// assinada usada como documento de auditoria.
///
/// Campos e layout provisórios, a serem ajustados ao modelo da Prefeitura
/// quando ele chegar. O endereço do aplicador é o bairro: o cadastro ainda
/// não traz endereço completo.
///
/// Lança [StateError] se o recebimento não foi confirmado.
Future<Uint8List> gerarComprovanteRecebimentoPdf(
  DistribuicaoDetalhadaViewModel d,
) async {
  if (d.statusConfirmacao != 'confirmado') {
    throw StateError('Comprovante só é gerado com recebimento confirmado.');
  }
  final linhas = {
    'Aplicador': d.responsavel,
    'Endereço': d.bairroResponsavel,
    'Produto / Lote': d.produtoNome,
    'Quantidade': '${d.quantidade} ${d.unidade}',
    'Data da entrega': d.dataEntrega,
    'Confirmação no App': d.confirmadoEm ?? 'não informada',
  };
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Comprovante de Recebimento de Insumo',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 24),
          for (final e in linhas.entries)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text('${e.key}: ${e.value}'),
            ),
        ],
      ),
    ),
  );
  return doc.save();
}

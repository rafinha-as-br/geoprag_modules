/// "Nenhum registro pendente de envio", "1 registro pendente de envio"…
String textoDosPendentes(int pendentes) => switch (pendentes) {
  0 => 'Nenhum registro pendente de envio',
  1 => '1 registro pendente de envio',
  _ => '$pendentes registros pendentes de envio',
};

String textoDaUltimaSincronizacao(DateTime? ultima) => ultima == null
    ? 'Ainda não sincronizado neste aparelho'
    : 'Última sincronização: ${formatarDataHora(ultima)}';

/// `21/10/2026 às 09:30`.
String formatarDataHora(DateTime data) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(data.day)}/${dois(data.month)}/${data.year} às '
      '${dois(data.hour)}:${dois(data.minute)}';
}

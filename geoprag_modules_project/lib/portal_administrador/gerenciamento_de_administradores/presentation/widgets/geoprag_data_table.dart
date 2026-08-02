import 'package:flutter/material.dart';

/// Uma coluna de [GeopragDataTable]: rótulo do cabeçalho, largura e como
/// renderizar a célula de cada linha a partir do item [T].
class GeopragDataColumn<T> {
  final String label;
  final TableColumnWidth width;
  final Widget Function(BuildContext context, T item) cellBuilder;

  const GeopragDataColumn({
    required this.label,
    required this.width,
    required this.cellBuilder,
  });
}

/// Tabela genérica para listagens de cadastro (usuários, e potencialmente
/// outras entidades tabulares do Portal Administrador) — extraída do
/// dashboard de Gerenciamento de Administradores para reuso por outros
/// módulos (feedback de revisão do PR #9: "mais módulos vão usar de
/// tabelas para exibir dados").
///
/// Cada linha ocupa a largura toda como alvo de toque — usa
/// [TableRowInkWell] para o destaque de toque cobrir todas as células da
/// mesma linha, não só uma célula isolada. Se [onRowTap] não for informado,
/// as linhas não são clicáveis (só a formatação de tabela é reaproveitada).
class GeopragDataTable<T> extends StatelessWidget {
  final List<GeopragDataColumn<T>> columns;
  final List<T> items;
  final void Function(T item)? onRowTap;

  const GeopragDataTable({
    super.key,
    required this.columns,
    required this.items,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      columnWidths: {
        for (var i = 0; i < columns.length; i++) i: columns[i].width,
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: [
            for (final coluna in columns)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  coluna.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        for (final item in items) _buildRow(context, item),
      ],
    );
  }

  TableRow _buildRow(BuildContext context, T item) {
    Widget celula(Widget child) {
      final comPadding = Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      );
      if (onRowTap == null) return comPadding;
      return TableRowInkWell(onTap: () => onRowTap!(item), child: comPadding);
    }

    return TableRow(
      children: [
        for (final coluna in columns) celula(coluna.cellBuilder(context, item)),
      ],
    );
  }
}

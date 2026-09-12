import 'package:flutter/material.dart';

/// Placeholder visual para a ausência de um SDK de mapa real integrado
/// (fora de escopo deste pacote — ver observação "Fora de escopo" do épico
/// GEOPRAG-76). Cobre o padrão `Container`+`Icon`+`Text` repetido em
/// `visualizacao_de_aplicacao_screen.dart`,
/// `visualizacao_individual_denuncia_screen.dart` e
/// `dashboard_geral_screen.dart`. Deixe [height] nulo para telas que
/// envolvem o placeholder em `Expanded` em vez de usar altura fixa; deixe
/// [icon] nulo para telas que não mostram ícone.
///
/// Em `mapa_hidrologico_screen.dart` (pins posicionados sobre o mapa) e em
/// `marcacao_do_ponto_screen.dart`/`geolocalizacao_screen.dart` (círculo de
/// precisão + pin central), este widget também é usado, mas como camada de
/// fundo dentro de um `Stack`/`Positioned.fill` — os elementos extras
/// (pins, círculo) são compostos por cima pela própria tela, sem herdar
/// nem estender este widget (GEOPRAG-95).
class GeopragMapPlaceholder extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double? height;
  final IconData? icon;
  final Color? iconColor;

  const GeopragMapPlaceholder({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.height,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: textColor);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: icon == null
            ? Text(message, textAlign: TextAlign.center, style: textStyle)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: iconColor ?? textColor, size: 48),
                  Text(message, textAlign: TextAlign.center, style: textStyle),
                ],
              ),
      ),
    );
  }
}

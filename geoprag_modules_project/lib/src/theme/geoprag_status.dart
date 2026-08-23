import 'package:flutter/material.dart';

import 'geoprag_colors.dart';

/// Os três estados funcionais reconhecidos pela marca GeoPrag
/// (seção 02 e 05 do guia de marca): em dia, atrasado e denúncia.
enum GeopragStatus { emDia, atrasado, denuncia }

extension GeopragStatusStyle on GeopragStatus {
  Color get color {
    switch (this) {
      case GeopragStatus.emDia:
        return GeopragColors.statusEmDia;
      case GeopragStatus.atrasado:
        return GeopragColors.statusAtrasado;
      case GeopragStatus.denuncia:
        return GeopragColors.statusDenuncia;
    }
  }

  Color get background => color.withValues(alpha: 0.12);

  String get defaultLabel {
    switch (this) {
      case GeopragStatus.emDia:
        return 'Em dia';
      case GeopragStatus.atrasado:
        return 'Atrasado';
      case GeopragStatus.denuncia:
        return 'Denúncia';
    }
  }
}

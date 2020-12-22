import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

///hover extension that can be added to any widget
///just supporting default and pointer cusrsor style
///primarily used for the web (may be desktops as well)
extension HoverExtensions on Widget {
  static final appContainer = kIsWeb ? html.window.document.querySelectorAll('flt-glass-pane')[0] : null;
  static const String pointer = 'pointer';
  Widget get xShowPointerOnHover => MouseRegion(
        child: this,
        //on mouse enter
        onHover: (event) => appContainer != null ? appContainer.style.cursor = 'pointer' : '',
        //on mouse exit
        onExit: (event) => appContainer != null ? appContainer.style.cursor = 'default' : '',
      );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///home for FocusableActionDetector related implementation
class XFAD extends StatelessWidget {
  final Function onEscCallback;
  final Function onTabCallback;
  final Function onShiftTabCallback;
  final Function onEnterCallback;
  final ValueChanged<bool> onHoverCallback;
  final Widget child;

  XFAD({
    this.child,
    this.onEscCallback,
    this.onTabCallback,
    this.onShiftTabCallback,
    this.onEnterCallback,
    this.onHoverCallback,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FocusableActionDetector(
        actions: _initActions(),
        shortcuts: _initShortcuts(),
        onShowHoverHighlight: onHoverCallback,
        child: child,
      );

  _initShortcuts() => <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.escape): _XIntent.esc(),
        LogicalKeySet(LogicalKeyboardKey.tab): _XIntent.tab(),
        LogicalKeySet.fromSet({LogicalKeyboardKey.tab, LogicalKeyboardKey.shift}): _XIntent.shiftTab(),
        LogicalKeySet(LogicalKeyboardKey.enter): _XIntent.enter(),
      };

  void _actionHandler(_XIntent intent) {
    switch (intent.type) {
      case _XIntentType.Esc:
        if (onEscCallback != null) onEscCallback();
        break;
      case _XIntentType.Tab:
        if (onTabCallback != null) onTabCallback();
        break;
      case _XIntentType.ShifTab:
        if (onShiftTabCallback != null) onShiftTabCallback();
        break;
      case _XIntentType.Enter:
        if (this.onEnterCallback != null) onEnterCallback();
        break;
    }
  }

  _initActions() => <Type, Action<Intent>>{
        _XIntent: CallbackAction<_XIntent>(
          onInvoke: _actionHandler,
        ),
      };
}

class _XIntent extends Intent {
  final _XIntentType type;
  const _XIntent({this.type});

  const _XIntent.esc() : type = _XIntentType.Esc;
  const _XIntent.tab() : type = _XIntentType.Tab;
  const _XIntent.shiftTab() : type = _XIntentType.ShifTab;
  const _XIntent.enter() : type = _XIntentType.Enter;
}

enum _XIntentType {
  Esc,
  Tab,
  ShifTab,
  Enter,
}

import 'dart:ui';

import 'package:flutter/material.dart';

///Overlay widget that be parent of any widget to show overlay content
///This is generic implementation refer x_search_textbox or x_search_dropdown for real widget implementation
///supports multiple widgets that are mutually exclusive
class XOverlay extends StatefulWidget {
  final Widget child;
  final Map<String, Widget> insideOverlayWidgetMap;
  final XOverlayController xOverlayController;
  //callback function when the overlay is hidden
  final Function onHideOverlayFunc;

  XOverlay({
    @required this.child,
    @required this.insideOverlayWidgetMap,
    @required this.xOverlayController,
    @required this.onHideOverlayFunc,
    Key key,
  }) : super(key: key);

  @override
  _XOverlayState createState() {
    _XOverlayState state = _XOverlayState();
    xOverlayController?._xOverlayState = state;
    return state;
  }
}

///xoverlay stack ... handle on multiple overlays as stack
///this is helpful in hiding or shown contents as and when required
///is very handy when we have nested overlays
class XOverlayStack {
  static final XOverlayStack _instance = XOverlayStack._init();
  final List<XOverlayController> _stack = [];

  factory XOverlayStack() {
    return _instance;
  }

  XOverlayStack._init();

  void _push(XOverlayController x) => _stack.add(x);

  void hideAll() {
    if (_stack.length > 0) _stack.forEach((element) => element.hideOverlay(false));
  }

  ///first visible from last
  void hideFirstVisible() {
    if (_stack.length > 0) _stack.reversed.firstWhere((element) => element.isVisible())?.hideOverlay(false);
  }

  void _remove(XOverlayController x) {
    x.hideOverlay(false);
    _stack.remove(x);
  }

  XOverlayController peek() => _stack.length > 0 ? _stack.last : null;
}

///controller to provider handle to the parent with some useful methods
///also refer XOverlayStack
class XOverlayController {
  _XOverlayState _xOverlayState;

  XOverlayController() {
    XOverlayStack()._push(this);
  }

  void hideOverlay(removeFocus) => _xOverlayState._hideOverlay(removeFocus);
  void showOverlay(String widgetId) => _xOverlayState._showOverlay(widgetId);
  bool isVisible() => _xOverlayState.isVisible;
  void dispose() => XOverlayStack()._remove(this);
}

class _XOverlayState extends State<XOverlay> {
  GlobalKey _globalKeyParent = GlobalKey();
  OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool isVisible = false;

  _XOverlayState();

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
        link: this._layerLink,
        child: Container(
          key: _globalKeyParent,
          child: widget.child,
        ),
      );

  ///overlay with glass pane + actual body
  OverlayEntry _overlay(String widgetId) => OverlayEntry(
        builder: (context) => _globalKeyParent.currentContext != null
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  _glassPanelLeft(),
                  _glassPanelBottom(),
                  _glassPanelRight(),
                  _glassPanelTop(),
                  _overlayBody(widgetId),
                ],
              )
            : Container(),
      );

  ///actual body of overlay eg: list
  Widget _overlayBody(widgetId) {
    RenderBox renderBox = _globalKeyParent.currentContext.findRenderObject();
    var size = renderBox.size;
    return Positioned(
      width: size.width,
      //height: widget.overlayHeight,
      child: CompositedTransformFollower(
        link: this._layerLink,
        showWhenUnlinked: false,
        offset: Offset(0, size.height),
        child: Material(
          elevation: 2,
          child: widget.insideOverlayWidgetMap[widgetId],
        ),
      ),
    );
  }

  ///show overlay
  void _showOverlay(String widgetId) {
    if (_overlayEntry != null) {
      _overlayEntry.remove();
      _overlayEntry = null;
    }

    _overlayEntry = _overlay(widgetId);
    Overlay.of(context).insert(_overlayEntry);
    isVisible = true;
  }

  ///hide overlay
  void _hideOverlay(removeFocus) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    widget.onHideOverlayFunc();
    if (removeFocus) WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    isVisible = false;
  }

  ///start: glass panel
  ///glass panel to the bottom
  Widget _glassPanelBottom() {
    RenderBox renderBox = _globalKeyParent.currentContext.findRenderObject();
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    return _glassPane(
      left: 0,
      top: offset.dy + size.height,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
    );
  }

  ///glass panel to the left
  Widget _glassPanelLeft() {
    RenderBox renderBox = _globalKeyParent.currentContext.findRenderObject();
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    return _glassPane(
      left: 0,
      top: offset.dy,
      width: offset.dx,
      height: size.height,
    );
  }

  ///glass panel to the right
  Widget _glassPanelRight() {
    RenderBox renderBox = _globalKeyParent.currentContext.findRenderObject();
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    return _glassPane(
      left: offset.dx + size.width,
      top: offset.dy,
      width: MediaQuery.of(context).size.width - (offset.dx + size.width),
      height: size.height,
    );
  }

  ///glass panel to the right
  Widget _glassPanelTop() {
    RenderBox renderBox = _globalKeyParent.currentContext.findRenderObject();
    Offset offset = renderBox.localToGlobal(Offset.zero);
    return _glassPane(
      left: 0,
      top: 0,
      width: MediaQuery.of(context).size.width,
      height: offset.dy,
    );
  }

  ///glass pane that covers the whole screen
  Widget _glassPane({double left, double top, double width, double height}) => Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: GestureDetector(
          onTap: () => _hideOverlay(true),
          child: Container(
            //color: Colors.greenAccent,
            color: Colors.transparent,
          ),
        ),
      );

  ///end: glass panel
}

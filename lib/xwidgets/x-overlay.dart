import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:xoverlay/xwidgets/x-fad.dart';

///Overlay widget that be parent of any widget to show overlay content
///This is a genetic implementation refer x-search-textbox for an example
class XOverlay extends StatefulWidget {
  final Widget child;
  final Map<String, Widget> insideOverlayWidgetMap;
  final XOverlayController xOverlayController;
  //only when this widget closes overlay eg: click on glass pane or esc key
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

///controller to provider handle to the parent on when to show and hide overlay widget
class XOverlayController {
  _XOverlayState _xOverlayState;

  XOverlayController();

  void hideOverlay(removeFocus) => _xOverlayState._hideOverlay(removeFocus);
  void showOverlay(String widgetId) => _xOverlayState._showOverlay(widgetId);
}

///notification to hide
class XOverlayHideNotification extends Notification {
  const XOverlayHideNotification();
}

class _XOverlayState extends State<XOverlay> {
  GlobalKey _globalKeyParent = GlobalKey();
  OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  _XOverlayState();

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
        link: this._layerLink,
        child: XFAD(
          onEscFunc: () => _hideOverlay(true),
          child: Container(
            key: _globalKeyParent,
            child: widget.child,
          ),
        ),
      );

  ///overlay with glass pane + actual body
  OverlayEntry _overlay(String widgetId) => OverlayEntry(
        builder: (context) => _globalKeyParent.currentContext != null
            ? NotificationListener<XOverlayHideNotification>(
                onNotification: (xOverlayHideNotification) {
                  _hideOverlay(true);
                  return true;
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _glassPanelLeft(),
                    _glassPanelBottom(),
                    _glassPanelRight(),
                    _glassPanelTop(),
                    _overlayBody(widgetId),
                  ],
                ),
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
  }

  ///hide overlay
  void _hideOverlay(removeFocus) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    widget.onHideOverlayFunc();
    if (removeFocus) WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
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
            //color: Colors.red,
            color: Colors.transparent,
          ),
        ),
      );

  ///end: glass panel
}

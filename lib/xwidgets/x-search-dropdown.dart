import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xoverlay/xwidgets/x-fad.dart';
import 'package:xoverlay/xwidgets/x-overlay.dart';
import 'package:xoverlay/xwidgets/hover_extension.dart';

typedef void SearchCallback(freeSearchTextAsUserIsTyping);
typedef String InitialValueCallback();

class XSearchDropdown extends StatefulWidget {
  final String labelText;
  final Widget searchListInOverlay;
  final bool autoFocus;
  final FocusNode searchTextFocusNode;
  final XSearchDropdownController xSearchDropdownController;
  final Function onShiftTabCallback;
  final Function onTabCallback;
  final SearchCallback searchCallbackFunc;
  final InitialValueCallback initialValueCallback;

  const XSearchDropdown({
    @required this.labelText,
    @required this.initialValueCallback,
    @required this.searchCallbackFunc,
    @required this.searchListInOverlay,
    @required this.onTabCallback,
    @required this.onShiftTabCallback,
    @required this.searchTextFocusNode,
    @required this.xSearchDropdownController,
    this.autoFocus: false,
    Key key,
  }) : super(key: key);

  @override
  _XSearchDropdownState createState() {
    _XSearchDropdownState state = _XSearchDropdownState();
    xSearchDropdownController?._xSearchDropdownState = state;
    return state;
  }
}

class XSearchDropdownController {
  _XSearchDropdownState _xSearchDropdownState;

  XSearchDropdownController();

  void setText({String text, bool hide}) {
    _xSearchDropdownState._textEditingController.text = text;
    _xSearchDropdownState._textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: _xSearchDropdownState._textEditingController.text.length));
    _xSearchDropdownState._focus();
    if (hide != null && hide) _xSearchDropdownState._hide();
  }
}

class _XSearchDropdownState extends State<XSearchDropdown> {
  final XOverlayController _xOverlayController = XOverlayController();
  final TextEditingController _textEditingController = TextEditingController();

  bool _showSearchOverlay = false;
  bool _initialLoadStatus = false;
  String _currentSearchVal;

  @override
  void initState() {
    super.initState();
    _currentSearchVal = widget.initialValueCallback();
    _textEditingController.text = widget.initialValueCallback();
    this._showSearchOverlay = false;
    _searchTextEditingControllerListener();
    _searchTextFocusNodeListener();
  }

  void _hide() => setState(() => _showSearchOverlay = false);

  void _focus() => widget.searchTextFocusNode.requestFocus();

  ///as and when there is a change in search textfield
  void _searchTextEditingControllerListener() => _textEditingController.addListener(() {
        if (_currentSearchVal != _textEditingController.text) {
          _currentSearchVal = _textEditingController.text;
          widget.searchCallbackFunc(_textEditingController.text);
        }

        _showSearchOverlay = widget.searchTextFocusNode.hasFocus && _textEditingController.text.isNotEmpty;
      });

  ///focus listener on textfield
  void _searchTextFocusNodeListener() => widget.searchTextFocusNode.addListener(() {
        if (!widget.searchTextFocusNode.hasFocus) setState(() => _showSearchOverlay = false);
      });

  ///display overlay
  void _displayAppropriateOverlay() => WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _showSearchOverlay ? _xOverlayController.showOverlay('list') : _xOverlayController.hideOverlay(false);
      });

  @override
  Widget build(BuildContext context) {
    _displayAppropriateOverlay();

    return XOverlay(
      onHideOverlayFunc: () => setState(() {
        _showSearchOverlay = false;
      }),
      insideOverlayWidgetMap: {'list': widget.searchListInOverlay},
      xOverlayController: _xOverlayController,
      child: Container(
        child: Stack(children: [
          _searchTextfield(),
          Positioned(
            right: 3,
            top: 6,
            child: IconButton(
              splashRadius: 20,
              icon: Icon(_showSearchOverlay ? Icons.arrow_drop_down : Icons.arrow_drop_up, color: Colors.grey[500]),
              onPressed: () => setState(() {
                _showSearchOverlay = !_showSearchOverlay;
                if (!_initialLoadStatus) {
                  _initialLoadStatus = true;
                  widget.searchCallbackFunc(_textEditingController.text);
                }
              }),
            ),
          ),
        ]),
      ),
    );
  }

  ///container top margin is for a glitch in web
  Widget _searchTextfield() => Container(
        margin: EdgeInsets.fromLTRB(0, kIsWeb ? 1 : 0, 0, 0),
        child: XFAD(
          onEscCallback: () {
            _xOverlayController.hideOverlay(true);
            XOverlayHideNotification()..dispatch(context);
          },
          onTabCallback: () => widget.onTabCallback(),
          onShiftTabCallback: () => widget.onShiftTabCallback(),
          child: TextField(
            autofocus: widget.autoFocus,
            cursorColor: Color.fromRGBO(155, 155, 155, 1),
            showCursor: true,
            focusNode: widget.searchTextFocusNode,
            controller: _textEditingController,
            style: const TextStyle(fontWeight: FontWeight.normal),
            decoration: InputDecoration(labelText: widget.labelText, counterText: ''),
          ),
        ),
      );

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }
}

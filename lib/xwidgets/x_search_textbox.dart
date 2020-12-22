import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'xwidget_barrel.dart';

///a composite search textbox (like gmail or google news)
///uses x_overlay.dart to display all overlays
///features:
///1. 'suggest list' that appears right below textbox
///2. 'x' icon appears to clear existing text search
///3. 'search options' that appears below textbox (optional)
///4. 'pick a filter' that appears below textbox (optional)
///
///all overlay widgets are mutually exclusive

///search callback function (to refresh the actual search list)
typedef void SearchCallbackText(freeSearchText);

///this is for suggestion
typedef void SuggestCallback(freeSearchTextAsUserIsTyping);

class XSearchTextbox extends StatefulWidget {
  final String searchHintText;
  final String initialvalue;
  final String filterName;
  final SearchCallbackText searchCallback;
  final SuggestCallback suggestCallbackFunc;
  final Widget suggestListInOverlay;
  final Widget searchOptionsInOverlay;
  final Widget filterOptionsInOverlay;

  const XSearchTextbox({
    @required this.searchHintText,
    @required this.initialvalue,
    @required this.searchCallback,
    @required this.suggestCallbackFunc,
    @required this.suggestListInOverlay,
    this.searchOptionsInOverlay,
    this.filterOptionsInOverlay,
    this.filterName,
    Key key,
  }) : super(key: key);

  @override
  _XSearchTextboxState createState() => _XSearchTextboxState();
}

class _XSearchTextboxState extends State<XSearchTextbox> {
  final XOverlayController _xOverlayController = XOverlayController();
  final TextEditingController _searchTextEditingController = TextEditingController();
  final FocusNode _searchTextFocusNode = FocusNode();

  ///state fields for suggest overlay
  //bool _firstFocus = true;
  bool _showSuggestOverlay = false;
  String _currentSearchVal;

  ///state field for search options overlay
  bool _showSearchOptionsOverlay = false;

  ///state field for filter options overlay
  bool _showFilterOptionsOverlay = false;

  @override
  void initState() {
    super.initState();

    _currentSearchVal = widget.initialvalue;
    _searchTextEditingController.text = widget.initialvalue;
    this._showSuggestOverlay = false;

    _searchTextEditingControllerListener();

    _searchTextFocusNodeListener();
  }

  ///as and when there is a change in search textfield
  void _searchTextEditingControllerListener() => _searchTextEditingController.addListener(() => setState(() {
        if (_currentSearchVal != _searchTextEditingController.text) {
          _currentSearchVal = _searchTextEditingController.text;
          widget.suggestCallbackFunc(_searchTextEditingController.text);
        }

        _showSuggestOverlay = _searchTextFocusNode.hasFocus && _searchTextEditingController.text.isNotEmpty; //&& !_firstFocus;
      }));

  ///focus listener on textfield
  void _searchTextFocusNodeListener() => _searchTextFocusNode.addListener(() {
        if (_searchTextFocusNode.hasFocus) {
          setState(() {
            _showSearchOptionsOverlay = false;
            _showFilterOptionsOverlay = false;
            _showSuggestOverlay = _searchTextEditingController.text.isNotEmpty;
          });
        }
      });

  ///display either suggest or search options overlay on post frame callback
  void _displayAppropriateOverlay() => WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (_searchTextFocusNode.hasFocus && _showSuggestOverlay)
          _xOverlayController.showOverlay('suggest');
        else if (_showSearchOptionsOverlay) {
          _xOverlayController.showOverlay('searchOptions');
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        } else if (_showFilterOptionsOverlay) {
          _xOverlayController.showOverlay('filterOptions');
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        } else
          _xOverlayController.hideOverlay(false);
      });

  @override
  Widget build(BuildContext context) {
    _displayAppropriateOverlay();
    return XOverlay(
      onHideOverlayFunc: () {
        _showSuggestOverlay = false;
        _showSearchOptionsOverlay = false;
        _showFilterOptionsOverlay = false;
      },
      insideOverlayWidgetMap: {
        'suggest': widget.suggestListInOverlay,
        if (widget.searchOptionsInOverlay != null) 'searchOptions': widget.searchOptionsInOverlay,
        if (widget.filterOptionsInOverlay != null) 'filterOptions': widget.filterOptionsInOverlay,
      },
      xOverlayController: _xOverlayController,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 3, 10, 2),
        constraints: BoxConstraints(maxWidth: 500, minWidth: 500),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(flex: 1, child: _searchIcon()),
            Flexible(flex: 8, child: _searchTextfield()),
            Flexible(
              flex: 1,
              child: _searchTextEditingController.text.isNotEmpty ? _searchClear() : Container(width: 42),
            ),
            if (widget.searchOptionsInOverlay != null) Flexible(flex: 1, child: _searchOptions()),
            if (widget.filterOptionsInOverlay != null) Flexible(flex: 1, child: _filters()),
          ],
        ),
      ),
    );
  }

  ///central place to invoke callbacl searchFunc
  ///need to set initialvalue before routing
  void _callSearchFunc() {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    String toSearch = this._searchTextEditingController.text;

    ///set initial value back it .. for routing context
    ///set to current value to avoid textcontroller listener listening to the change
    _currentSearchVal = widget.initialvalue;
    this._searchTextEditingController.text = widget.initialvalue;

    ///should always be false when exiting out as it should be collapsed between routes
    _showSuggestOverlay = false;
    this.widget.searchCallback(toSearch);
  }

  Widget _searchIcon() => Tooltip(
        message: 'Search',
        child: IconButton(
          icon: Icon(Icons.search, color: Colors.grey[800]),
          onPressed: () => _callSearchFunc(),
          splashRadius: 25,
        ),
      );

  ///container top margin is for a glitch in web
  Widget _searchTextfield() => Container(
        margin: EdgeInsets.fromLTRB(0, kIsWeb ? 1 : 0, 0, 0),
        child: TextField(
          autofocus: false,
          cursorColor: Color.fromRGBO(155, 155, 155, 1),
          showCursor: true,
          focusNode: _searchTextFocusNode,
          controller: this._searchTextEditingController,
          onSubmitted: (val) => _callSearchFunc(),
          style: TextStyle(fontWeight: FontWeight.normal),
          decoration: InputDecoration(
            isCollapsed: false,
            isDense: true,
            hintText: widget.searchHintText,
            hintStyle: TextStyle(color: Color.fromRGBO(155, 155, 155, 1), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: Colors.grey[100],
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[200]),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[200]),
            ),
            hoverColor: Colors.transparent,
          ),
        ),
      );

  Widget _searchClear() => Tooltip(
        message: 'Clear Search',
        child: IconButton(
          icon: Icon(Icons.close, color: Colors.grey[800]),
          onPressed: () {
            this._searchTextEditingController.text = '';
            _callSearchFunc();
          },
          splashRadius: 25,
        ),
      );

  Widget _searchOptions() => Tooltip(
        message: 'Search Options',
        child: IconButton(
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[800]),
          onPressed: () {
            setState(() {
              _showSearchOptionsOverlay = !_showSearchOptionsOverlay;
              if (_showSearchOptionsOverlay) {
                _showSuggestOverlay = false;
                _showFilterOptionsOverlay = false;
              }
            });
          },
          splashRadius: 25,
        ).xShowPointerOnHover,
      );

  Widget _filters() => Tooltip(
        message: this.widget.filterName ?? 'Filter Options',
        child: IconButton(
          icon: Icon(Icons.filter_alt_sharp, color: Colors.grey[600], size: 20),
          onPressed: () {
            setState(() {
              _showFilterOptionsOverlay = !_showFilterOptionsOverlay;
              if (_showFilterOptionsOverlay) {
                _showSuggestOverlay = false;
                _showSearchOptionsOverlay = false;
              }
            });
          },
          splashRadius: 25,
        ),
      );

  @override
  void dispose() {
    this._searchTextFocusNode.dispose();
    this._searchTextEditingController.dispose();
    _xOverlayController.dispose();
    super.dispose();
  }
}

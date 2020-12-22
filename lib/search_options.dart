import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'random_list.dart';
import 'xwidgets/xwidget_barrel.dart';

typedef void SearchCallback(searchText);

class SearchOptionsScreen extends StatefulWidget {
  final String currentSearch;
  final SearchCallback searchCallback;
  SearchOptionsScreen({
    @required this.currentSearch,
    @required this.searchCallback,
    Key key,
  }) : super(key: key);

  @override
  _SearchOptionsScreenState createState() => _SearchOptionsScreenState();
}

class _SearchOptionsScreenState extends State<SearchOptionsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  XSearchDropdownController _fromXDropdownController = XSearchDropdownController();
  final _fromFocus = FocusNode();
  final _toFocus = FocusNode();
  final _subjectFocus = FocusNode();
  final _hasTheWordsFocus = FocusNode();
  final _closeFocus = FocusNode();
  final _searchFocus = FocusNode();

  String _fromValue = '';
  List<WordPair> _dataListForFrom;
  int _fromListSelectedIndex = -1;
  String _hasWords = '';

  _SearchOptionsScreenState();

  @override
  Widget build(BuildContext context) => _searchOptionContainer(context: context, fields: <Widget>[
        _hasWordsField(),
        _fromField(),
        _toField(),
        _subjectField(),
        SizedBox(height: 15),
        _searchAndCloseButton(),
      ]);

  Widget _searchOptionContainer({context, List<Widget> fields}) => XFAD(
        onEscCallback: () => XOverlayStack().hideFirstVisible(),
        child: Form(
          key: _formKey,
          child: Scrollbar(
            child: Container(
              height: kIsWeb ? 375 : 425,
              padding: EdgeInsets.fromLTRB(20, kIsWeb ? 15 : 0, 20, 15),
              child: ListView(
                children: fields
                    .map((e) => Container(
                          margin: EdgeInsets.fromLTRB(2, 0, 2, 15),
                          child: e,
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      );

  ///search and close button
  Widget _searchAndCloseButton() => Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 25,
        spacing: 25,
        children: [
          SizedBox(width: 0),
          Wrap(
            children: [
              SizedBox(
                width: 90,
                child: XFAD(
                  onEscCallback: () => XOverlayStack().hideFirstVisible(),
                  onTabCallback: () => _closeFocus.requestFocus(),
                  onShiftTabCallback: () => _subjectFocus.requestFocus(),
                  child: SizedBox(
                    height: 40,
                    child: RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child: Text('Search', style: TextStyle(color: Colors.white)),
                      onPressed: () => _search(),
                      focusNode: _searchFocus,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 25),
              SizedBox(
                width: 90,
                child: XFAD(
                  onEscCallback: () => XOverlayStack().hideFirstVisible(),
                  onTabCallback: () => _hasTheWordsFocus.requestFocus(),
                  onShiftTabCallback: () => _searchFocus.requestFocus(),
                  child: SizedBox(
                    height: 40,
                    child: RaisedButton(
                      color: Colors.grey[600],
                      child: Text('Close', style: TextStyle(color: Colors.white)),
                      focusNode: _closeFocus,
                      onPressed: () => XOverlayStack().hideFirstVisible(),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      );

  void _search() {
    _formKey.currentState.save();
    widget.searchCallback(_hasWords);
  }

  Widget _hasWordsField() => XFAD(
        onEscCallback: () => XOverlayStack().hideFirstVisible(),
        onTabCallback: () => _fromFocus.requestFocus(),
        onShiftTabCallback: () => _closeFocus.requestFocus(),
        child: TextFormField(
          autofocus: true,
          focusNode: _hasTheWordsFocus,
          keyboardType: TextInputType.text,
          maxLength: 50,
          maxLines: 1,
          minLines: 1,
          decoration: InputDecoration(labelText: 'Has Words', counterText: ''),
          initialValue: widget.currentSearch,
          onSaved: (value) => _hasWords = value,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _search(),
        ),
      );

  Widget _fromField() {
    return _keyboardSupportForFrom(
      dataList: _dataListForFrom,
      child: XSearchDropdown(
        xSearchDropdownController: _fromXDropdownController,
        searchTextFocusNode: _fromFocus,
        searchCallback: (freeSearchTextAsUserIsTyping) => setState(() {
          _fromValue = freeSearchTextAsUserIsTyping;
          _fromListSelectedIndex = -1;
          String srch = this._fromValue == null || this._fromValue == '' ? 'a' : this._fromValue.toLowerCase();
          _dataListForFrom = generateWordPairs(maxSyllables: 10).take(1000).toList()..removeWhere((element) => element.first[0] != srch[srch.length - 1]);
          _dataListForFrom = _dataListForFrom.length > 5 ? _dataListForFrom.sublist(0, 5) : _dataListForFrom;
        }),
        onSubmitted: (value) {
          if (_fromListSelectedIndex < 0) {
            _search();
          } else {
            setState(() {
              _fromValue = '${_dataListForFrom[_fromListSelectedIndex].first} - ${_dataListForFrom[_fromListSelectedIndex].second}';
              _fromXDropdownController.setText(text: _fromValue, hide: true);
            });
          }
        },
        searchListInOverlay: RandomList(
          selectedIndex: _fromListSelectedIndex,
          dataList: _dataListForFrom,
          icon: Icon(Icons.person),
          selectedItemCallback: (val) => setState(() {
            _fromValue = val;
            _fromXDropdownController.setText(text: _fromValue, hide: true);
          }),
        ),
        labelText: 'From',
        initialValueCallback: () => _fromValue,
        autoFocus: true,
      ),
    );
  }

  Widget _keyboardSupportForFrom({@required Widget child, @required List<WordPair> dataList}) => XFAD(
        onEscCallback: () => _fromXDropdownController.isOpen() ? _fromXDropdownController.hide() : XOverlayStack().hideFirstVisible(),
        onShiftTabCallback: () => _hasTheWordsFocus.requestFocus(),
        onTabCallback: () => _toFocus.requestFocus(),
        onArrowDownCallback: () {
          if (dataList != null && dataList.length > 0) {
            setState(() {
              _fromListSelectedIndex = (_fromListSelectedIndex + 1 >= dataList.length) ? 0 : _fromListSelectedIndex + 1;
            });
          }
        },
        onArrowUpCallback: () {
          if (dataList != null && dataList.length > 0) {
            setState(() {
              _fromListSelectedIndex = (_fromListSelectedIndex - 1 < 0) ? dataList.length - 1 : _fromListSelectedIndex - 1;
            });
          }
        },
        child: child,
      );

  Widget _toField() => XFAD(
        onEscCallback: () => XOverlayStack().hideFirstVisible(),
        onTabCallback: () => _subjectFocus.requestFocus(),
        onShiftTabCallback: () => _fromFocus.requestFocus(),
        child: TextFormField(
          autofocus: true,
          focusNode: _toFocus,
          keyboardType: TextInputType.text,
          maxLength: 50,
          maxLines: 1,
          minLines: 1,
          decoration: InputDecoration(labelText: 'To', counterText: ''),
          initialValue: '',
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _search(),
        ),
      );

  Widget _subjectField() => XFAD(
        onEscCallback: () => XOverlayStack().hideFirstVisible(),
        onTabCallback: () => _searchFocus.requestFocus(),
        onShiftTabCallback: () => _toFocus.requestFocus(),
        child: TextFormField(
          autofocus: true,
          focusNode: _subjectFocus,
          keyboardType: TextInputType.text,
          maxLength: 50,
          maxLines: 1,
          minLines: 1,
          decoration: InputDecoration(labelText: 'Subject', counterText: ''),
          initialValue: '',
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _search(),
        ),
      );

  @override
  void dispose() {
    _fromFocus.dispose();
    _toFocus.dispose();
    _subjectFocus.dispose();
    _hasTheWordsFocus.dispose();
    _closeFocus.dispose();
    _searchFocus.dispose();
    super.dispose();
  }
}

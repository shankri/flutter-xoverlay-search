import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

import 'filter_options_screen.dart';
import 'random_list_screen.dart';
import 'search_options_screen.dart';
import 'xwidgets/xwidget_barrel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Overlay',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blueAccent,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedFilterIndex = 0;
  String _searchTextAsUserIsTyping = '';
  String _currentSearch = '';

  ///list related
  int _listSelectedIndex = -1;
  List<WordPair> _dataList;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: _mainBody(),
            toolbarHeight: 75,
            elevation: 0,
          ),
          bottomNavigationBar: Container(
            color: Colors.grey[800],
            alignment: Alignment.center,
            height: 50,
            child: Text('Search widget with Overlays', style: TextStyle(color: Colors.white70, fontSize: 16)),
          ),
          body: Container(
            color: Colors.grey[200],
            child: Center(
                child: Text(
              _currentSearch.isEmpty ? 'start searching...' : 'results for "$_currentSearch"',
              style: TextStyle(fontSize: Theme.of(context).textTheme.headline3.fontSize, color: Colors.grey[600]),
            )),
          ),
        ),
      );

  Widget _mainBody() => _keyboardSupport(
        child: XSearchTextbox(
          key: Key(_currentSearch),
          searchOptionsInOverlay: _searchOptionsWidget(),
          suggestCallbackFunc: (freeSearchTextAsUserIsTyping) => setState(() {
            this._searchTextAsUserIsTyping = freeSearchTextAsUserIsTyping;
            String srch = this._searchTextAsUserIsTyping == null || this._searchTextAsUserIsTyping == '' ? 'a' : this._searchTextAsUserIsTyping.toLowerCase();
            _dataList = generateWordPairs(maxSyllables: 10).take(1000).toList()..removeWhere((element) => element.first[0] != srch[srch.length - 1]);
            _dataList = _dataList.length > 5 ? _dataList.sublist(0, 5) : _dataList;
          }),
          searchHintText: 'Search words',
          initialvalue: _currentSearch,
          searchCallback: (freeSearchValue) => setState(() {
            if (_listSelectedIndex > -1)
              _currentSearch = '${_dataList[_listSelectedIndex].first} - ${_dataList[_listSelectedIndex].second}';
            else
              _currentSearch = freeSearchValue;
            _searchTextAsUserIsTyping = _currentSearch;
            _listSelectedIndex = -1;
          }),
          suggestListInOverlay: _suggestListWdiget(),
          filterOptionsInOverlay: _filterOptionsWidget(),
        ),
      );

  ///suggest list widget
  Widget _suggestListWdiget() => RandomList(
      selectedIndex: _listSelectedIndex,
      dataList: _dataList,
      icon: Icon(Icons.mail_sharp, size: 20),
      selectedItemCallback: (selected) => setState(() {
            XOverlayStack().hideAll();
            _currentSearch = selected;
            _searchTextAsUserIsTyping = _currentSearch;
          }));

  ///widget that appears for search options as overlay
  Widget _searchOptionsWidget() => SearchOptionsScreen(
      key: Key(_searchTextAsUserIsTyping),
      currentSearch: _searchTextAsUserIsTyping,
      searchCallback: (freeSearchValue) => setState(() {
            XOverlayStack().hideAll();
            _currentSearch = freeSearchValue;
            _searchTextAsUserIsTyping = _currentSearch;
          }));

  ///widget that appears for filter options as overlay
  Widget _filterOptionsWidget() => FilterOptions(
        selectedFilterIndex: _selectedFilterIndex,
        selectFilterCallback: (index) => setState(() => _selectedFilterIndex = index),
      );

  ///escape: hide overlay
  ///arrow up & arrow down: navigate through the list
  Widget _keyboardSupport({Widget child}) => XFAD(
        onEscCallback: () => XOverlayStack().hideFirstVisible(),
        onArrowDownCallback: () {
          if (_dataList != null && _dataList.length > 0) {
            setState(() {
              _listSelectedIndex = (_listSelectedIndex + 1 >= _dataList.length) ? 0 : _listSelectedIndex + 1;
            });
          }
        },
        onArrowUpCallback: () {
          if (_dataList != null && _dataList.length > 0) {
            setState(() {
              _listSelectedIndex = (_listSelectedIndex - 1 < 0) ? _dataList.length - 1 : _listSelectedIndex - 1;
            });
          }
        },
        child: child,
      );
}
//

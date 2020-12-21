import 'package:flutter/material.dart';
import 'package:xoverlay/random_list.dart';
import 'package:xoverlay/search_options.dart';
import 'package:xoverlay/xwidgets/x-overlay.dart';
import 'package:xoverlay/xwidgets/x-search-textbox.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  String _searchTextAsUserIsTyping = '';
  String _currentSearch = '';

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: _searchTextbox(),
            toolbarHeight: 75,
            elevation: 0,
          ),
          body: Center(child: Text(_currentSearch)),
        ),
      );

  Widget _searchTextbox() {
    return XSearchTextbox(
      key: Key(_currentSearch),
      searchOptionsInOverlay: SearchOptionsScreen(
          key: Key(_searchTextAsUserIsTyping),
          currentSearch: _searchTextAsUserIsTyping,
          searchCallback: (freeSearchValue) => setState(() {
                XOverlayStack().hideAll();
                _currentSearch = freeSearchValue;
                _searchTextAsUserIsTyping = _currentSearch;
              })),
      suggestCallbackFunc: (freeSearchTextAsUserIsTyping) => setState(() => this._searchTextAsUserIsTyping = freeSearchTextAsUserIsTyping),
      searchHintText: 'Search words',
      initialvalue: _currentSearch,
      searchCallback: (freeSearchValue) => setState(() {
        _currentSearch = freeSearchValue;
        _searchTextAsUserIsTyping = _currentSearch;
      }),
      suggestListInOverlay: RandomList(
          freeSearchTextAsUserIsTyping: _searchTextAsUserIsTyping,
          icon: Icon(Icons.mail_sharp, size: 20),
          selectedItemCallback: (selected) => setState(() {
                XOverlayStack().hideAll();
                _currentSearch = selected;
                _searchTextAsUserIsTyping = _currentSearch;
              })),
    );
  }
}
//

import 'package:flutter/material.dart';
import 'package:xoverlay/random_list.dart';
import 'package:xoverlay/search_options.dart';
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
  String _freeSearchTextAsUserIsTyping = '';
  String _currentSearch = '';

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: _searchTextbox(),
            toolbarHeight: 75,
          ),
          body: Center(child: Text(_currentSearch)),
        ),
      );

  Widget _searchTextbox() {
    return XSearchTextbox(
      key: Key(_currentSearch),
      searchOptionsInOverlay: SearchOptionsScreen(),
      suggestCallbackFunc: (freeSearchTextAsUserIsTyping) => setState(() => this._freeSearchTextAsUserIsTyping = freeSearchTextAsUserIsTyping),
      searchHintText: 'Search words',
      initialvalue: _currentSearch,
      searchFunc: (freeSearchValue) => setState(() => _currentSearch = freeSearchValue),
      suggestListInOverlay: RandomList(
          //key: Key(_freeSearchTextAsUserIsTyping),
          freeSearchTextAsUserIsTyping: _freeSearchTextAsUserIsTyping,
          icon: Icon(Icons.mail_sharp, size: 20),
          selectedItemCallback: (selected) => setState(() => _currentSearch = selected)),
    );
  }
}
//

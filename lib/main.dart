import 'package:flutter/material.dart';
import 'package:xoverlay/RandomList.dart';
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
  String freeSearchTextAsUserIsTyping = '';

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: _searchTextbox(),
            toolbarHeight: 75,
          ),
          body: Center(child: Text('Main body here')),
        ),
      );

  Widget _searchTextbox() => XSearchTextbox(
        searchOptionsInOverlay: SearchOptionsScreen(),
        suggestCallbackFunc: (freeSearchTextAsUserIsTyping) => setState(() => this.freeSearchTextAsUserIsTyping = freeSearchTextAsUserIsTyping),
        searchHintText: 'Search words',
        initialvalue: '',
        searchFunc: (freeSearchValue) => print('time to search: $freeSearchValue'),
        suggestListInOverlay: RandomList(
          key: Key(freeSearchTextAsUserIsTyping),
          freeSearchTextAsUserIsTyping: freeSearchTextAsUserIsTyping,
          icon: Icon(Icons.mail),
        ),
      );
}

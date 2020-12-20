import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'xwidgets/x-fad.dart';
import 'xwidgets/hover_extension.dart';

typedef void SelectedItemCallback(selected);

class RandomList extends StatefulWidget {
  final SelectedItemCallback selectedItemCallback;
  final String freeSearchTextAsUserIsTyping;
  final Icon icon;

  const RandomList({
    @required this.freeSearchTextAsUserIsTyping,
    @required this.icon,
    this.selectedItemCallback,
    Key key,
  }) : super(key: key);

  @override
  _RandomListState createState() => _RandomListState();
}

class _RandomListState extends State<RandomList> {
  bool _hovering = false;
  int _selectedIndex = -1;
  List<WordPair> _dummyList;

  @override
  void initState() {
    super.initState();
    String srch = widget.freeSearchTextAsUserIsTyping == null || widget.freeSearchTextAsUserIsTyping == '' ? 'a' : widget.freeSearchTextAsUserIsTyping;
    _dummyList = generateWordPairs(maxSyllables: 10).take(1000).toList()..removeWhere((element) => element.first[0] != srch[srch.length - 1]);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      itemCount: _dummyList.length > 5 ? 5 : _dummyList.length,
      itemBuilder: (context, index) {
        return XFAD(
          onHoverCallback: (bool value) => setState(() {
            _hovering = value;
            _selectedIndex = index;
          }),
          child: Container(
            decoration: BoxDecoration(
                color: _hovering && _selectedIndex == index ? const Color.fromRGBO(220, 220, 220, 0.6) : Colors.transparent,
                border: Border(
                  top: BorderSide(color: const Color.fromRGBO(220, 220, 220, 0.6)),
                  bottom: BorderSide(color: const Color.fromRGBO(220, 220, 220, 0.6)),
                  left: BorderSide(
                    color: _hovering && _selectedIndex == index ? Theme.of(context).primaryColor : Colors.transparent,
                    width: 3,
                  ),
                )),
            child: ListTile(
              hoverColor: Colors.transparent,
              leading: widget.icon,
              title: Text('${_dummyList[index].first} - ${_dummyList[index].second}'),
              onTap: () {
                if (widget.selectedItemCallback != null) widget.selectedItemCallback('${_dummyList[index].first} - ${_dummyList[index].second}');
              },
            ),
          ).xShowPointerOnHover,
        );
      },
    );
  }
}

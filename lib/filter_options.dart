import 'package:flutter/material.dart';
import 'package:xoverlay/xwidgets/x-overlay.dart';

import 'xwidgets/hover_extension.dart';

const List<String> _filters = ['All', 'Inbox', 'Social', 'Promotions'];
typedef void SelectFilterCallback(int index);

class FilterOptions extends StatefulWidget {
  final int selectedFilterIndex;
  final SelectFilterCallback selectFilterCallback;

  FilterOptions({
    @required this.selectedFilterIndex,
    @required this.selectFilterCallback,
    Key key,
  }) : super(key: key);

  @override
  _FilterOptionsState createState() => _FilterOptionsState(selectedFilterIndex);
}

class _FilterOptionsState extends State<FilterOptions> {
  int selectedIndex;
  _FilterOptionsState(this.selectedIndex);

  @override
  Widget build(BuildContext context) => ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: const Color.fromRGBO(220, 220, 220, 0.6)))),
            child: _tile(index),
          ).xShowPointerOnHover;
        },
      );

  Widget _tile(index) => ListTile(
        hoverColor: Colors.grey[200],
        leading: selectedIndex == index ? Icon(Icons.check, color: Theme.of(context).primaryColor) : Icon(Icons.filter_alt_sharp, color: Colors.grey[300]),
        title: Text(_filters[index]),
        onTap: () {
          setState(() {
            selectedIndex = index;
            Future.delayed(Duration(milliseconds: 300), () async {
              XOverlayStack().hideFirstVisible();
              widget.selectFilterCallback(selectedIndex);
            });
          });
        },
      );
}

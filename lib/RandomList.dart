import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

typedef void SelectedItemCallback(selected);

class RandomList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    String srch = freeSearchTextAsUserIsTyping == null || freeSearchTextAsUserIsTyping == '' ? 'a' : freeSearchTextAsUserIsTyping;
    List<WordPair> dummyList = generateWordPairs(maxSyllables: 10).take(1000).toList()..removeWhere((element) => element.first[0] != srch[srch.length - 1]);
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      itemCount: dummyList.length > 5 ? 5 : dummyList.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(border: Border.fromBorderSide(BorderSide(color: Colors.grey[200]))),
          child: ListTile(
            leading: icon,
            title: Text('${dummyList[index].first} - ${dummyList[index].second}'),
            hoverColor: Colors.grey[200],
            onTap: () {
              if (selectedItemCallback != null) selectedItemCallback('${dummyList[index].first} - ${dummyList[index].second}');
            },
          ),
        );
      },
    );
  }
}

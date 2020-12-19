import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xoverlay/RandomList.dart';
import 'package:xoverlay/xwidgets/x-fad.dart';
import 'package:xoverlay/xwidgets/x-overlay.dart';
import 'package:xoverlay/xwidgets/x-search-dropdown.dart';

class SearchOptionsScreen extends StatefulWidget {
  SearchOptionsScreen({Key key}) : super(key: key);

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

  _SearchOptionsScreenState();

  @override
  Widget build(BuildContext context) => _searchOptionContainer(context: context, fields: <Widget>[
        _fromField(),
        _toField(),
        _subjectField(),
        _hasWordsField(),
        SizedBox(height: 15),
        _searchAndCloseButton(),
      ]);

  Widget _searchOptionContainer({context, List<Widget> fields}) => XFAD(
        onEscFunc: () => XOverlayHideNotification()..dispatch(context),
        child: Form(
          key: _formKey,
          child: Scrollbar(
            child: Container(
              height: kIsWeb ? 375 : 425,
              padding: EdgeInsets.fromLTRB(20, kIsWeb ? 15 : 0, 20, 15),
              child: ListView(
                children: fields
                    .map((e) => Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
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
                  onEscFunc: () => XOverlayHideNotification()..dispatch(context),
                  onTabFunc: () => _closeFocus.requestFocus(),
                  onShiftTabFunc: () => _hasTheWordsFocus.requestFocus(),
                  child: ElevatedButton(
                    child: Text('Search'),
                    onPressed: () => _search(),
                    focusNode: _searchFocus,
                  ),
                ),
              ),
              SizedBox(width: 25),
              SizedBox(
                width: 90,
                child: XFAD(
                  onEscFunc: () => XOverlayHideNotification()..dispatch(context),
                  onTabFunc: () => _fromFocus.requestFocus(),
                  onShiftTabFunc: () => _searchFocus.requestFocus(),
                  child: ElevatedButton(
                    child: Text('Close'),
                    focusNode: _closeFocus,
                    onPressed: () => XOverlayHideNotification()..dispatch(context),
                  ),
                ),
              )
            ],
          ),
        ],
      );

  void _search() {
    _formKey.currentState.save();
    XOverlayHideNotification()..dispatch(context);
  }

  Widget _fromField() => XSearchDropdown(
        xSearchDropdownController: _fromXDropdownController,
        searchTextFocusNode: _fromFocus,
        onShiftTabCallback: () => _closeFocus.requestFocus(),
        onTabCallback: () => _toFocus.requestFocus(),
        searchCallbackFunc: (freeSearchTextAsUserIsTyping) => setState(() {
          _fromValue = freeSearchTextAsUserIsTyping;
        }),
        searchListInOverlay: RandomList(
          freeSearchTextAsUserIsTyping: _fromValue,
          icon: Icon(Icons.person),
          selectedItemCallback: (val) => setState(() {
            _fromValue = val;
            _fromXDropdownController.setText(text: _fromValue, hide: true);
          }),
        ),
        labelText: 'From',
        initialValueCallback: () => _fromValue,
        autoFocus: true,
      );

  Widget _toField() => XFAD(
        onEscFunc: () => XOverlayHideNotification()..dispatch(context),
        onTabFunc: () => _subjectFocus.requestFocus(),
        onShiftTabFunc: () => _fromFocus.requestFocus(),
        onEnter: () => this._search(),
        child: TextFormField(
          autofocus: true,
          focusNode: _toFocus,
          keyboardType: TextInputType.text,
          maxLength: 50,
          maxLines: 1,
          minLines: 1,
          decoration: InputDecoration(labelText: 'To', counterText: ''),
          initialValue: '',
          onSaved: (value) => print('not saving it for demo'),
          textInputAction: TextInputAction.next,
        ),
      );

  Widget _subjectField() => XFAD(
        onEscFunc: () => XOverlayHideNotification()..dispatch(context),
        onTabFunc: () => _hasTheWordsFocus.requestFocus(),
        onShiftTabFunc: () => _toFocus.requestFocus(),
        onEnter: () => this._search(),
        child: TextFormField(
          autofocus: true,
          focusNode: _subjectFocus,
          keyboardType: TextInputType.text,
          maxLength: 50,
          maxLines: 1,
          minLines: 1,
          decoration: InputDecoration(labelText: 'Subject', counterText: ''),
          initialValue: '',
          onSaved: (value) => print('not saving it for demo'),
          textInputAction: TextInputAction.next,
        ),
      );

  Widget _hasWordsField() => XFAD(
        onEscFunc: () => XOverlayHideNotification()..dispatch(context),
        onTabFunc: () => _searchFocus.requestFocus(),
        onShiftTabFunc: () => _subjectFocus.requestFocus(),
        onEnter: () => this._search(),
        child: TextFormField(
          autofocus: true,
          focusNode: _hasTheWordsFocus,
          keyboardType: TextInputType.text,
          maxLength: 50,
          maxLines: 1,
          minLines: 1,
          decoration: InputDecoration(labelText: 'Has Words', counterText: ''),
          initialValue: '',
          onSaved: (value) => print('not saving it for demo'),
          textInputAction: TextInputAction.next,
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

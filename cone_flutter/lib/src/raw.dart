// import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart' hide Actions;
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
// import 'package:cone_lib/cone_lib.dart';

// import 'package:cone/src/add_transaction.dart' show transactionSnackBar;
// import 'package:cone/src/redux/actions.dart';
import 'package:cone/src/redux/state.dart';
// import 'package:cone/src/reselect.dart';

class Raw extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<ConeState, String>(
      converter: (Store<ConeState> store) => store.state.contents,
      builder: (_, String contents) => Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Text.rich(
            TextSpan(
              text: contents,
            ),
            softWrap: false,
            style: const TextStyle(
              fontFamily: 'IBMPlexMono',
            ),
          ),
        ),
      ),
    );
  }
}

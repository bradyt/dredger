import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart' hide Actions;
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:cone_lib/cone_lib.dart';

import 'package:cone/src/add_transaction.dart' show transactionSnackBar;
import 'package:cone/src/redux/actions.dart';
import 'package:cone/src/redux/state.dart';
import 'package:cone/src/reselect.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<ConeState, bool>(
      converter: (Store<ConeState> store) =>
          hideAddTransactionButton(store.state),
      builder: (BuildContext context, bool hideAddTransactionButton) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('cone'),
            actions: <Widget>[SettingsButton()],
          ),
          body: Transactions(),
          floatingActionButton:
              hideAddTransactionButton ? null : AddTransactionButton(),
        );
      },
    );
  }
}

class Transactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreBuilder<ConeState>(
        builder: (BuildContext context, Store<ConeState> store) {
      final ConeState state = store.state;

      final BuiltList<Transaction> transactions = (state.journal == null)
          ? BuiltList<Transaction>()
          : reselectTransactions(state).toBuiltList();

      final bool loading = state.isRefreshing;

      return Stack(
        children: <Widget>[
          if (loading) const Center(child: CircularProgressIndicator()),
          Opacity(
            opacity: loading ? 0.5 : 1.0,
            child: RefreshIndicator(
              onRefresh: () {
                store.dispatch(Actions.refreshFileContents);
                return store.onChange
                    .firstWhere((ConeState state) => !state.isRefreshing);
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (BuildContext context, int index) => Padding(
                  padding: EdgeInsets.fromLTRB(4, (index == 0) ? 8 : 0, 4,
                      (index == transactions.length - 1) ? 8 : 0),
                  child: Card(
                    color: (index == store.state.transactionIndex &&
                            store.state.transactionIndex != -1)
                        ? ((Theme.of(context).brightness == Brightness.dark)
                            ? const Color(0xff556b2f) // darkolivegreen
                            : const Color(0xff8fbc8f)) // darkseagreen2
                        : null,
                    elevation: 3,
                    child: InkWell(
                      onTap: () => store
                          .dispatch(UpdateTransactionIndexAction(index: index)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child: FormattedJournalItem(
                          transaction: transactions[index],
                          dark: Theme.of(context).brightness == Brightness.dark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class FormattedJournalItem extends StatelessWidget {
  const FormattedJournalItem({@required this.transaction, @required this.dark});

  // Color choices taken from
  // https://github.com/emacs-mirror/emacs/blob/emacs-26.3/lisp/font-lock.el
  // comment: firebrick/chocolate1
  // builtin: dark slate blue/ LightSteelBlue
  // constant: dark cyan/ Aquamarine
  // function: Blue1/ LightSky
  // keyword: Purple/Cyan1
  // string: VioletRed4/LightSalmon
  // type: ForestGreen/PaleGreen
  // warning: Red1/Pink

  // Mapping transaction elements to Emacs colors follows that of ledger-mode.el

  final Transaction transaction;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    Widget formattedJournalItem;
    final Color colorNewline =
        dark ? const Color(0xffa9a9a9) : const Color(0xffd3d3d3);
    // final Color colorBuiltin =
    //     dark ? const Color(0xffb0c4de) : const Color(0xff483d8b);
    // final Color colorComment =
    //     dark ? const Color(0xffff7f24) : const Color(0xffb22222);
    if (transaction is Transaction) {
      final Color colorConstant =
          dark ? const Color(0xff7fffd4) : const Color(0xff008b8b);
      // final Color colorString =
      //     dark ? const Color(0xffffa07a) : const Color(0xff8b2252);
      final Color colorKeyword =
          dark ? const Color(0xff00ffff) : const Color(0xff800080);
      final Color colorWarning =
          dark ? const Color(0xffffc0cb) : const Color(0xffff6a6a);
      final String date = transaction.date;
      final String description = transaction.description;
      final Widget column = Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FormatString(
                text: date,
                color: colorKeyword,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      const FormatString(text: ' '),
                      FormatString(
                        text: description,
                        color: colorWarning,
                      ),
                      FormatString(
                        text: '\$',
                        color: colorNewline,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          for (final Posting posting in transaction.postings)
            Builder(
              builder: (BuildContext _) {
                final String account = posting.account;
                final Amount amount = posting.amount;
                return Row(
                  children: <Widget>[
                    const FormatString(text: '  '),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: FormatString(
                          text: account,
                          color: null,
                        ),
                      ),
                    ),
                    if (amount != null)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: FormatString(
                          text: amount.toString(),
                          color: colorConstant,
                        ),
                      ),
                  ],
                );
              },
            ) // else Text(line)
          ,
        ],
      );
      formattedJournalItem = column;
      // } else if (RegExp(r'[A-Za-z]').hasMatch(chunk[0])) {
      //   formattedChunk = SingleChildScrollView(
      //     scrollDirection: Axis.horizontal,
      //     child: Builder(
      //       builder: (BuildContext _) {
      //         final List<String> lines = chunk.split('\n');
      //         return Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: <Widget>[
      //             for (String line in lines)
      //               Row(
      //                 children: <Widget>[
      //                   FormatString(
      //                     text: line,
      //                     color: colorBuiltin,
      //                   ),
      //                   FormatString(
      //                     text: '\$',
      //                     color: colorNewline,
      //                   ),
      //                 ],
      //               ),
      //           ],
      //         );
      //       },
      //     ),
      //   );
      // } else {
      //   formattedChunk = SingleChildScrollView(
      //     scrollDirection: Axis.horizontal,
      //     child: Builder(
      //       builder: (BuildContext _) {
      //         final List<String> lines = chunk.split('\n');
      //         return Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: <Widget>[
      //             for (String line in lines)
      //               Row(
      //                 children: <Widget>[
      //                   FormatString(
      //                     text: line,
      //                     color: colorComment,
      //                   ),
      //                   FormatString(
      //                     text: '\$',
      //                     color: colorNewline,
      //                   ),
      //                 ],
      //               ),
      //           ],
      //         );
      //       },
      //     ),
      //   );
    }
    return formattedJournalItem;
  }
}

class FormatString extends StatelessWidget {
  const FormatString({@required this.text, this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
      ),
      style: TextStyle(
        fontFamily: 'IBMPlexMono',
        color: color,
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreBuilder<ConeState>(
      builder: (BuildContext context, Store<ConeState> store) {
        return IconButton(
          key: const Key('Settings'),
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        );
      },
    );
  }
}

class AddTransactionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreBuilder<ConeState>(
      builder: (BuildContext context, Store<ConeState> store) {
        return FloatingActionButton(
          heroTag: '''the only floating action button here \
${DateTime.now().millisecondsSinceEpoch}''',
          onPressed: () {
            store
              ..dispatch(Actions.today)
              ..dispatch(UpdateTodayAction(DateTime.now()))
              ..dispatch(Actions.updateHintTransaction);
            Navigator.pushNamed<dynamic>(context, '/add-transaction')
                .then((dynamic transaction) {
              if (transaction != null) {
                Scaffold.of(context).showSnackBar(
                  transactionSnackBar(transaction: transaction as Transaction),
                );
              }
              store
                ..dispatch(Actions.resetTransaction)
                ..dispatch(Actions.refreshFileContents);
            });
          },
          child: (store.state.transactionIndex == -1)
              ? const Icon(Icons.add)
              : const Icon(Icons.content_copy),
        );
      },
    );
  }
}

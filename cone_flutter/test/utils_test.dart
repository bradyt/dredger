import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';

import 'package:cone_lib/cone_lib.dart'
    show
        Amount,
        AmountBuilder,
        // Journal,
        Posting,
        PostingBuilder,
        Transaction,
        TransactionBuilder;
import 'package:cone_lib/pad_zeros.dart' show padZeros;

import 'package:cone/src/utils.dart'
    show
        // accounts,
        blendHintTransaction,
        // descriptions,
        filterSuggestions,
        localeSpacing,
        localeCurrency,
        localeCurrencyOnLeft,
        sortSuggestions,
        implicitTransaction;

void main() {
  test('Test localeSpacing.', () {
    expect(localeSpacing('en'), 0);
    expect(localeSpacing('de'), 1);
    expect(localeSpacing('ja'), 0);
  });
  test('Test localeCurrencyOnLeft.', () {
    expect(localeCurrencyOnLeft('en'), true);
    expect(localeCurrencyOnLeft('de'), false);
    expect(localeCurrencyOnLeft('ja'), true);
  });
  test('Test localeCurrency.', () {
    expect(localeCurrency('en'), 'USD');
    expect(localeCurrency('de'), 'EUR');
    expect(localeCurrency('ja'), 'JPY');
  });
  // test('Test descriptions.', () {
  //   expect(
  //     descriptions(Journal(contents: '2000-01-01 example')),
  //     <String>['example'],
  //   );
  // });
  test('Test accounts.', () {
    // expect(
    //   accounts(Journal(contents: 'account a')),
    //   <String>['a'],
    // );
    // expect(
    //   accounts(Journal(contents: '2000-01-01 example\n  a  0 EUR\n  b')),
    //   <String>['a', 'b'],
    // );
  });
  test('Test sortSuggestions.', () {
    expect(
      sortSuggestions(<String>['a', 'b']),
      <String>['b', 'a'],
    );
    expect(
      sortSuggestions(<String>['a', 'a', 'b']),
      <String>['a', 'b'],
    );
    expect(
      sortSuggestions(<String>['a', 'b', 'b', 'a']),
      <String>['a', 'b'],
    );
  });
  test('Test filterSuggestions.', () {
    expect(filterSuggestions('', <String>['a']), <String>['a']);
    expect(filterSuggestions('a', <String>['a']), <String>['a']);
    expect(filterSuggestions('z', <String>['a']), <String>[]);
    expect(filterSuggestions('a b', <String>['abc']), <String>['abc']);
    expect(filterSuggestions('a z', <String>['abc']), <String>[]);
  });
  group('Test implicit transaction for add entry UI.', () {
    test('Test one.', () {
      expect(
        implicitTransaction(
          defaultCommodity: '¤',
          padZeros: ({String quantity, String commodity}) => padZeros(
            locale: 'en',
            quantity: quantity,
            commodity: commodity,
          ),
          transaction: Transaction().copyWith(date: ''),
          hintTransaction: Transaction().copyWith(date: '1970-01-01'),
        ),
        Transaction().copyWith(date: '1970-01-01'),
      );
      expect(
        implicitTransaction(
          defaultCommodity: '¤',
          padZeros: ({String quantity, String commodity}) => padZeros(
            locale: 'en',
            quantity: quantity,
            commodity: commodity,
          ),
          transaction: Transaction().addPosting(Posting()),
          hintTransaction: Transaction().copyWith(date: '1970-01-01'),
        ),
        Transaction().copyWith(date: '1970-01-01'),
      );

      final Transaction transactionWithNonEmptyPostings =
          Transaction().addAllPostings(
        <Posting>[
          Posting().copyWith(account: 'assets:cash'),
          Posting().copyWith(amount: Amount().copyWith(quantity: '7')),
        ],
      );
      expect(
        implicitTransaction(
          defaultCommodity: '¤',
          padZeros: ({String quantity, String commodity}) => padZeros(
            locale: 'en',
            quantity: quantity,
            commodity: commodity,
          ),
          transaction: transactionWithNonEmptyPostings,
          hintTransaction: Transaction().copyWith(date: '1970-01-01'),
        ),
        transactionWithNonEmptyPostings.copyWith(date: '1970-01-01').rebuild(
              (TransactionBuilder tb) => tb
                ..postings = (tb.postings
                  ..update(
                    (ListBuilder<Posting> plb) => plb
                      ..[1] = plb[1].rebuild(
                        (PostingBuilder pb) => pb
                          ..amount = (pb.amount
                            ..update(
                              (AmountBuilder ab) => ab
                                ..quantity = '7.00'
                                ..commodity = '¤',
                            )),
                      ),
                  )),
            ),
      );
    });
  });
  group('Test transaction hint blending.', () {
    test('Test transaction hint blending.', () {
      expect(
        blendHintTransaction(
          transaction: Transaction(),
          hintTransaction: Transaction(),
        ),
        Transaction(),
      );
    });
  });
}

extension CopyTransaction on Transaction {
  Transaction addPosting(Posting posting) => rebuild(
        (TransactionBuilder b) => b..postings = (b.postings..add(posting)),
      );

  Transaction addAllPostings(List<Posting> postings) => rebuild(
        (TransactionBuilder b) => b
          ..postings = (b.postings
            ..addAll(
              BuiltList<Posting>(postings),
            )),
      );

  Transaction copyWith({
    String date,
    String description,
    BuiltList<Posting> postings,
  }) =>
      rebuild(
        (TransactionBuilder b) => b
          ..date = date ?? b.date
          ..description = description ?? b.description
          ..postings = postings?.toBuilder() ?? b.postings,
      );
}

extension CopyPosting on Posting {
  Posting copyWith({
    int key,
    String account,
    Amount amount,
  }) =>
      rebuild(
        (PostingBuilder b) => b
          ..key = key ?? b.key
          ..account = account ?? b.account
          ..amount = amount?.toBuilder() ?? b.amount,
      );
}

extension CopyAmount on Amount {
  Amount copyWith({
    String quantity,
    String commodity,
    bool commodityOnLeft,
    int spacing,
  }) =>
      rebuild(
        (AmountBuilder b) => b
          ..quantity = quantity ?? b.quantity
          ..commodity = commodity ?? b.commodity
          ..commodityOnLeft = commodityOnLeft ?? b.commodityOnLeft
          ..spacing = spacing ?? b.spacing,
      );
}

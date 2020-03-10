// import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:test/test.dart';

import 'package:cone_lib/src/types.dart';

void main() {
  group('A journal.', () {
//     const String journalContents = '''
// ; a comment

// account a

// 2020-01-01 example
//   b    2.00 EUR
//   c    EUR3.00
//   d

// random_directive blah''';
    // final Journal journal = Journal(contents: journalContents);
    // final BuiltList<JournalItem> journalItems = journal.journalItems;

    // ignore: avoid_as
    // final Transaction transaction = journalItems[3] as Transaction;

    // test('A comment.', () {
    //   expect(journalItems[0] is Comment, true);
    // });
    // test('A directive.', () {
    //   expect(journalItems[1] is Directive, true);
    // });
    // test('A comment.', () {
    //   expect(journalItems[2] is Comment, true);
    // });
    // test('A transaction.', () {
    //   expect(journalItems[3] is Transaction, true);
    // });
    // test('At least one posting.', () {
    //   expect(transaction.postings.isNotEmpty, true);
    // });
    // test('An account.', () {
    //   expect('${transaction.postings[0].account}', 'b');
    // });
    // test('An amount.', () {
    //   expect('${transaction.postings[0].amount}', '2.00 EUR');
    // });
    // test('Another amount.', () {
    //   expect('${transaction.postings[1].amount}', 'EUR3.00');
    // });
    // test('A posting.', () {
    //   expect('${transaction.postings[0]}',
    //       '    b                                           2.00 EUR');
    // });
    // test('A directive.', () {
    //   expect('${journalItems[1]}', 'a');
    // });
    // test('A random directive.', () {
    //   expect('${journalItems[5]}', 'random_directive blah');
    // });
    // test('A comment.', () {
    //   expect('${journalItems[0]}', '; a comment');
    // });
    // test('A transaction.', () {
    //   expect(
    //     '$transaction',
    //     '2020-01-01 example\n'
    //         '    b                                           2.00 EUR\n'
    //         '    c                                        EUR3.00\n'
    //         '    d',
    //   );
    // });
  });
  group('Test of two transactions.', () {
//     const String contents = '''
// 2020-01-01 an example
//     a                                           2.00 EUR
//     b

// 2020-01-02 another example
//     a                                           3.00 EUR
//     b''';

    // test('Roundtrip.', () {
    //   expect('${Journal(contents: contents)}', contents);
    // });
    // test('Get transactions.', () {
    //   expect(
    //       Journal(contents: contents)
    //           .transactions[1]
    //           .postings[0]
    //           .amount
    //           .quantity,
    //       '3.00');
    // });
  });
  test('Copy a transaction', () {
    final Transaction transaction0 = Transaction();
    final Transaction transaction1 = transaction0.rebuild(
      (TransactionBuilder tb) => tb..description = 'pb&j',
    );
    final Transaction transaction2 = transaction1.rebuild(
      (TransactionBuilder tb) => tb..description = '',
    );
    expect(transaction0.date, '');
    expect(transaction0 != transaction1, true);
    expect(transaction1 != transaction2, true);
    expect(transaction0 == transaction2, true);
  });
  test('Investigate nesting.', () {
    final Transaction transaction0 = Transaction(
      (TransactionBuilder tb) => tb..date = '2000',
    );
    final Transaction transaction1 = transaction0.rebuild(
      (TransactionBuilder tb) => tb
        ..date = '2001'
        ..postings.add(Posting((PostingBuilder pb) => pb.account = 'a')),
    );
    final Transaction transaction2 = transaction1.rebuild(
      (TransactionBuilder tb) => tb.postings[0] = tb.postings[0].rebuild(
        (PostingBuilder pb) => pb.account = 'b',
      ),
    );
    final Transaction transaction3 = transaction2.rebuild(
      (TransactionBuilder tb) => tb.postings[0] = tb.postings[0].rebuild(
        (PostingBuilder pb) => pb.amount = AmountBuilder()..quantity = '7',
      ),
    );
    expect(transaction0.date, '2000');
    expect(transaction1.date, '2001');
    expect(transaction1.postings[0].account, 'a');
    expect(transaction2.postings[0].account, 'b');
    expect(transaction3.postings[0].amount.quantity, '7');
  });
  group('Copying a posting.', () {
    final Posting posting0 = Posting(
      (dynamic b) => b
        ..key = 0
        ..account = 'a',
    );
    final Posting posting1 = posting0.rebuild((dynamic b) => b..key = 1);
    final Posting posting2 = posting1.rebuild((dynamic b) => b..account = 'b');
    test('Just a key.', () {
      expect(posting1.key, 1);
    });
    test('Full check.', () {
      expect(posting2.key, 1);
      expect(posting2.account, 'b');
    });
  });
  group('Test generated code.', () {
    test('Test built values.', () {
      expect(() => Comment(), throwsA(isA<BuiltValueNullFieldError>()));
      expect(
        () => Comment((CommentBuilder b) => b..firstLine = -1),
        throwsA(isA<BuiltValueNullFieldError>()),
      );
      expect(
        () => Comment((CommentBuilder b) => b
          ..firstLine = -1
          ..lastLine = -1),
        throwsA(isA<BuiltValueNullFieldError>()),
      );

      final Comment trivialComment = Comment((CommentBuilder b) => b
        ..firstLine = -1
        ..lastLine = -1
        ..comment = '');

      expect(trivialComment..rebuild((CommentBuilder b) => b), isA<Comment>());

      expect(
        trivialComment,
        Comment((CommentBuilder b) => b
          ..firstLine = -1
          ..lastLine = -1
          ..comment = ''),
      );

      expect(trivialComment.hashCode, 182578061);

      expect(
        () => CommentBuilder().build(),
        throwsA(isA<BuiltValueNullFieldError>()),
      );

      expect(trivialComment.toBuilder().firstLine, -1);

      expect(
        () => CommentBuilder().build(),
        throwsA(isA<BuiltValueNullFieldError>()),
      );

      expect(
        () => trivialComment.toBuilder()..replace(null),
        throwsA(isArgumentError),
      );
    });
  });
}

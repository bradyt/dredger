// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:math' show max;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:petitparser/petitparser.dart';

import 'package:cone_lib/parse.dart';

part 'types.g.dart';

@SerializersFor(<Type>[
  AccountDirective,
  Amount,
  Comment,
  Journal,
  OtherDirective,
  Posting,
  Transaction,
])
final Serializers serializers = _$serializers;

String topLevelParser(String contents) {
  final BuiltList<Token<String>> tokens =
      // ignore: avoid_as
      (JournalParser().parse(contents).value as Iterable<Token<String>>)
          .toBuiltList();
  final BuiltList<JournalItem> journalItems =
      tokens.map<JournalItem>(parseJournalItem).toBuiltList();

  final Journal journal =
      Journal((JournalBuilder b) => b..journalItems = journalItems.toBuilder());

  final String jsonJournal = jsonEncode(
    serializers.serializeWith(Journal.serializer, journal),
  );

  return jsonJournal;
}

abstract class Journal implements JournalItem, Built<Journal, JournalBuilder> {
  factory Journal([void Function(JournalBuilder) updates]) = _$Journal;
  Journal._();
  static Serializer<Journal> get serializer => _$journalSerializer;

  BuiltList<JournalItem> get journalItems;
}

abstract class JournalItem {}

abstract class Comment implements JournalItem, Built<Comment, CommentBuilder> {
  factory Comment([void Function(CommentBuilder) updates]) = _$Comment;
  Comment._();
  static Serializer<Comment> get serializer => _$commentSerializer;

  int get firstLine;
  int get lastLine;
  String get comment;

  @override
  String toString() => '$comment';
}

abstract class Directive implements JournalItem {}

abstract class AccountDirective
    implements Directive, Built<AccountDirective, AccountDirectiveBuilder> {
  factory AccountDirective([void Function(AccountDirectiveBuilder) updates]) =
      _$AccountDirective;
  AccountDirective._();
  static Serializer<AccountDirective> get serializer => _$accountDirectiveSerializer;

  int get firstLine;
  int get lastLine;
  String get account;

  @override
  String toString() => '$account';
}

abstract class OtherDirective
    implements Directive, Built<OtherDirective, OtherDirectiveBuilder> {
  factory OtherDirective([void Function(OtherDirectiveBuilder) updates]) =
      _$OtherDirective;
  OtherDirective._();
  static Serializer<OtherDirective> get serializer => _$otherDirectiveSerializer;

  int get firstLine;
  int get lastLine;
  String get other;

  @override
  String toString() => '$other';
}

abstract class Transaction
    implements JournalItem, Built<Transaction, TransactionBuilder> {
  factory Transaction([void Function(TransactionBuilder) updates]) =
      _$Transaction;
  Transaction._();
  static Serializer<Transaction> get serializer => _$transactionSerializer;

  int get firstLine;
  int get lastLine;
  String get date;
  String get description;
  BuiltList<Posting> get postings;

  static void _initializeBuilder(TransactionBuilder b) => b
    ..firstLine = -1
    ..lastLine = -1
    ..date = ''
    ..description = '';

  @override
  String toString() => <String>[
        '$date $description'.trimRight(),
        for (Posting posting in postings) '$posting',
      ].join('\n');
}

abstract class Posting implements Built<Posting, PostingBuilder> {
  factory Posting([void Function(PostingBuilder) updates]) = _$Posting;
  Posting._();
  static Serializer<Posting> get serializer => _$postingSerializer;

  int get key;
  String get account;
  Amount get amount;

  static void _initializeBuilder(PostingBuilder b) => b
    ..key = -1
    ..account = '';

  @override
  String toString() {
    final int padding = max(
        2,
        (amount?.commodityOnLeft ?? true)
            ? 52 - 4 - account.length - 2 - amount.toString().length
            : 52 - 4 - account.length - 2 - amount.quantity.toString().length);
    return '    $account  ${' ' * padding}$amount'.trimRight();
  }
}

abstract class Amount implements Built<Amount, AmountBuilder> {
  factory Amount([void Function(AmountBuilder) updates]) = _$Amount;
  Amount._();
  static Serializer<Amount> get serializer => _$amountSerializer;

  String get commodity;
  String get quantity;
  @nullable
  bool get commodityOnLeft;
  @nullable
  int get spacing;

  static void _initializeBuilder(AmountBuilder b) => b
    ..quantity = ''
    ..commodity = '';

  @override
  String toString() {
    if (commodityOnLeft ?? true) {
      return '${commodity ?? ''}${' ' * (spacing ?? 0)}$quantity';
    } else {
      return '$quantity${' ' * (spacing ?? 0)}${commodity ?? ''}';
    }
  }
}

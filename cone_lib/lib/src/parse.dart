// ignore_for_file: public_member_api_docs

import 'package:built_collection/built_collection.dart';
import 'package:petitparser/petitparser.dart';

import 'package:cone_lib/src/types.dart';

class _JournalGrammarDefinition extends GrammarDefinition {
  @override
  Parser<Iterable<Token<String>>> start() => journalItem()
      .flatten()
      .map((String string) => string.trim())
      .token()
      .star()
      .end();

  Parser<dynamic> journalItem() => block() | inert();

  Parser<Iterable<dynamic>> block() =>
      (pattern('A-Za-z0-9~')) &
      restOfLine() &
      (newline() & restOfBlock()).optional();

  Parser<Iterable<dynamic>> restOfBlock() => indentedLine()
      .separatedBy<dynamic>(newline(), optionalSeparatorAtEnd: true);

  Parser<Iterable<dynamic>> indentedLine() =>
      anyOf(' \t').plus() & restOfLine();

  Parser<Iterable<dynamic>> inert() =>
      (newline() | (pattern('A-Za-z0-9~').not() & any() & restOfLine())).plus();

  Parser<String> newline() => char('\n');

  Parser<Iterable<String>> restOfLine() => newline().neg().star();
}

class _JournalParserDefinition extends _JournalGrammarDefinition {}

class JournalParser extends GrammarParser {
  JournalParser() : super(_JournalParserDefinition());
}

JournalItem parseJournalItem(Token<String> token) {
  if (token.value.startsWith(RegExp(r'[0-9~]'))) {
    return _parseTransaction(token);
  } else if (token.value.startsWith(RegExp(r'[A-Za-z]'))) {
    if (token.value.startsWith('account')) {
      return AccountDirective(
        (AccountDirectiveBuilder b) => b
          ..account = token.value.split('account ')[1].split(';')[0].trim()
          ..firstLine = token.line
          ..lastLine = Token.lineAndColumnOf(token.buffer, token.stop)[0],
      );
    } else {
      return OtherDirective(
        (OtherDirectiveBuilder b) => b
          ..other = token.value
          ..firstLine = token.line
          ..lastLine = Token.lineAndColumnOf(token.buffer, token.stop)[0],
      );
    }
  } else {
    return Comment(
      (CommentBuilder b) => b
        ..comment = token.value
        ..firstLine = token.line
        ..lastLine = Token.lineAndColumnOf(token.buffer, token.stop)[0],
    );
  }
}

Transaction _parseTransaction(Token<String> token) {
  final String chunk = token.value;
  final Iterable<String> lines = chunk.split('\n');
  final String firstLine = lines.elementAt(0);
  final String date = '${firstLine.split(' ')[0]}';
  final int splitAt = firstLine.indexOf(' ');
  final String description =
      (splitAt == -1) ? '' : firstLine.substring(splitAt).trim();
  final ListBuilder<Posting> postingsBuilder = BuiltList<Posting>().toBuilder();
  for (final String line in lines.skip(1)) {
    if (!line.startsWith(RegExp(r'[ \t]*;'))) {
      final String account = '${line.trim().split('  ')[0]}';
      final int splitAt2 = line.trim().indexOf('  ');
      final AmountBuilder amountBuilder = (splitAt2 == -1)
          ? (AmountBuilder()..quantity = '')
          : _parseAmount(line.trim().substring(splitAt2).trim()).toBuilder();
      postingsBuilder.add(
        Posting(
          (PostingBuilder pb) => pb
            ..account = account
            ..amount = amountBuilder,
        ),
      );
    }
  }
  return Transaction(
    (TransactionBuilder tb) => tb
      ..date = date
      ..description = description
      ..postings = postingsBuilder
      ..firstLine = token.line
      ..lastLine = Token.lineAndColumnOf(token.buffer, token.stop)[0],
  );
}

Amount _parseAmount(String amount) {
  String commodity;
  String quantity;
  bool commodityOnLeft;
  int spacing;

  if (amount.startsWith(RegExp(r'[-+0-9.,]+'))) {
    commodityOnLeft = false;
    quantity = RegExp(r'^[-+0-9.,]+').stringMatch(amount);
    commodity = amount.split(RegExp(r'^[-+0-9.,]+'))[1].trim();
    spacing = (amount.startsWith(RegExp(r'[-+0-9.,]+ '))) ? 1 : 0;
  } else if (amount.startsWith(RegExp(r'[A-Za-z]+'))) {
    commodity = RegExp(r'^[A-Za-z]+').stringMatch(amount);
    quantity = amount.split(RegExp(r'^[A-Za-z]+'))[1].trim();
    spacing = (amount.startsWith(RegExp(r'[A-Za-z]+ '))) ? 1 : 0;
    commodityOnLeft = true;
  }

  return Amount(
    (AmountBuilder b) => b
      ..commodity = commodity
      ..commodityOnLeft = commodityOnLeft
      ..quantity = quantity
      ..spacing = spacing,
  );
}

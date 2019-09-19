import 'dart:math' show max;

import 'package:flutter/services.dart' show PlatformException;
import 'package:intl/intl.dart' show NumberFormat;
import 'package:intl/number_symbols.dart' show NumberSymbols;
import 'package:intl/number_symbols_data.dart' show numberFormatSymbols;
import 'package:uri_picker/uri_picker.dart';

import 'package:cone/src/transaction.dart';

Future<void> appendFile(String uri, String contentsToAppend) async {
  await UriPicker.isUriOpenable(uri);
  final String originalContents = await UriPicker.readTextFromUri(uri);
  final String newContents =
      combineContentsWithLinebreak(originalContents, contentsToAppend);
  try {
    await UriPicker.alterDocument(uri, newContents);
  } on PlatformException catch (_) {
    rethrow;
  }
}

class MeasureNewlines {
  MeasureNewlines(String contents) {
    listOfCleanLines =
        contents.split(re).map((String line) => line.trim()).toList();
    lastLine = listOfCleanLines.length - 1;
    lastNonEmptyLine =
        listOfCleanLines.lastIndexWhere((String line) => line.isNotEmpty);
    distance = lastLine - lastNonEmptyLine;
  }

  static final RegExp re = RegExp(r'\r\n?|\n');
  List<String> listOfCleanLines;
  int lastLine;
  int lastNonEmptyLine;
  int distance;

  int numberOfNewlinesToAddBetween() {
    int result;
    if (lastNonEmptyLine == -1) {
      result = 0;
    } else if (distance == 0) {
      result = 2;
    } else if (distance == 1) {
      result = 1;
    } else if (distance > 1) {
      result = 0;
    }
    return result;
  }

  bool needsNewline() {
    return distance == 0;
  }
}

String combineContentsWithLinebreak(String firstPart, String secondPart) {
  return firstPart +
      '\n' * MeasureNewlines(firstPart).numberOfNewlinesToAddBetween() +
      secondPart +
      ((MeasureNewlines(secondPart).needsNewline()) ? '\n' : '');
}

String getAccountNameFromLine(String line) {
  String result;
  if (line.isNotEmpty) {
    if (line.startsWith(RegExp('[ \t]+[^ \t;]'))) {
      result = line.trim().split('  ').first;
    } else if (line.startsWith('account')) {
      result = line.replaceFirst('account', '').trim();
    } else if (line.startsWith(RegExp(r'[-0-9]{10} open [A-Za-z]+:'))) {
      result = line.trim().split(' ').last;
    }
  }
  return result;
}

String getTransactionDescriptionFromLine(String line) {
  final RegExp re = RegExp(r'[-0-9=]{10,21}');
  String result;
  if (line.startsWith(re)) {
    final String dateRemoved = line.replaceFirst(re, '');
    final int commentStart = dateRemoved.indexOf(';');
    final String description = (commentStart == -1)
        ? dateRemoved
        : dateRemoved.substring(0, commentStart);
    result = description.trim();
  }
  return result;
}

String getTransactionDescriptionFromBeancountLine(String line) {
  final RegExp re = RegExp(r'[-0-9]{10}');
  String result;
  if (line.startsWith(re)) {
    final String dateRemoved = line.replaceFirst(re, '').trim();
    if (dateRemoved.startsWith(RegExp(r'[*!]'))) {
      result = dateRemoved.trim();
    }
  }
  return result;
}

Set<String> getSubAccounts(Set<String> accounts) {
  final Set<String> subAccounts = <String>{};
  for (String account in accounts) {
    while (account.lastIndexOf(':') != -1) {
      account = account.substring(0, account.lastIndexOf(':'));
      subAccounts.add(account);
    }
  }
  return subAccounts;
}

Set<String> getAccountsAndSubAccountsFromLines(List<String> lines) {
  final Set<String> accounts = lines.map(getAccountNameFromLine).toSet()
    ..remove(null);
  return accounts.union(getSubAccounts(accounts));
}

List<String> fuzzyMatch(String input, Set<String> candidates) {
  final List<String> fuzzyText = input.split(' ');
  return candidates
      .where((String candidate) => fuzzyText.every((String subtext) =>
          candidate.toLowerCase().contains(subtext.toLowerCase())))
      .toList()
        ..sort();
}

String transactionToString({
  String locale,
  Transaction transaction,
  bool currencyOnLeft = false,
}) {
  // extract postings
  final List<Posting> postings = transaction.postings;

  //
  // first pass
  //
  final List<List<String>> postingsWithSplitAmounts = <List<String>>[];
  int maxWidthOfAccounts = -1;
  int maxWidthOfWholeNumberParts = -1;
  int maxWidthOfDecimalParts = -1;
  for (final Posting posting in postings) {
    maxWidthOfAccounts = max(posting.account.length, maxWidthOfAccounts);
    if (posting.amount.isNotEmpty) {
      final String zeroPaddedAmount = padZeros(
        locale: locale,
        amount: posting.amount,
        currency: posting.currency,
      );
      final List<String> splittedAmount = splitOnDecimalSeparator(
        locale: locale,
        amount: zeroPaddedAmount,
      );
      final String partBeforeDecimal =
          (currencyOnLeft ? posting.currency + ' ' : '') + splittedAmount[0];
      final String decimalAndAfter = splittedAmount[1];
      maxWidthOfWholeNumberParts =
          max(partBeforeDecimal.length, maxWidthOfWholeNumberParts);
      maxWidthOfDecimalParts =
          max(decimalAndAfter.length, maxWidthOfDecimalParts);
      postingsWithSplitAmounts.add(<String>[
        posting.account,
        partBeforeDecimal,
        decimalAndAfter,
        posting.currency,
      ]);
    } else {
      postingsWithSplitAmounts.add(<String>[posting.account, '', '', '']);
    }
  }

  // header
  // String result = '${transaction.date} ${transaction.description}';
  final StringBuffer buffer = StringBuffer()
    ..write('${transaction.date} ${transaction.description}');

  //
  // second pass
  //
  for (final List<String> posting in postingsWithSplitAmounts) {
    buffer.write(('\n  ' +
            posting[0].padRight(maxWidthOfAccounts) +
            '  ' +
            posting[1].padLeft(maxWidthOfWholeNumberParts) +
            posting[2] +
            ((!currencyOnLeft) ? ' ${posting[3]}' : ''))
        .trimRight());
  }

  return buffer.toString();
}

List<String> splitOnDecimalSeparator({
  String locale,
  String amount,
}) {
  final NumberSymbols symbols = numberFormatSymbols[locale] as NumberSymbols;
  final int indexOfDecimalSeparator = amount.indexOf(symbols.DECIMAL_SEP);
  if (indexOfDecimalSeparator > 0) {
    final String wholeNumberPart = amount.substring(0, indexOfDecimalSeparator);
    final String decimalPart = amount.substring(indexOfDecimalSeparator);
    return <String>[wholeNumberPart, decimalPart];
  }
  return <String>[amount, ''];
}

String padZeros({String locale, String amount, String currency}) {
  // final symbols = numberFormatSymbols[locale];
  final NumberFormat numberFormat =
      NumberFormat.currency(locale: locale, decimalDigits: 2, name: '');
  final num parsedNum =
      parseAmountToNum(locale: locale, amount: amount, currency: currency);
  if (parsedNum == null) {
    return amount;
  } else {
    final String paddedAmount = numberFormat.format(parsedNum);
    if (parseAmountToNum(
            locale: locale, amount: paddedAmount, currency: currency) ==
        parsedNum) {
      return paddedAmount;
    } else {
      return amount;
    }
  }
}

num parseAmountToNum({String locale, String amount, String currency}) {
  final NumberSymbols symbols = numberFormatSymbols[locale] as NumberSymbols;
  final NumberFormat numberFormat = NumberFormat.currency(locale: locale);
  if (symbols.DEF_CURRENCY_CODE == currency) {
    try {
      final num parsedAmount = numberFormat.parse(amount);
      return parsedAmount;
    } catch (e) {
      // ignore: avoid_returning_null
      return null;
    }
  } else {
    // ignore: avoid_returning_null
    return null;
  }
}

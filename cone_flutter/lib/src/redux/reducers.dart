import 'package:cone_lib/cone_lib.dart'
    show Posting, PostingBuilder, TransactionBuilder;

import 'package:cone/src/redux/actions.dart';
import 'package:cone/src/redux/state.dart';
import 'package:cone/src/reselect.dart';
import 'package:cone/src/types.dart' show ConeBrightness, Spacing;
import 'package:cone/src/utils.dart'
    show localeCurrency, localeCurrencyOnLeft, localeSpacing;

ConeState firstConeReducer(ConeState state, dynamic action) {
  if (action is InitializeSettingsAction) {
    return state.rebuild(
      (ConeStateBuilder b) => b
        ..brightness = ConeBrightness.values[action.settings.brightness ?? 0]
        ..currencyOnLeft = action.settings.currencyOnLeft ??
            localeCurrencyOnLeft(state.systemLocale)
        ..debugMode = action.settings.debugMode ?? false
        ..defaultCurrency = action.settings.defaultCurrency ??
            localeCurrency(state.systemLocale)
        ..initialized = true
        ..ledgerFileUri = action.settings.ledgerFileUri
        ..ledgerFileDisplayName = action.settings.ledgerFileDisplayName
        ..numberLocale = action.settings.numberLocale ?? state.systemLocale
        ..reverseSort = action.settings.reverseSort ?? true
        ..spacing = Spacing.values[
            action.settings.spacing ?? localeSpacing(state.systemLocale)],
    );
  } else if (action is UpdateSystemLocaleAction) {
    return state.rebuild(
      (ConeStateBuilder b) => b..systemLocale = action.systemLocale,
    );
  } else if (action == Actions.addPosting) {
    return state.rebuild(
      (ConeStateBuilder b) => b
        ..postingKey = state.postingKey + 1
        ..transaction = state.transaction
            .rebuild(
              (TransactionBuilder tb) => tb.postings = tb.postings
                ..add(
                  Posting(
                    (PostingBuilder pb) => pb
                      ..key = state.postingKey
                      ..amount = (pb.amount
                        ..commodityOnLeft = state.currencyOnLeft
                        ..spacing = state.spacing.index),
                  ),
                ),
            )
            .toBuilder(),
    );
  } else if (action is RemovePostingAtAction) {
    return state.rebuild(
      (ConeStateBuilder b) => b
        ..hintTransaction.postings =
            ((action.index < b.hintTransaction.postings.length)
                ? (b.hintTransaction.postings..removeAt(action.index))
                : b.hintTransaction.postings)
        ..transaction = state.transaction
            .rebuild(
              (TransactionBuilder tb) => tb.postings = tb.postings
                ..removeAt(
                  action.index,
                ),
            )
            .toBuilder(),
    );
  } else if (action == Actions.resetTransaction) {
    return state.rebuild(
      (ConeStateBuilder b) => b..transaction = TransactionBuilder(),
    );
  } else if (action is UpdateTransactionIndexAction) {
    return state.rebuild(
      (ConeStateBuilder b) => b
        ..transactionIndex =
            (b.transactionIndex == action.index) ? -1 : action.index,
    );
  } else if (action == Actions.updateHintTransaction) {
    return state.rebuild(
      (ConeStateBuilder csb) => csb
        ..hintTransaction = reselectHintTransaction(state).toBuilder()
        ..hintTransaction.date = reselectDateFormat(state).format(state.today),
    );
  } else if (action is UpdateTodayAction) {
    return state.rebuild(
      (ConeStateBuilder b) => b..today = action.today,
    );
  } else if (action is UpdateDateAction) {
    return state.rebuild(
      (ConeStateBuilder b) => b
        ..transaction = state.transaction
            .rebuild(
              (TransactionBuilder b) => b..date = action.date,
            )
            .toBuilder(),
    );
  } else if (action is UpdateDescriptionAction) {
    return state.rebuild(
      (ConeStateBuilder b) => b
        ..transaction = state.transaction
            .rebuild(
              (TransactionBuilder b) => b..description = action.description,
            )
            .toBuilder(),
    );
  } else if (action is UpdateAccountAction) {
    return state.rebuild(
      (ConeStateBuilder b) => b
        ..transaction = state.transaction
            .rebuild(
              (TransactionBuilder tb) =>
                  tb.postings[action.index] = tb.postings[action.index].rebuild(
                (PostingBuilder pb) => pb.account = action.account,
              ),
            )
            .toBuilder(),
    );
  } else if (action is UpdateQuantityAction) {
    return state.rebuild(
      (ConeStateBuilder b) => b
        ..transaction = state.transaction
            .rebuild(
              (TransactionBuilder tb) =>
                  tb.postings[action.index] = tb.postings[action.index].rebuild(
                (PostingBuilder pb) =>
                    pb.amount = pb.amount..quantity = action.quantity,
              ),
            )
            .toBuilder(),
    );
  } else if (action is UpdateCommodityAction) {
    return state.rebuild(
      (ConeStateBuilder b) => b
        ..transaction = state.transaction
            .rebuild(
              (TransactionBuilder tb) =>
                  tb.postings[action.index] = tb.postings[action.index].rebuild(
                (PostingBuilder pb) =>
                    pb.amount = pb.amount..commodity = action.commodity,
              ),
            )
            .toBuilder(),
    );
  } else if (action is UpdateSettingsAction) {
    ConeState newState;
    switch (action.key) {
      case 'debug_mode':
        newState = state.rebuild(
          (ConeStateBuilder b) => b..debugMode = action.value as bool,
        );
        break;
      case 'default_currency':
        newState = state.rebuild(
          (ConeStateBuilder b) => b..defaultCurrency = action.value as String,
        );
        break;
      case 'ledger_file_uri':
        newState = state.rebuild(
          (ConeStateBuilder b) => b..ledgerFileUri = action.value as String,
        );
        break;
      case 'ledger_file_display_name':
        newState = state.rebuild(
          (ConeStateBuilder b) =>
              b..ledgerFileDisplayName = action.value as String,
        );
        break;
      case 'number_locale':
        newState = state.rebuild(
          (ConeStateBuilder b) => b..numberLocale = action.value as String,
        );
        break;
      case 'currency_on_left':
        newState = state.rebuild(
          (ConeStateBuilder b) => b..currencyOnLeft = action.value as bool,
        );
        break;
      case 'spacing':
        newState = state.rebuild(
          (ConeStateBuilder b) => b..spacing = action.value as Spacing,
        );
        break;
      case 'reverse_sort':
        newState = state.rebuild(
          (ConeStateBuilder b) => b..reverseSort = action.value as bool,
        );
        break;
      default:
        newState = state;
    }
    return newState;
  } else if (action == Actions.refreshFileContents) {
    return state.rebuild(
      (ConeStateBuilder b) => b..isRefreshing = true,
    );
  } else if (action is UpdateContentsAction) {
    return state.rebuild(
      (ConeStateBuilder b) => b..contents = action.contents,
    );
  } else if (action is UpdateJournalAction) {
    return state.rebuild(
      (ConeStateBuilder b) => b
        ..journal = action.journal.toBuilder()
        ..isRefreshing = false
        ..refreshCount = state.refreshCount + 1,
    );
  } else if (action == Actions.cancelRefresh) {
    return state.rebuild(
      (ConeStateBuilder b) => b..isRefreshing = false,
    );
  } else if (action == Actions.markInitialized) {
    return state.rebuild(
      (ConeStateBuilder b) => b..initialized = true,
    );
  } else if (action is SetBrightness) {
    return state.rebuild(
      (ConeStateBuilder b) => b..brightness = action.brightness,
    );
  }

  return state;
}

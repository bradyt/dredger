import 'package:cone_lib/cone_lib.dart' show Journal;

import 'package:cone/src/types.dart';
import 'package:cone/src/services.dart';

enum Actions {
  addPosting,
  cancelRefresh,
  getPersistentSettings,
  markInitialized,
  parse,
  pickLedgerFileUri,
  refreshFileContents,
  resetTransaction,
  snackBar,
  snackBarProcessing,
  submitTransaction,
  today,
  updateHintTransaction,
}

class UpdateTransactionIndexAction {
  UpdateTransactionIndexAction({
    this.index,
  });

  final int index;
}

class InitializeSettingsAction {
  InitializeSettingsAction({
    this.settings,
  });

  final PersistentSettings settings;
}

class UpdateSettingsAction {
  UpdateSettingsAction(this.key, this.value);

  final String key;
  final dynamic value;

  @override
  String toString() {
    if (value is String) {
      return 'UpdateSettingsAction($key, \'$value\')';
    } else {
      return 'UpdateSettingsAction($key, $value)';
    }
  }
}

class UpdateUriAction {
  UpdateUriAction(this.uri);

  final String uri;
}

class UpdateSystemLocaleAction {
  UpdateSystemLocaleAction(this.systemLocale);

  final String systemLocale;
}

class UpdateJournalAction {
  UpdateJournalAction(this.journal);

  final Journal journal;

  // @override
  // String toString() {
  //   return 'UpdateJournalAction(\'${journal.split('\n')[0]}...\')';
  // }
}

class UpdateContentsAction {
  UpdateContentsAction(this.contents);

  final String contents;

  @override
  String toString() {
    return 'UpdateContentsAction(\'${contents.split('\n')[0]}...\')';
  }
}

class UpdateTodayAction {
  UpdateTodayAction(this.today);

  final DateTime today;
}

class UpdateDateAction {
  UpdateDateAction(this.date);

  final String date;
}

class UpdateDescriptionAction {
  UpdateDescriptionAction(this.description);

  final String description;
}

class UpdateAccountAction {
  UpdateAccountAction({this.index, this.account});

  final int index;
  final String account;
}

class UpdateQuantityAction {
  UpdateQuantityAction({this.index, this.quantity});

  final int index;
  final String quantity;
}

class UpdateCommodityAction {
  UpdateCommodityAction({this.index, this.commodity});

  final int index;
  final String commodity;
}

class RemovePostingAtAction {
  RemovePostingAtAction(this.index);

  final int index;
}

class SetBrightness {
  SetBrightness(this.brightness);

  final ConeBrightness brightness;

  @override
  String toString() {
    return 'SetBrightness($brightness)';
  }
}

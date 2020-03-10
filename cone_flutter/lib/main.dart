import 'package:flutter/material.dart' hide Actions;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';

import 'package:cone/src/add_transaction.dart';
import 'package:cone/src/home.dart';
import 'package:cone/src/localizations.dart';
import 'package:cone/src/raw.dart';
import 'package:cone/src/redux/actions.dart';
import 'package:cone/src/redux/state.dart';
import 'package:cone/src/settings.dart';
import 'package:cone/src/types.dart';

class ConeWidgetTest extends InheritedWidget {
  const ConeWidgetTest({Key key, this.widgetTest, Widget child})
      : super(key: key, child: child);

  final bool widgetTest;

  static bool of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ConeWidgetTest>()
        .widgetTest;
  }

  @override
  bool updateShouldNotify(ConeWidgetTest oldWidget) =>
      widgetTest != oldWidget.widgetTest;
}

void main({bool widgetTest = false, bool snapshots = false}) {
  final Store<ConeState> store = Store<ConeState>(
    coneReducer,
    initialState: ConeState(),
    middleware: coneMiddleware,
  );

  WidgetsFlutterBinding.ensureInitialized();
  store
    ..dispatch(UpdateSystemLocaleAction(Intl.systemLocale))
    ..dispatch(Actions.getPersistentSettings);

  runApp(
    ConeWidgetTest(
      widgetTest: widgetTest,
      child: Provider<Store<ConeState>>.value(
        value: store,
        child: StoreProvider<ConeState>(
          store: store,
          child: ConeInitializing(),
        ),
      ),
    ),
  );
}

class ConeInitializing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<ConeState, bool>(
      converter: (Store<ConeState> store) => store.state.initialized,
      builder: (BuildContext context, bool stateInitialized) {
        return stateInitialized ? ConeApp() : Container();
      },
    );
  }
}

class ConeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<ConeState, dynamic>(
      converter: (Store<ConeState> store) => store.state.brightness,
      builder: (BuildContext context, dynamic brightness) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'cone',
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            ConeLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const <Locale>[
            Locale('en', 'US'),
            Locale('de'),
            Locale('es', 'MX'),
            Locale('fil'),
            Locale('fr'),
            Locale('hi'),
            Locale('in'),
            Locale('it'),
            Locale('ja'),
            Locale('pt', 'BR'),
            Locale('ru', 'RU'),
            Locale('th'),
            Locale('zh'),
          ],
          theme: (brightness == ConeBrightness.dark)
              ? ThemeData(
                  brightness: Brightness.dark,
                  accentColor: Colors.greenAccent,
                )
              : ThemeData(
                  primarySwatch: Colors.green,
                  accentColor: Colors.amberAccent,
                ),
          darkTheme: (brightness == ConeBrightness.auto)
              ? ThemeData(
                  brightness: Brightness.dark,
                  accentColor: Colors.greenAccent,
                )
              : null,
          routes: <String, Widget Function(BuildContext)>{
            '/': (BuildContext context) => Home(),
            '/add-transaction': (BuildContext context) => AddTransaction(),
            '/settings': (BuildContext context) => Settings(),
            '/raw': (BuildContext context) => Raw(),
          },
        );
      },
    );
  }
}

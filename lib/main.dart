import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_scope.dart';
import 'data/app_state.dart';
import 'l10n.dart';
import 'shell.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final state = AppState();
  await state.load();
  runApp(RuscaApp(state: state));
}

class RuscaApp extends StatelessWidget {
  const RuscaApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: L10n.appName,
        debugShowCheckedModeBanner: false,
        theme: buildRuscaTheme(),
        home: const AppShell(),
      ),
    );
  }
}

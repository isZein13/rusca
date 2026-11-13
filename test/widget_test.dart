import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rusca/data/app_state.dart';
import 'package:rusca/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home, swipe and practice tabs render', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final ttsCalls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('home_widget'),
      (call) async => null,
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (call) async {
        ttsCalls.add(call.method);
        if (call.method == 'getVoices') return <Map<String, String>>[];
        if (call.method == 'isLanguageAvailable') return true;
        return 1;
      },
    );
    final state = AppState();
    await state.load();

    await tester.pumpWidget(RuscaApp(state: state));
    await tester.pump();

    expect(find.text('Kilit ekranındaki kelime'), findsOneWidget);
    expect(find.text(state.wordOfDay.trPron), findsWidgets);
    expect(find.text('Ana sayfa'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Kartlara geç'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Kartlara geç'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Biliyorum'), findsOneWidget);
    expect(find.text('Öğreneceğim'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Dinle').hitTestable().last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(ttsCalls, contains('speak'));

    await tester.tap(find.text('Pratik'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Pratiğe başla'), findsOneWidget);

    await tester.tap(find.text('Pratiğe başla'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Soru 1/8'), findsOneWidget);
  });
}

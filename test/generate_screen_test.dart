import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rusca/app_scope.dart';
import 'package:rusca/data/ai_words.dart';
import 'package:rusca/data/app_state.dart';
import 'package:rusca/features/speak/generate_screen.dart';
import 'package:rusca/l10n.dart';
import 'package:rusca/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _payload = '''
{"items":[
  {"ru":"Можно меню?","tr":"Menü alabilir miyim?","trPron":"Mojno menyu?","tip":"Kafede söyle."}
]}
''';

class _FakeAi implements AiWordClient {
  @override
  Future<String> complete(String prompt, String apiKey) async => _payload;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('generate screen asks for a key and then shows the phrase',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('home_widget'),
      (call) async => null,
    );
    final state = AppState(ai: _FakeAi());
    await state.load();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildRuscaTheme(),
        home: AppScope(
          state: state,
          child: const GenerateScreen(),
        ),
      ),
    );

    expect(find.text(L10n.generateTitle), findsOneWidget);
    expect(find.text(L10n.generateLead), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.text(L10n.saveKey, skipOffstage: false), findsOneWidget);

    await state.saveAiKey('test-key-123456789012345');
    await tester.pump(const Duration(milliseconds: 20));
    tester
        .widget<FilledButton>(
          find.widgetWithText(FilledButton, L10n.generatePack,
              skipOffstage: false),
        )
        .onPressed!
        .call();
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 20));

    expect(state.generatedWords, hasLength(1));
    expect(find.text('Mojno menyu?', skipOffstage: false), findsOneWidget);
  });
}

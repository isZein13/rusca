import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../data/ai_words.dart';
import '../../data/speak_topics.dart';
import '../../l10n.dart';
import '../../models/word_item.dart';
import '../../theme.dart';

void openGenerate(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const GenerateScreen()),
  );
}

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final _key = TextEditingController();
  String _topic = speakTopics.first.id;
  bool _topicReady = false;
  bool _editingKey = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_topicReady) return;
    _topicReady = true;
    _topic = suggestSpeakTopic(
      AppScope.of(context).generatedWords.map((word) => word.category),
    );
  }

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final showKey = !state.hasAiKey || _editingKey;
    final latest = state.generatedWords.reversed.take(aiPackSize).toList();

    return Scaffold(
      backgroundColor: RuscaColors.paper,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: RuscaColors.ink,
                    ),
                    const Text('YAPAY ZEKA', style: RuscaType.kicker),
                  ],
                ),
                const Text(L10n.generateTitle, style: RuscaType.page),
                const SizedBox(height: 8),
                const Text(
                  L10n.generateLead,
                  style: TextStyle(color: RuscaColors.muted, height: 1.4),
                ),
                const SizedBox(height: 4),
                const Text(
                  L10n.generateNext,
                  style: TextStyle(color: RuscaColors.muted, height: 1.4),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final topic in speakTopics)
                      ChoiceChip(
                        label: Text(topic.label),
                        selected: topic.id == _topic,
                        showCheckmark: false,
                        selectedColor: RuscaColors.ink,
                        backgroundColor: RuscaColors.card,
                        side: const BorderSide(color: RuscaColors.line),
                        labelStyle: TextStyle(
                          color: topic.id == _topic
                              ? Colors.white
                              : RuscaColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: state.generating
                            ? null
                            : (_) => setState(() => _topic = topic.id),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                if (showKey) ...[
                  TextField(
                    controller: _key,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: L10n.keyHint,
                      filled: true,
                      fillColor: RuscaColors.card,
                      hintStyle: const TextStyle(color: RuscaColors.muted),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: RuscaColors.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: RuscaColors.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: RuscaColors.ink),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SelectableText(
                    L10n.keyHelp,
                    style: TextStyle(
                        color: RuscaColors.muted, height: 1.4, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: state.generating ? null : _run,
                  child: state.generating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(showKey ? L10n.saveKey : L10n.generatePack),
                ),
                if (state.hasAiKey)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: state.generating
                          ? null
                          : () => setState(() => _editingKey = !_editingKey),
                      child: Text(_editingKey ? L10n.hideKey : L10n.changeKey),
                    ),
                  ),
                if (state.generateError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.generateError!,
                    style: const TextStyle(color: RuscaColors.no, height: 1.35),
                  ),
                ],
                const SizedBox(height: 22),
                Text(
                  L10n.latestPhrases,
                  style: RuscaType.kicker,
                ),
                const SizedBox(height: 10),
                if (latest.isEmpty)
                  const Text(L10n.noPhrasesYet,
                      style: TextStyle(color: RuscaColors.muted))
                else
                  for (final word in latest) ...[
                    _PhraseTile(
                      word: word,
                      onListen: () => state.tts.speakRussian(word.ru),
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _run() async {
    final state = AppScope.of(context);
    final typed = _key.text.trim();
    FocusManager.instance.primaryFocus?.unfocus();
    if (typed.isNotEmpty) {
      await state.saveAiKey(typed);
    }
    if (!mounted) return;
    try {
      final added = await state.generateSpeakingWords(_topic);
      if (!mounted || added == 0) return;
      setState(() => _editingKey = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: RuscaColors.ink,
          content: Text(
            L10n.addedCount(added),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } on AiWordsException {
      // The message is already on AppState.generateError.
    }
  }
}

class _PhraseTile extends StatelessWidget {
  const _PhraseTile({required this.word, required this.onListen});

  final WordItem word;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    final topic = speakTopicById(word.category);
    final detail = word.tip.isEmpty
        ? '${word.ru}  ·  ${word.tr}'
        : '${word.ru}  ·  ${word.tr}\n${word.tip}';
    return Material(
      color: RuscaColors.card,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: RuscaColors.line),
        ),
        title: Text(
          word.trPron,
          style: const TextStyle(
              color: RuscaColors.ink, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          topic == null ? detail : '${topic.label}\n$detail',
          style: const TextStyle(color: RuscaColors.muted),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.volume_up_rounded),
          onPressed: onListen,
        ),
      ),
    );
  }
}

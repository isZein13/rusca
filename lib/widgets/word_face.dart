import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../l10n.dart';
import '../models/word_item.dart';
import '../theme.dart';

class WordFace extends StatelessWidget {
  const WordFace({
    super.key,
    required this.word,
    required this.state,
    this.compact = false,
  });

  final WordItem word;
  final AppState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          word.trPron,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 36 : 48,
            fontWeight: FontWeight.w800,
            color: RuscaColors.accent,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          word.ru,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 22 : 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          word.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 16 : 20,
            color: RuscaColors.muted,
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => state.tts.speakRussian(word.ru),
          icon: const Icon(Icons.volume_up_rounded),
          label: const Text(L10n.listen),
        ),
      ],
    );
  }
}

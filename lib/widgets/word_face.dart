import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/speak_topics.dart';
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
    final topic = speakTopicById(word.category);
    final long = word.trPron.length > 18 || word.ru.length > 18;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 3,
          decoration: BoxDecoration(
            color: RuscaColors.stamp,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        if (topic != null) ...[
          Text(topic.label.toUpperCase(), style: RuscaType.kicker),
          const SizedBox(height: 8),
        ],
        Text(
          word.trPron,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 32 : (long ? 30 : 44),
            fontWeight: FontWeight.w700,
            color: RuscaColors.ink,
            height: 1.05,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          word.ru,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 20 : (long ? 20 : 24),
            fontWeight: FontWeight.w500,
            color: RuscaColors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          word.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 15 : 17,
            color: RuscaColors.muted,
          ),
        ),
        if (word.tip.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            word.tip,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 14, height: 1.35, color: RuscaColors.stamp),
          ),
        ],
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: () => state.tts.speakRussian(word.ru),
          style: TextButton.styleFrom(
            foregroundColor: RuscaColors.ink,
            backgroundColor: RuscaColors.paper,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: const BorderSide(color: RuscaColors.line),
            ),
          ),
          icon: const Icon(Icons.volume_up_rounded, size: 18),
          label: const Text(L10n.listen),
        ),
      ],
    );
  }
}

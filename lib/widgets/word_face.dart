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
        _ListenButton(onPressed: () => state.tts.speakRussian(word.ru)),
      ],
    );
  }
}

class _ListenButton extends StatelessWidget {
  const _ListenButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (_) {},
      onHorizontalDragUpdate: (_) {},
      onHorizontalDragEnd: (_) {},
      child: Material(
        color: RuscaColors.paper,
        shape: const StadiumBorder(
          side: BorderSide(color: RuscaColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.volume_up_rounded, size: 18, color: RuscaColors.ink),
                SizedBox(width: 8),
                Text(
                  L10n.listen,
                  style: TextStyle(
                    color: RuscaColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

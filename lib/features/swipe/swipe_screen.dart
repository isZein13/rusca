import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../data/app_state.dart';
import '../../l10n.dart';
import '../../models/word_item.dart';
import '../../theme.dart';
import '../../widgets/word_face.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  double _dx = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final deck = state.swipeDeck;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              L10n.cards,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sağa: Biliyorum  ·  Sola: Öğreneceğim',
              style: TextStyle(color: RuscaColors.muted),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: deck.isEmpty
                  ? const Center(
                      child: Text(
                        L10n.emptyDeck,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: RuscaColors.muted, fontSize: 16),
                      ),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        if (deck.length > 1)
                          Transform.scale(
                            scale: 0.94,
                            child: _CardBody(word: deck[1], state: state),
                          ),
                        Transform.translate(
                          offset: Offset(_dx, 0),
                          child: Transform.rotate(
                            angle: _dx * 0.0015,
                            child: GestureDetector(
                              onHorizontalDragUpdate: (d) {
                                setState(() => _dx += d.delta.dx);
                              },
                              onHorizontalDragEnd: (_) =>
                                  _finish(state, deck.first),
                              child: _CardBody(word: deck.first, state: state),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            if (deck.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _commit(state, deck.first, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RuscaColors.no,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(L10n.swipeLeft),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _commit(state, deck.first, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: RuscaColors.ok,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(L10n.swipeRight),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _finish(AppState state, WordItem word) async {
    if (_dx.abs() < 120) {
      setState(() => _dx = 0);
      return;
    }
    await _commit(state, word, _dx > 0);
  }

  Future<void> _commit(AppState state, WordItem word, bool learned) async {
    setState(() => _dx = 0);
    if (learned) {
      await state.markLearned(word);
    } else {
      await state.markToLearn(word);
    }
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.word, required this.state});

  final WordItem word;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: RuscaColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      child: WordFace(word: word, state: state),
    );
  }
}

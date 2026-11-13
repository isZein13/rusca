import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../data/app_state.dart';
import '../../l10n.dart';
import '../../models/word_item.dart';
import '../../theme.dart';
import '../../widgets/word_face.dart';
import '../speak/generate_screen.dart';

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
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('KARTLAR', style: RuscaType.kicker),
            const SizedBox(height: 6),
            const Text(L10n.cards, style: RuscaType.page),
            const SizedBox(height: 6),
            const Text(
              'Sağa biliyorum, sola öğreneceğim',
              style: TextStyle(color: RuscaColors.muted),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => openGenerate(context),
                style: TextButton.styleFrom(
                  foregroundColor: RuscaColors.stamp,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.centerLeft,
                ),
                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                label: const Text(L10n.generateWords),
              ),
            ),
            Expanded(
              child: deck.isEmpty
                  ? const Center(
                      child: Text(
                        L10n.emptyDeck,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: RuscaColors.muted, fontSize: 16),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            if (deck.length > 1)
                              Transform.translate(
                                offset: const Offset(0, 18),
                                child: _CardBody(
                                  word: deck[1],
                                  state: state,
                                  width: constraints.maxWidth,
                                ),
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
                                  child: _CardBody(
                                    word: deck.first,
                                    state: state,
                                    width: constraints.maxWidth,
                                    tint: _dx > 24
                                        ? RuscaColors.ok
                                        : _dx < -24
                                            ? RuscaColors.no
                                            : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
                        side: const BorderSide(color: RuscaColors.no),
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
                        foregroundColor: Colors.white,
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

class _Stamp extends StatelessWidget {
  const _Stamp({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.word,
    required this.state,
    required this.width,
    this.tint,
  });

  final WordItem word;
  final AppState state;
  final double width;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: PaperCard(
      borderColor: tint ?? RuscaColors.line,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          WordFace(word: word, state: state),
          if (tint == RuscaColors.ok)
            const Align(
              alignment: Alignment.topRight,
              child: _Stamp(label: L10n.swipeRight, color: RuscaColors.ok),
            ),
          if (tint == RuscaColors.no)
            const Align(
              alignment: Alignment.topLeft,
              child: _Stamp(label: L10n.swipeLeft, color: RuscaColors.no),
            ),
        ],
      ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imposter/models/game_state.dart';
import 'package:imposter/screens/scoreboard_screen.dart';

class RevealScoringScreen extends StatefulWidget {
  const RevealScoringScreen({super.key});

  @override
  State<RevealScoringScreen> createState() => _RevealScoringScreenState();
}

class _RevealScoringScreenState extends State<RevealScoringScreen>
    with SingleTickerProviderStateMixin {
  bool _revealed = false;
  late AnimationController _revealCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  void _doReveal() {
    setState(() => _revealed = true);
    _revealCtrl.forward();
  }

  void _resolve(BuildContext context, bool groupWon, bool imposterGuessedWord) {
    context.read<GameState>().resolveRound(
      groupCaughtImposter: groupWon,
      imposterGuessedWord: imposterGuessedWord,
    );
    context.read<GameState>().resetRound();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, b) => const ScoreboardScreen(),
        transitionsBuilder: (_, a, b, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: _revealed
              ? _RevealedView(
                  gameState: gameState,
                  fadeIn: _fadeIn,
                  slideIn: _slideIn,
                  onResolve: (groupWon, imposterGuessed) =>
                      _resolve(context, groupWon, imposterGuessed),
                )
              : _VotePrompt(onReveal: _doReveal),
        ),
      ),
    );
  }
}

// ── Pre-reveal: vote prompt ────────────────────────────────────────────────────
class _VotePrompt extends StatelessWidget {
  final VoidCallback onReveal;
  const _VotePrompt({required this.onReveal});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Text('🗳️', style: TextStyle(fontSize: 90)),
          const SizedBox(height: 28),
          Text(
            'Time to Vote!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            'Discuss who you think the Imposter is.\nWhen ready, press reveal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.55),
              height: 1.6,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onReveal,
              style: ElevatedButton.styleFrom(backgroundColor: colorScheme.secondary),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility_rounded, size: 20),
                  SizedBox(width: 10),
                  Text('REVEAL THE IMPOSTER'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Post-reveal: imposter shown, outcome buttons ───────────────────────────────
class _RevealedView extends StatefulWidget {
  final GameState gameState;
  final Animation<double> fadeIn;
  final Animation<Offset> slideIn;
  final void Function(bool groupWon, bool imposterGuessed) onResolve;

  const _RevealedView({
    required this.gameState,
    required this.fadeIn,
    required this.slideIn,
    required this.onResolve,
  });

  @override
  State<_RevealedView> createState() => _RevealedViewState();
}

class _RevealedViewState extends State<_RevealedView> {
  // Outcome state — null means not chosen yet
  bool? _groupWon;
  bool? _imposterGuessed;
  bool _wordRevealed = false;

  bool get _canConfirm => _groupWon != null && (_groupWon! ? _imposterGuessed != null : true);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imposter = widget.gameState.imposter;
    final word = widget.gameState.currentWord ?? '';

    return FadeTransition(
      opacity: widget.fadeIn,
      child: SlideTransition(
        position: widget.slideIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Imposter reveal card ───────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.secondary.withOpacity(0.2),
                      colorScheme.secondary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: colorScheme.secondary.withOpacity(0.4), width: 2),
                ),
                child: Column(
                  children: [
                    const Text('🕵️', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 12),
                    Text(
                      'The Imposter Was',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.55),
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      imposter.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.secondary,
                      ),
                    ),
                    const Divider(height: 28),
                    if (!_wordRevealed)
                      TextButton.icon(
                        onPressed: () => setState(() => _wordRevealed = true),
                        icon: const Icon(Icons.visibility_rounded),
                        label: const Text('REVEAL SECRET WORD'),
                        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
                      )
                    else ...[
                      Text(
                        'The Secret Word Was',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.55),
                          fontSize: 13,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        word,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Outcome: Did group catch them? ─────────────────────────
              _SectionLabel(label: 'Did the group catch the Imposter?'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ToggleCard(
                      label: '✅  Yes, caught!',
                      selected: _groupWon == true,
                      color: colorScheme.primary,
                      onTap: () => setState(() {
                        _groupWon = true;
                        _imposterGuessed = null; // reset sub-question
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToggleCard(
                      label: '🚀  Imposter escaped!',
                      selected: _groupWon == false,
                      color: colorScheme.secondary,
                      onTap: () => setState(() {
                        _groupWon = false;
                        _imposterGuessed = null;
                      }),
                    ),
                  ),
                ],
              ),

              // ── Sub-question: imposter guessed the word? ───────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                child: _groupWon != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _SectionLabel(
                            label: _groupWon!
                                ? 'Did the Imposter correctly guess the secret word?'
                                : 'Did the Imposter know the secret word?',
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _ToggleCard(
                                  label: '🎯  Yes!',
                                  selected: _imposterGuessed == true,
                                  color: colorScheme.primary,
                                  onTap: () => setState(() => _imposterGuessed = true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ToggleCard(
                                  label: '❌  No',
                                  selected: _imposterGuessed == false,
                                  color: colorScheme.onSurface.withOpacity(0.4),
                                  onTap: () => setState(() => _imposterGuessed = false),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 28),

              // ── Confirm ───────────────────────────────────────────────
              AnimatedOpacity(
                opacity: _canConfirm ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 250),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canConfirm
                        ? () => widget.onResolve(_groupWon!, _imposterGuessed ?? false)
                        : null,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: colorScheme.primary,
                      disabledForegroundColor: Colors.white,
                    ),
                    child: const Text('CONFIRM & SEE SCORES'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleCard({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.15) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? color : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: selected ? color : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

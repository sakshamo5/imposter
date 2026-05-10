import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import 'package:imposter/models/game_state.dart';
import 'package:imposter/screens/reveal_scoring_screen.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _timerStarted = false;
  bool _timerPaused = false;
  late int _startingPlayerIndex;

  // For the pulsing ring animation when time is low
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    final gameState = context.read<GameState>();
    if (gameState.useTimer) {
      _secondsRemaining = gameState.timerMinutes * 60;
    }

    // Randomly pick who goes first
    _startingPlayerIndex = Random().nextInt(gameState.players.length);
  }

  void _startTimer() {
    if (_timerStarted) return;
    setState(() => _timerStarted = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timerPaused) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
        if (_secondsRemaining <= 10) {
          _pulseCtrl.repeat(reverse: true);
        }
      } else {
        _timer?.cancel();
        _pulseCtrl.stop();
        _onTimeUp();
      }
    });
  }

  void _togglePause() {
    setState(() => _timerPaused = !_timerPaused);
  }

  void _onTimeUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("⏰ Time's Up!"),
        content: const Text("The discussion phase has ended. Time to vote!"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _goToReveal();
            },
            child: const Text('VOTE NOW'),
          ),
        ],
      ),
    );
  }

  void _goToReveal() {
    _timer?.cancel();
    _pulseCtrl.stop();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, b) => const RevealScoringScreen(),
        transitionsBuilder: (_, a, b, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _timerProgress {
    final gameState = context.read<GameState>();
    final total = gameState.timerMinutes * 60;
    if (total == 0) return 0;
    return _secondsRemaining / total;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLow = _secondsRemaining <= 10 && _timerStarted;
    final timerColor = isLow ? colorScheme.secondary : colorScheme.primary;
    final startingPlayer = gameState.players[_startingPlayerIndex];

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ── Header ──────────────────────────────────────────────────
                _InfoChip(
                  label: gameState.selectedCategory?.emoji ?? '🎮',
                  text: gameState.selectedCategory?.name ?? '',
                  color: colorScheme.primary,
                ),

                const Spacer(),

                // ── Timer or Free-form ───────────────────────────────────────
                if (gameState.useTimer) ...[
                  ScaleTransition(
                    scale: isLow ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: _timerProgress,
                            strokeWidth: 10,
                            backgroundColor: colorScheme.onSurface.withOpacity(0.08),
                            valueColor: AlwaysStoppedAnimation(timerColor),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formattedTime,
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                color: timerColor,
                                letterSpacing: 2,
                              ),
                            ),
                            if (!_timerStarted)
                              Text(
                                'TAP TO START',
                                style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 2,
                                  color: colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_timerStarted)
                        _ActionChipBtn(
                          icon: Icons.play_arrow_rounded,
                          label: 'Start Timer',
                          onPressed: _startTimer,
                          color: colorScheme.primary,
                        )
                      else if (_timerStarted)
                        _ActionChipBtn(
                          icon: _timerPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          label: _timerPaused ? 'Resume' : 'Pause',
                          onPressed: _togglePause,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                    ],
                  ),
                ] else ...[
                  // ── Free-form mode ─────────────────────────────────────────
                  const Text('🗣️', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 24),
                  Text(
                    'Discussion Phase',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Each player gives ONE clue.\nThen discuss and find the Imposter!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      height: 1.6,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // ── Who goes first card ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(startingPlayer.avatarColor).withOpacity(0.2),
                        child: Text(
                          startingPlayer.name[0].toUpperCase(),
                          style: TextStyle(
                            color: Color(startingPlayer.avatarColor),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Goes First',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            startingPlayer.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.casino_outlined, size: 20),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Vote button ──────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToReveal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.how_to_vote_rounded, size: 20),
                        SizedBox(width: 10),
                        Text('END DISCUSSION & VOTE'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String text;
  final Color color;
  const _InfoChip({required this.label, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        '$label  $text',
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}

class _ActionChipBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  const _ActionChipBtn({required this.icon, required this.label, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

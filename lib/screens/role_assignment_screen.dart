import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imposter/models/game_state.dart';
import 'package:imposter/screens/gameplay_screen.dart';

class RoleAssignmentScreen extends StatefulWidget {
  const RoleAssignmentScreen({super.key});

  @override
  State<RoleAssignmentScreen> createState() => _RoleAssignmentScreenState();
}

class _RoleAssignmentScreenState extends State<RoleAssignmentScreen>
    with SingleTickerProviderStateMixin {
  bool _isRevealed = false;
  late AnimationController _revealCtrl;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _revealCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  void _reveal() {
    setState(() => _isRevealed = true);
    _revealCtrl.forward();
  }

  void _hide() {
    _revealCtrl.reverse().then((_) {
      if (mounted) setState(() => _isRevealed = false);
    });
  }

  void _nextPlayer(GameState gameState) {
    _revealCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _isRevealed = false);
      gameState.markCurrentPlayerViewed();

      if (gameState.allPlayersViewed) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, a, b) => const GameplayScreen(),
            transitionsBuilder: (_, a, b, child) =>
                FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final colorScheme = Theme.of(context).colorScheme;

    if (gameState.allPlayersViewed) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentPlayer = gameState.players[gameState.currentPlayerIndexToView];
    final totalPlayers = gameState.players.length;
    final viewedCount = gameState.currentPlayerIndexToView;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Progress indicator ──────────────────────────────────────
              Row(
                children: [
                  Text(
                    'Player ${viewedCount + 1} of $totalPlayers',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${((viewedCount / totalPlayers) * 100).toInt()}%',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: viewedCount / totalPlayers,
                  minHeight: 6,
                  backgroundColor: colorScheme.primary.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
              ),

              const Spacer(),

              // ── Pass instruction ────────────────────────────────────────
              if (!_isRevealed) ...[
                Text(
                  'Pass the device to',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentPlayer.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Color(currentPlayer.avatarColor),
                  ),
                ),
                const SizedBox(height: 48),

                // Tap-and-Hold button
                GestureDetector(
                  onLongPressStart: (_) => _reveal(),
                  onLongPressEnd: (_) => _hide(),
                  onLongPressCancel: () => _hide(),
                  child: _HoldButton(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hold the button to see your role',
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 13),
                ),
              ],

              // ── Revealed role ────────────────────────────────────────────
              if (_isRevealed) ...[
                AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (_, child) {
                    return Opacity(
                      opacity: _flipAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _flipAnimation.value)),
                        child: child,
                      ),
                    );
                  },
                  child: _RoleCard(
                    isImposter: currentPlayer.isImposter,
                    word: gameState.currentWord ?? '',
                    category: gameState.selectedCategory?.name ?? '',
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _nextPlayer(gameState),
                    child: Text(
                      viewedCount + 1 < totalPlayers ? 'HIDE & PASS →' : 'START GAME 🎮',
                    ),
                  ),
                ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoldButton extends StatefulWidget {
  @override
  State<_HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<_HoldButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fingerprint_rounded, color: Colors.white, size: 56),
              SizedBox(height: 10),
              Text(
                'HOLD TO\nREVEAL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final bool isImposter;
  final String word;
  final String category;

  const _RoleCard({
    required this.isImposter,
    required this.word,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isImposter ? colorScheme.secondary : colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Column(
        children: [
          Text(
            isImposter ? '🕵️' : '🔑',
            style: const TextStyle(fontSize: 52),
          ),
          const SizedBox(height: 16),
          Text(
            isImposter ? 'YOU ARE THE' : 'SECRET WORD',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color.withOpacity(0.7),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isImposter ? 'IMPOSTER' : word.toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1,
            ),
          ),
          if (!isImposter) ...[
            const SizedBox(height: 8),
            Text(
              'Category: $category',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13),
            ),
          ],
          if (isImposter) ...[
            const SizedBox(height: 12),
            Text(
              'Blend in. Guess the word from others\' clues.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imposter/models/game_state.dart';
import 'package:imposter/screens/category_selection_screen.dart';

class ScoreboardScreen extends StatelessWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final colorScheme = Theme.of(context).colorScheme;
    final leaderboard = gameState.leaderboard;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 28),

              // ── Header ────────────────────────────────────────────────────
              Text(
                '🏆 Scoreboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Round ${gameState.roundNumber} complete',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
              ),
              const SizedBox(height: 28),

              // ── Top 3 podium ──────────────────────────────────────────────
              if (leaderboard.length >= 3)
                _Podium(players: leaderboard.take(3).toList()),

              const SizedBox(height: 20),

              // ── Full list ─────────────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  itemCount: leaderboard.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final player = leaderboard[index];
                    final isTop = index == 0;
                    final avatarColor = Color(player.avatarColor);

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200 + index * 60),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isTop
                            ? colorScheme.primary.withOpacity(0.1)
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isTop
                              ? colorScheme.primary.withOpacity(0.3)
                              : colorScheme.onSurface.withOpacity(0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Rank
                          SizedBox(
                            width: 32,
                            child: Text(
                              _rankEmoji(index),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Avatar
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: avatarColor.withOpacity(0.2),
                            child: Text(
                              player.name[0].toUpperCase(),
                              style: TextStyle(
                                color: avatarColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Name
                          Expanded(
                            child: Text(
                              player.name,
                              style: TextStyle(
                                fontWeight: isTop ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Score
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: avatarColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${player.score} pt${player.score != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: avatarColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ── Action buttons ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 20),
                      SizedBox(width: 10),
                      Text('PLAY NEXT ROUND'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showResetDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface.withOpacity(0.6),
                    side: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
                  ),
                  child: const Text('END GAME & RESET SCORES'),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  String _rankEmoji(int index) {
    switch (index) {
      case 0: return '🥇';
      case 1: return '🥈';
      case 2: return '🥉';
      default: return '${index + 1}.';
    }
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Game?'),
        content: const Text('This will clear all scores and return everyone to 0. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GameState>().resetFullGame();
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ── Podium widget for top 3 ────────────────────────────────────────────────────
class _Podium extends StatelessWidget {
  final List<Player> players;
  const _Podium({required this.players});

  @override
  Widget build(BuildContext context) {
    // Display order: 2nd, 1st, 3rd
    final display = [players[1], players[0], players[2]];
    final heights = [80.0, 110.0, 60.0];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        final player = display[i];
        final avatarColor = Color(player.avatarColor);
        final rank = i == 1 ? 1 : (i == 0 ? 2 : 3);
        final rankEmoji = ['🥇', '🥈', '🥉'][rank - 1];

        return Expanded(
          child: Column(
            children: [
              Text(rankEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              CircleAvatar(
                radius: i == 1 ? 26 : 20,
                backgroundColor: avatarColor.withOpacity(0.2),
                child: Text(
                  player.name[0].toUpperCase(),
                  style: TextStyle(
                    color: avatarColor,
                    fontWeight: FontWeight.bold,
                    fontSize: i == 1 ? 20 : 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                player.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: i == 1 ? 14 : 12),
              ),
              Text(
                '${player.score} pts',
                style: TextStyle(color: avatarColor, fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Container(
                height: heights[i],
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [avatarColor.withOpacity(0.6), avatarColor.withOpacity(0.3)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

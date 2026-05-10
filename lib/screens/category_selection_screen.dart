import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imposter/models/game_state.dart';
import 'package:imposter/data/word_bank.dart';
import 'package:imposter/screens/role_assignment_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  bool _showSettings = false;

  static const _difficulties = [
    _Diff(value: 'easy',   label: 'Easy',   emoji: '😊'),
    _Diff(value: 'medium', label: 'Medium', emoji: '🤔'),
    _Diff(value: 'hard',   label: 'Hard',   emoji: '😈'),
    _Diff(value: 'all',    label: 'Mixed',  emoji: '🎲'),
  ];

  void _startGame(WordCategory category) {
    final gameState = context.read<GameState>();
    // Make sure words exist for the chosen difficulty
    if (category.getWords(gameState.difficulty).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No words available for that difficulty. Try "Mixed".')),
      );
      return;
    }
    gameState.startGame(category);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoleAssignmentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Category'),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _showSettings ? Icons.close_rounded : Icons.tune_rounded,
                key: ValueKey(_showSettings),
              ),
            ),
            onPressed: () => setState(() => _showSettings = !_showSettings),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Settings Panel ─────────────────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showSettings
                ? _SettingsPanel(difficulties: _difficulties)
                : const SizedBox.shrink(),
          ),

          // ── Category Grid ──────────────────────────────────────────────────
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              itemCount: gameState.allCategories.length,
              itemBuilder: (context, index) {
                final category = gameState.allCategories[index];
                return _CategoryCard(
                  category: category,
                  onTap: () => _startGame(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Diff {
  final String value;
  final String label;
  final String emoji;
  const _Diff({required this.value, required this.label, required this.emoji});
}

class _SettingsPanel extends StatelessWidget {
  final List<_Diff> difficulties;
  const _SettingsPanel({required this.difficulties});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.08))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Game Settings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Difficulty chips
          Text('Difficulty', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: difficulties.map((d) {
              final selected = gameState.difficulty == d.value;
              return ChoiceChip(
                label: Text('${d.emoji}  ${d.label}'),
                selected: selected,
                selectedColor: colorScheme.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => context.read<GameState>().setDifficulty(d.value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Timer toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Discussion Timer', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    Text('Countdown during the discussion phase', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: gameState.useTimer,
                onChanged: (v) => context.read<GameState>().setUseTimer(v),
              ),
            ],
          ),

          if (gameState.useTimer) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Minutes:', style: Theme.of(context).textTheme.bodyLarge),
                const Spacer(),
                _CounterButton(
                  icon: Icons.remove_rounded,
                  onPressed: gameState.timerMinutes > 1
                      ? () => context.read<GameState>().setTimerMinutes(gameState.timerMinutes - 1)
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${gameState.timerMinutes}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                _CounterButton(
                  icon: Icons.add_rounded,
                  onPressed: gameState.timerMinutes < 10
                      ? () => context.read<GameState>().setTimerMinutes(gameState.timerMinutes + 1)
                      : null,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _CounterButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: onPressed != null ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: onPressed != null ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.3), size: 22),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final WordCategory category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = widget.category.color;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [catColor.withOpacity(0.25), catColor.withOpacity(0.10)]
                  : [catColor.withOpacity(0.15), catColor.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: catColor.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.category.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: catColor,
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

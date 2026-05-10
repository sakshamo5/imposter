import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imposter/models/game_state.dart';
import 'package:imposter/screens/category_selection_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  final _listKey = GlobalKey<AnimatedListState>();

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final gameState = context.read<GameState>();
    if (gameState.players.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A player with this name already exists.')),
      );
      return;
    }
    if (gameState.players.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 players allowed.')),
      );
      return;
    }
    gameState.addPlayer(name);
    _listKey.currentState?.insertItem(gameState.players.length - 1);
    _nameController.clear();
    _focusNode.requestFocus();
  }

  void _removePlayer(int index, Player player) {
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildPlayerTile(player, index, animation),
      duration: const Duration(milliseconds: 250),
    );
    context.read<GameState>().removePlayer(player.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final colorScheme = Theme.of(context).colorScheme;
    final canProceed = gameState.players.length >= 4;

    return Scaffold(
      appBar: AppBar(title: const Text('Players')),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Who\'s playing?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gameState.players.length} / 10 players  •  minimum 4',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Add field ─────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          focusNode: _focusNode,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Enter player name…',
                            prefixIcon: Icon(Icons.person_add_outlined),
                          ),
                          onSubmitted: (_) => _addPlayer(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _AddButton(onPressed: _addPlayer),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Player list ────────────────────────────────────────────────
            Expanded(
              child: gameState.players.isEmpty
                  ? _EmptyState()
                  : AnimatedList(
                      key: _listKey,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      initialItemCount: gameState.players.length,
                      itemBuilder: (context, index, animation) {
                        if (index >= gameState.players.length) return const SizedBox.shrink();
                        return _buildPlayerTile(gameState.players[index], index, animation);
                      },
                    ),
            ),

            // ── Bottom bar ─────────────────────────────────────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  children: [
                    if (!canProceed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Add ${4 - gameState.players.length} more player(s) to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canProceed
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
                                )
                            : null,
                        child: const Text('NEXT  →'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTile(Player player, int index, Animation<double> animation) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarColor = Color(player.avatarColor);

    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: avatarColor.withOpacity(0.15),
              child: Text(
                player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            title: Text(
              player.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            trailing: IconButton(
              icon: Icon(Icons.close_rounded, color: colorScheme.onSurface.withOpacity(0.4)),
              onPressed: () => _removePlayer(index, player),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👥', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No players yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Type a name above and press + to add',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

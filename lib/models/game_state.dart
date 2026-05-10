import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:imposter/data/word_bank.dart';

class Player {
  final String id;
  String name;
  int score;
  bool isImposter;
  bool hasViewedRole;

  Player({
    required this.id,
    required this.name,
    this.score = 0,
    this.isImposter = false,
    this.hasViewedRole = false,
  });

  // Avatar color based on name hash for visual variety
  int get colorIndex => name.codeUnits.fold(0, (a, b) => a + b) % _avatarColors.length;

  static const List<int> _avatarColors = [
    0xFF6366F1, 0xFFF43F5E, 0xFF10B981, 0xFFF59E0B,
    0xFF3B82F6, 0xFF8B5CF6, 0xFFEC4899, 0xFF14B8A6,
  ];

  int get avatarColor => _avatarColors[colorIndex];
}

class GameState extends ChangeNotifier {
  // Players list starts empty — users add their own
  List<Player> _players = [];

  List<WordCategory> _customCategories = [];
  bool _useTimer = false;
  int _timerMinutes = 3;
  String _difficulty = 'all'; // 'easy', 'medium', 'hard', 'all'

  WordCategory? _selectedCategory;
  String? _currentWord;
  int _currentPlayerIndexToView = 0;
  bool _gameInProgress = false;
  int _roundNumber = 0;

  // ── Getters ──────────────────────────────────────────────────────────────────
  List<Player> get players => _players;
  List<WordCategory> get customCategories => _customCategories;
  List<WordCategory> get allCategories => [...WordBank.defaultCategories, ..._customCategories];
  bool get useTimer => _useTimer;
  int get timerMinutes => _timerMinutes;
  String get difficulty => _difficulty;
  WordCategory? get selectedCategory => _selectedCategory;
  String? get currentWord => _currentWord;
  int get currentPlayerIndexToView => _currentPlayerIndexToView;
  bool get gameInProgress => _gameInProgress;
  int get roundNumber => _roundNumber;

  // Sorted leaderboard for score display
  List<Player> get leaderboard {
    final sorted = List<Player>.from(_players);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  // ── Player Management ────────────────────────────────────────────────────────
  void addPlayer(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _players.add(Player(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: trimmed,
    ));
    notifyListeners();
  }

  void removePlayer(String id) {
    _players.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void updatePlayerName(String id, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final idx = _players.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _players[idx].name = trimmed;
      notifyListeners();
    }
  }

  // ── Custom Categories ────────────────────────────────────────────────────────
  void addCustomCategory(WordCategory category) {
    _customCategories.add(category);
    notifyListeners();
  }

  void removeCustomCategory(String id) {
    _customCategories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ── Settings ─────────────────────────────────────────────────────────────────
  void setUseTimer(bool use) {
    _useTimer = use;
    notifyListeners();
  }

  void setTimerMinutes(int minutes) {
    _timerMinutes = minutes.clamp(1, 10);
    notifyListeners();
  }

  void setDifficulty(String diff) {
    _difficulty = diff;
    notifyListeners();
  }

  // ── Game Flow ─────────────────────────────────────────────────────────────────
  /// Starts a new round. Picks a random word from the category/difficulty,
  /// picks one random imposter, shuffles the display order.
  void startGame(WordCategory category) {
    if (_players.length < 4) return;

    _selectedCategory = category;
    _roundNumber++;

    // Pick word from chosen difficulty
    final words = category.getWords(_difficulty);
    words.shuffle();
    _currentWord = words.first;

    // Reset per-round flags — keep scores!
    for (final p in _players) {
      p.isImposter = false;
      p.hasViewedRole = false;
    }

    // Randomly assign exactly one imposter using secure RNG
    final imposterIndex = Random.secure().nextInt(_players.length);
    _players[imposterIndex].isImposter = true;

    // Rotate the list by a random amount so a different player starts the passing phase,
    // but the circular seating order remains identical.
    final shift = Random.secure().nextInt(_players.length);
    if (shift > 0) {
      _players = [..._players.sublist(shift), ..._players.sublist(0, shift)];
    }

    _currentPlayerIndexToView = 0;
    _gameInProgress = true;
    notifyListeners();
  }

  void markCurrentPlayerViewed() {
    if (_currentPlayerIndexToView < _players.length) {
      _players[_currentPlayerIndexToView].hasViewedRole = true;
      _currentPlayerIndexToView++;
      notifyListeners();
    }
  }

  bool get allPlayersViewed => _currentPlayerIndexToView >= _players.length;

  Player get imposter => _players.firstWhere((p) => p.isImposter);

  /// Resolves the round, awards points, then resets round state (not scores).
  /// [groupCaughtImposter] — true if majority voted the imposter out
  /// [imposterGuessedWord] — true if the imposter correctly guessed the secret word
  void resolveRound({
    required bool groupCaughtImposter,
    required bool imposterGuessedWord,
  }) {
    if (groupCaughtImposter) {
      // Group gets 1 point each
      for (var player in _players) {
        if (!player.isImposter) player.score += 1;
      }
      // Imposter gets bonus point for guessing the word after being caught
      if (imposterGuessedWord) {
        imposter.score += 1;
      }
    } else {
      // Imposter survived — gets 1 point for surviving + 1 bonus for knowing the word
      imposter.score += 1;
      if (imposterGuessedWord) {
        imposter.score += 1;
      }
    }
    notifyListeners();
  }

  /// Resets ONLY round state. Player scores and names are preserved.
  void resetRound() {
    _gameInProgress = false;
    _selectedCategory = null;
    _currentWord = null;
    _currentPlayerIndexToView = 0;
    for (final p in _players) {
      p.isImposter = false;
      p.hasViewedRole = false;
    }
    notifyListeners();
  }

  /// Full game reset — clears scores too.
  void resetFullGame() {
    _gameInProgress = false;
    _selectedCategory = null;
    _currentWord = null;
    _currentPlayerIndexToView = 0;
    _roundNumber = 0;
    for (final p in _players) {
      p.isImposter = false;
      p.hasViewedRole = false;
      p.score = 0;
    }
    notifyListeners();
  }
}

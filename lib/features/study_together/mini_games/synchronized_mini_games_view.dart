import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/study_room.dart';
import '../../../core/services/study_together_service.dart';
import '../../../core/services/academic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';

/// Flagship Multiplayer Synchronized Mini Games View:
/// Enables any room participant to start a room-wide game:
/// - Quick Quiz
/// - Fast Math
/// - Word Challenge
/// - Memory Match
/// Synchronizes countdown, rounds, questions, answer submission, and scoreboard.
/// Zero Unicode emojis.
class SynchronizedMiniGamesView extends StatefulWidget {
  final StudyRoom room;
  final StudyTogetherService studyService;
  final AcademicService academicService;
  final String currentUserId;
  final bool isHost;

  const SynchronizedMiniGamesView({
    super.key,
    required this.room,
    required this.studyService,
    required this.academicService,
    required this.currentUserId,
    required this.isHost,
  });

  @override
  State<SynchronizedMiniGamesView> createState() => _SynchronizedMiniGamesViewState();
}

class _SynchronizedMiniGamesViewState extends State<SynchronizedMiniGamesView> {
  Timer? _countdownTicker;
  int _localCountdownSeconds = 3;

  @override
  void initState() {
    super.initState();
    _startLocalCountdownIfNeeded();
  }

  @override
  void didUpdateWidget(covariant SynchronizedMiniGamesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _startLocalCountdownIfNeeded();
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    super.dispose();
  }

  void _startLocalCountdownIfNeeded() {
    final game = widget.room.activeMiniGame;
    if (game != null && game.status == MiniGameStatus.countdown) {
      final remaining = game.countdownEndsAt.difference(DateTime.now()).inSeconds;
      setState(() {
        _localCountdownSeconds = remaining.clamp(1, 3);
      });
      _countdownTicker?.cancel();
      _countdownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        final rem = game.countdownEndsAt.difference(DateTime.now()).inSeconds;
        if (rem <= 0) {
          timer.cancel();
          setState(() => _localCountdownSeconds = 0);
        } else {
          setState(() => _localCountdownSeconds = rem);
        }
      });
    } else {
      _countdownTicker?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGame = widget.room.activeMiniGame;

    if (activeGame == null) {
      return _buildGameSelectionScreen(isDark);
    }

    switch (activeGame.status) {
      case MiniGameStatus.countdown:
        return _buildCountdownScreen(activeGame, isDark);
      case MiniGameStatus.inRound:
        return _buildInRoundScreen(activeGame, isDark);
      case MiniGameStatus.roundReview:
        return _buildInRoundScreen(activeGame, isDark, isReview: true);
      case MiniGameStatus.completed:
        return _buildCompletedScoreboard(activeGame, isDark);
    }
  }

  // --- 1. Game Selection Hub (Any Participant Can Start) ---
  Widget _buildGameSelectionScreen(bool isDark) {
    final games = [
      {
        'type': MiniGameType.quickQuiz,
        'title': 'Quick Quiz',
        'subtitle': 'Trivia challenge across CS & study subjects',
        'icon': Icons.quiz_rounded,
        'badge': '3 Rounds',
        'color': AppColors.gamifyPurple,
      },
      {
        'type': MiniGameType.fastMath,
        'title': 'Fast Math',
        'subtitle': 'Mental arithmetic speed drill',
        'icon': Icons.calculate_rounded,
        'badge': 'Speed Drill',
        'color': AppColors.gamifyEmerald,
      },
      {
        'type': MiniGameType.wordChallenge,
        'title': 'Word Challenge',
        'subtitle': 'Unscramble academic vocabulary & concepts',
        'icon': Icons.spellcheck_rounded,
        'badge': 'Vocabulary',
        'color': AppColors.brandOrange,
      },
      {
        'type': MiniGameType.memoryMatch,
        'title': 'Memory Match',
        'subtitle': 'Recall patterns & sequence orders',
        'icon': Icons.psychology_rounded,
        'badge': 'Recall',
        'color': AppColors.streakOrangeDark,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SYNCHRONIZED MINI-GAMES',
                      style: AppTypography.label.copyWith(
                        color: AppColors.brandOrange,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'All room members play together in real-time',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gamifyEmerald.withValues(alpha: 0.12),
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(color: AppColors.gamifyEmerald.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: AppColors.gamifyEmerald),
                    const SizedBox(width: 4),
                    Text(
                      '+20 XP REWARD',
                      style: AppTypography.label.copyWith(
                        fontSize: 10,
                        color: AppColors.gamifyEmerald,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 4 Game Cards Grid
          ...games.map((g) {
            final type = g['type'] as MiniGameType;
            final title = g['title'] as String;
            final subtitle = g['subtitle'] as String;
            final icon = g['icon'] as IconData;
            final badge = g['badge'] as String;
            final color = g['color'] as Color;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.roundedMd,
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: InkWell(
                onTap: () {
                  widget.studyService.startMiniGame(
                    type,
                    userId: widget.currentUserId,
                  );
                },
                borderRadius: AppRadii.roundedMd,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    badge,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: const Text(
                          'START',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                        onPressed: () {
                          widget.studyService.startMiniGame(
                            type,
                            userId: widget.currentUserId,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- 2. Synchronized Countdown Screen ---
  Widget _buildCountdownScreen(RoomMiniGameState game, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.brandOrange.withValues(alpha: 0.15),
                borderRadius: AppRadii.roundedPill,
                border: Border.all(color: AppColors.brandOrange.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(game.gameType.icon, size: 16, color: AppColors.brandOrange),
                  const SizedBox(width: 6),
                  Text(
                    '${game.startedByUserName.toUpperCase()} SELECTED ${game.gameType.title.toUpperCase()}',
                    style: AppTypography.label.copyWith(
                      color: AppColors.brandOrange,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Giant Synchronized Countdown Number
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandOrange.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.brandOrange, width: 4),
              ),
              child: Center(
                child: Text(
                  '$_localCountdownSeconds',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brandOrange,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Starting in $_localCountdownSeconds... Get ready!',
              style: AppTypography.title.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'All ${widget.room.participants.length} room members will start Round 1 together',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Synchronized In-Round Playing & Review Screen ---
  Widget _buildInRoundScreen(RoomMiniGameState game, bool isDark, {bool isReview = false}) {
    final question = game.currentQuestion;
    final myAnswer = game.answers[widget.currentUserId];
    final hasAnswered = myAnswer != null;
    final myScore = game.scores[widget.currentUserId] ?? 0;
    final remainingSeconds = game.roundEndsAt.difference(DateTime.now()).inSeconds.clamp(0, 30);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Round Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(game.gameType.icon, size: 18, color: AppColors.brandOrange),
                  const SizedBox(width: 6),
                  Text(
                    'ROUND ${game.currentRound} / ${game.totalRounds}',
                    style: AppTypography.label.copyWith(
                      color: AppColors.brandOrange,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isReview
                          ? AppColors.gamifyPurple.withValues(alpha: 0.15)
                          : (remainingSeconds <= 3
                              ? AppColors.dangerRed.withValues(alpha: 0.15)
                              : AppColors.brandOrange.withValues(alpha: 0.15)),
                      borderRadius: AppRadii.roundedPill,
                      border: Border.all(
                        color: isReview
                            ? AppColors.gamifyPurple
                            : (remainingSeconds <= 3
                                ? AppColors.dangerRed
                                : AppColors.brandOrange),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isReview ? Icons.visibility_rounded : Icons.timer_outlined,
                          size: 13,
                          color: isReview
                              ? AppColors.gamifyPurple
                              : (remainingSeconds <= 3
                                  ? AppColors.dangerRed
                                  : AppColors.brandOrange),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isReview ? 'REVEAL' : '${remainingSeconds}s',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isReview
                                ? AppColors.gamifyPurple
                                : (remainingSeconds <= 3
                                    ? AppColors.dangerRed
                                    : AppColors.brandOrange),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gamifyEmerald.withValues(alpha: 0.12),
                      borderRadius: AppRadii.roundedPill,
                      border: Border.all(color: AppColors.gamifyEmerald.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.gamifyEmerald),
                        const SizedBox(width: 4),
                        Text(
                          'Score: $myScore pts',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gamifyEmerald,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (!isReview) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (remainingSeconds / 12.0).clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  remainingSeconds <= 3 ? AppColors.dangerRed : AppColors.brandOrange,
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Question Prompt Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: AppRadii.roundedMd,
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              question.prompt,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Options
          ...List.generate(question.options.length, (idx) {
            final isSelected = myAnswer == idx;
            final isCorrect = idx == question.correctIndex;
            Color btnColor = isDark ? const Color(0xFF1E293B) : Colors.white;
            Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

            if (isReview || hasAnswered) {
              if (isCorrect) {
                btnColor = AppColors.gamifyEmerald.withValues(alpha: 0.18);
                borderColor = AppColors.gamifyEmerald;
              } else if (isSelected) {
                btnColor = AppColors.dangerRed.withValues(alpha: 0.18);
                borderColor = AppColors.dangerRed;
              }
            } else if (isSelected) {
              btnColor = AppColors.brandOrange.withValues(alpha: 0.15);
              borderColor = AppColors.brandOrange;
            }

            final optionLabel = String.fromCharCode(65 + idx); // A, B, C, D
            final participantsWhoChose = widget.room.participants
                .where((p) => game.answers[p.userId] == idx)
                .toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: (hasAnswered || isReview)
                    ? null
                    : () {
                        widget.studyService.submitMiniGameAnswer(
                          userId: widget.currentUserId,
                          optionIndex: idx,
                        );
                      },
                borderRadius: AppRadii.roundedMd,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(color: borderColor, width: (isSelected || (isReview && isCorrect)) ? 1.5 : 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.brandOrange
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                optionLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              question.options[idx],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          if ((hasAnswered || isReview) && isCorrect)
                            const Icon(Icons.check_circle_rounded, color: AppColors.gamifyEmerald, size: 18)
                          else if ((hasAnswered || isReview) && isSelected && !isCorrect)
                            const Icon(Icons.cancel_rounded, color: AppColors.dangerRed, size: 18),
                        ],
                      ),
                      if (isReview && participantsWhoChose.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          children: participantsWhoChose.map((p) {
                            final isMe = p.userId == widget.currentUserId;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isCorrect ? AppColors.gamifyEmerald : AppColors.dangerRed).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${p.displayName}${isMe ? " (You)" : ""}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isCorrect ? AppColors.gamifyEmerald : AppColors.dangerRed,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          if (isReview && question.explanation != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gamifyPurple.withValues(alpha: 0.1),
                borderRadius: AppRadii.roundedMd,
                border: Border.all(color: AppColors.gamifyPurple.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.gamifyPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Participant Answer Status Row
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${game.answers.length} / ${widget.room.participants.length} answered',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
              if (hasAnswered || isReview)
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                      label: Text(
                        game.currentRound < game.totalRounds ? 'Next Round' : 'See Results',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        widget.studyService.advanceMiniGameRound();
                      },
                    ),
                  ],
                ),
            ],
          ),

          // Peer test helper
          if (widget.room.participants.any((p) => p.userId == 'user_ahmed_peer') &&
              !game.answers.containsKey('user_ahmed_peer')) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                widget.studyService.simulateAhmedMiniGameAnswer(question.correctIndex);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Simulate Ahmed Answer (+10)',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- 4. Synchronized Final Scoreboard ---
  Widget _buildCompletedScoreboard(RoomMiniGameState game, bool isDark) {
    // Sort participants by scores descending
    final ranked = List<RoomParticipant>.from(widget.room.participants)
      ..sort((a, b) {
        final sa = game.scores[a.userId] ?? 0;
        final sb = game.scores[b.userId] ?? 0;
        return sb.compareTo(sa);
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: AppRadii.roundedLg,
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.brandOrange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 28,
                    color: AppColors.brandOrange,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'CHALLENGE COMPLETE!',
                  style: AppTypography.label.copyWith(
                    color: AppColors.brandOrange,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${game.gameType.title} • All ${game.totalRounds} Rounds Finished',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Leaderboard list
                ...ranked.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final participant = entry.value;
                  final score = game.scores[participant.userId] ?? 0;
                  final isMe = participant.userId == widget.currentUserId;
                  final isWinner = rank == 1;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isWinner
                          ? AppColors.brandOrange.withValues(alpha: 0.08)
                          : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                      borderRadius: AppRadii.roundedMd,
                      border: Border.all(
                        color: isWinner
                            ? AppColors.brandOrange.withValues(alpha: 0.5)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isWinner ? AppColors.brandOrange : AppColors.textSecondaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${participant.displayName} ${isMe ? "(You)" : ""}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                isWinner ? '+20 XP Champion' : '+10 XP Participant',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isWinner ? AppColors.brandOrange : AppColors.gamifyEmerald,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$score pts',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isWinner ? AppColors.brandOrange : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.brandOrange),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.brandOrange),
                  label: const Text(
                    'Play Another Game',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandOrange,
                    ),
                  ),
                  onPressed: () {
                    widget.studyService.exitMiniGame();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

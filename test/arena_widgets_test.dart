import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unifocus/core/models/study_room.dart';
import 'package:unifocus/core/theme/app_theme.dart';
import 'package:unifocus/core/widgets/achievement_badge.dart';
import 'package:unifocus/core/widgets/level_badge.dart';
import 'package:unifocus/core/widgets/participant_node.dart';
import 'package:unifocus/core/widgets/room_music_dock.dart';
import 'package:unifocus/core/widgets/session_control_dock.dart';
import 'package:unifocus/core/widgets/session_goal_widget.dart';
import 'package:unifocus/core/widgets/session_timer.dart';
import 'package:unifocus/core/widgets/status_indicator.dart';
import 'package:unifocus/core/widgets/streak_badge.dart';
import 'package:unifocus/core/widgets/study_arena.dart';
import 'package:unifocus/core/widgets/xp_bar.dart';

void main() {
  Widget wrapWidget(Widget child, {bool isDark = false}) {
    return MaterialApp(
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('Study Arena & Reusable Widgets Tests', () {
    testWidgets('SessionTimer displays formatted duration and course code without emojis', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const SessionTimer(
            elapsed: Duration(hours: 1, minutes: 48, seconds: 32),
            courseCode: 'CENG401',
          ),
        ),
      );

      expect(find.text('01:48:32'), findsOneWidget);
      expect(find.text('CENG401 · SYNCHRONIZED'), findsOneWidget);
      expect(find.text('FOCUS SESSION'), findsOneWidget);
    });

    testWidgets('ParticipantNode renders student avatar, major, status, and subject pill', (tester) async {
      final participant = RoomParticipant(
        userId: 'user_mohamed',
        displayName: 'Mohamed Abdou',
        major: 'Computer Engineering',
        level: 7,
        isHost: true,
        status: ParticipantStatus.studying,
        currentSubject: 'Writing CENG401 proposal',
        joinedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        wrapWidget(
          ParticipantNode(
            participant: participant,
            isSelf: true,
          ),
        ),
      );

      expect(find.text('Mohamed Abdou'), findsOneWidget);
      expect(find.text('YOU'), findsOneWidget);
      expect(find.text('Writing CENG401 proposal'), findsOneWidget);
      expect(find.text('Computer · L7'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget); // host icon
    });

    testWidgets('StudyArena renders participants in spatial layout', (tester) async {
      final participants = [
        RoomParticipant(
          userId: 'user_mohamed',
          displayName: 'Mohamed Abdou',
          major: 'Computer Engineering',
          level: 7,
          isHost: true,
          status: ParticipantStatus.studying,
          currentSubject: 'Writing CENG401 proposal',
          joinedAt: DateTime.now(),
        ),
        RoomParticipant(
          userId: 'user_ahmed',
          displayName: 'Ahmed',
          major: 'Computer Engineering',
          level: 4,
          isHost: false,
          status: ParticipantStatus.onBreak,
          breakMinutesRemaining: 10,
          currentSubject: 'Calculus Exercises',
          joinedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        wrapWidget(
          StudyArena(
            participants: participants,
            currentUserId: 'user_mohamed',
          ),
        ),
      );

      expect(find.text('Mohamed Abdou'), findsOneWidget);
      expect(find.text('Ahmed'), findsOneWidget);
      expect(find.text('ARENA'), findsOneWidget);
    });

    testWidgets('SessionControlDock renders compact tactile buttons: BREAK, SUBJECT, GOAL, MUSIC, MORE', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          SessionControlDock(
            onBreakPressed: () {},
            onSubjectPressed: () {},
            onGoalPressed: () {},
            onMusicPressed: () {},
            onMorePressed: () {},
          ),
        ),
      );

      expect(find.text('BREAK'), findsOneWidget);
      expect(find.text('SUBJECT'), findsOneWidget);
      expect(find.text('GOAL'), findsOneWidget);
      expect(find.text('MUSIC'), findsOneWidget);
      expect(find.text('MORE'), findsOneWidget);
    });

    testWidgets('SessionGoalWidget renders goal text and +25 XP chip', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          SessionGoalWidget(
            goal: 'Complete introduction & system architecture',
            isCompleted: false,
            onToggleCompleted: () {},
            onEditGoal: () {},
          ),
        ),
      );

      expect(find.text('Complete introduction & system architecture'), findsOneWidget);
      expect(find.text('+25 XP'), findsOneWidget);
      expect(find.text('SESSION GOAL'), findsOneWidget);
    });

    testWidgets('RoomMusicDock renders track details, visualizer bars, and host controls', (tester) async {
      const music = RoomMusicState(
        trackId: 'track_lofi_1',
        trackTitle: 'Lo-fi Study Beats',
        artist: 'UniFocus Chill',
        isPlaying: true,
      );

      await tester.pumpWidget(
        wrapWidget(
          RoomMusicDock(
            musicState: music,
            positionSeconds: 174,
            isHost: true,
            isLocalMuted: false,
            onTogglePlay: () {},
            onNextTrack: () {},
            onToggleMute: () {},
          ),
        ),
      );

      expect(find.text('NOW PLAYING'), findsOneWidget);
      expect(find.text('Lo-fi Study Beats'), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget);
    });

    testWidgets('LevelBadge, StreakBadge, StatusIndicator, XPBar render without emojis', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const Column(
            children: [
              LevelBadge(level: 7),
              StreakBadge(streakDays: 12),
              StatusIndicator(status: ParticipantStatus.studying),
              XPBar(level: 7, currentXp: 1840, maxXp: 2000),
              AchievementBadge(title: 'First Study Together Session'),
            ],
          ),
        ),
      );

      expect(find.text('LVL 7'), findsWidgets);
      expect(find.text('12 DAY STREAK'), findsOneWidget);
      expect(find.text('STUDYING'), findsOneWidget);
      expect(find.text('1840 / 2000 XP'), findsOneWidget);
      expect(find.text('First Study Together Session'), findsOneWidget);
    });
  });
}

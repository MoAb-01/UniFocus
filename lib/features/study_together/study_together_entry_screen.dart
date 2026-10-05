import 'package:flutter/material.dart';
import '../../core/models/study_room.dart';
import '../../core/services/study_together_service.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/game_button.dart';
import '../../core/widgets/streak_badge.dart';
import 'study_room_lobby_screen.dart';
import 'active_study_session_screen.dart';

class StudyTogetherEntryScreen extends StatefulWidget {
  final StudyTogetherService studyService;
  final AcademicService academicService;

  const StudyTogetherEntryScreen({
    super.key,
    required this.studyService,
    required this.academicService,
  });

  @override
  State<StudyTogetherEntryScreen> createState() => _StudyTogetherEntryScreenState();
}

class _StudyTogetherEntryScreenState extends State<StudyTogetherEntryScreen> {
  final TextEditingController _codeController = TextEditingController(text: '482-731-205');
  final TextEditingController _titleController = TextEditingController(text: 'CENG401 Focus Session');
  String _selectedCourse = 'CENG401';
  bool _isJoining = false;

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _openActiveRoom() {
    final room = widget.studyService.activeRoom;
    if (room == null) return;

    if (room.status == StudyRoomStatus.active) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveStudySessionScreen(
            studyService: widget.studyService,
            academicService: widget.academicService,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudyRoomLobbyScreen(
            studyService: widget.studyService,
            academicService: widget.academicService,
          ),
        ),
      );
    }
  }

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isJoining = true);
    final success = await widget.studyService.joinRoom(code);
    setState(() => _isJoining = false);

    if (!mounted) return;
    if (success) {
      _openActiveRoom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("That room doesn't exist or has already ended."),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  void _showCreateModal() {
    final activeRoom = widget.studyService.activeRoom;
    final isHost = activeRoom != null && activeRoom.hostId == widget.academicService.profile.id && activeRoom.status != StudyRoomStatus.ended;

    if (isHost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already have an active room. Complete or leave it before creating a new one.'),
          backgroundColor: AppColors.streakOrange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.sheetTop),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Study Arena',
                  style: AppTypography.headline.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'ROOM TITLE',
              style: AppTypography.label.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. CENG401 Project Sprint',
                border: OutlineInputBorder(
                  borderRadius: AppRadii.roundedMd,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'COURSE',
              style: AppTypography.label.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCourse,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: AppRadii.roundedMd,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'CENG401', child: Text('CENG401 — Senior Thesis')),
                DropdownMenuItem(value: 'CENG403', child: Text('CENG403 — Cloud Computing')),
                DropdownMenuItem(value: 'MATH201', child: Text('MATH201 — Linear Algebra')),
                DropdownMenuItem(value: 'General Study', child: Text('General Focus Arena')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedCourse = val);
              },
            ),
            const SizedBox(height: 24),
            GameButton(
              text: 'CREATE ARENA',
              variant: GameButtonVariant.primary,
              onPressed: () async {
                Navigator.pop(ctx);
                await widget.studyService.createRoom(
                  title: _titleController.text.trim(),
                  courseCode: _selectedCourse,
                );
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudyRoomLobbyScreen(
                      studyService: widget.studyService,
                      academicService: widget.academicService,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeRoom = widget.studyService.activeRoom;
    final hasActiveRoom = activeRoom != null && activeRoom.status != StudyRoomStatus.ended;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'STUDY TOGETHER',
          style: AppTypography.label.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StreakBadge(
              streakDays: widget.academicService.profile.studyStreakDays,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF2563EB),
                    Color(0xFF4F46E5),
                  ],
                ),
                borderRadius: AppRadii.roundedXl,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandBlue.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppRadii.roundedPill,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.groups_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              'MULTIPLAYER ARENA',
                              style: AppTypography.label.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gamifyYellow.withValues(alpha: 0.25),
                          borderRadius: AppRadii.roundedSm,
                          border: Border.all(color: AppColors.gamifyYellow, width: 1),
                        ),
                        child: Text(
                          '+50 XP / SESSION',
                          style: AppTypography.label.copyWith(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Study Arena Live',
                    style: AppTypography.display.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Synchronized focus clocks, peer break requests, shared lo-fi audio, and real-time social motivation.',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active Room Quick Launch (if any)
            if (hasActiveRoom) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: AppRadii.roundedLg,
                  border: Border.all(
                    color: AppColors.gamifyEmerald.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gamifyEmerald.withValues(alpha: 0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: activeRoom.status == StudyRoomStatus.active
                                ? AppColors.gamifyEmerald
                                : AppColors.gamifyYellow,
                            borderRadius: AppRadii.roundedPill,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                activeRoom.status == StudyRoomStatus.active
                                    ? 'SESSION ACTIVE'
                                    : 'LOBBY READY',
                                style: AppTypography.label.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'ARENA ${activeRoom.id}',
                          style: AppTypography.label.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1.0,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      activeRoom.title,
                      style: AppTypography.headline.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${activeRoom.participants.length} Participants Studying · Lo-fi Audio Synced',
                      style: AppTypography.caption.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    GameButton(
                      text: activeRoom.status == StudyRoomStatus.active
                          ? 'ENTER LIVE ARENA'
                          : 'ENTER LOBBY',
                      variant: GameButtonVariant.success,
                      onPressed: _openActiveRoom,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Host a Room Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: AppRadii.roundedLg,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.brandBlueLight,
                          borderRadius: AppRadii.roundedMd,
                        ),
                        child: const Icon(Icons.group_add_rounded, color: AppColors.brandBlue, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Host a Study Arena',
                              style: AppTypography.headline.copyWith(
                                fontSize: 17,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              'Generate a room code and invite your peers',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GameButton(
                    text: 'CREATE NEW ARENA',
                    variant: GameButtonVariant.primary,
                    onPressed: _showCreateModal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Join Room with Code Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: AppRadii.roundedLg,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.gamifyPurpleLight,
                          borderRadius: AppRadii.roundedMd,
                        ),
                        child: const Icon(Icons.vpn_key_rounded, color: AppColors.gamifyPurple, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Join with Room Code',
                              style: AppTypography.headline.copyWith(
                                fontSize: 17,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              'Enter a 9-digit code (e.g. 482-731-205)',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    style: AppTypography.headline.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'XXX-XXX-XXX',
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: AppRadii.roundedMd,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GameButton(
                    text: 'JOIN ARENA',
                    variant: GameButtonVariant.purple,
                    isLoading: _isJoining,
                    onPressed: _handleJoin,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Motivational Feature Highlights
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
                borderRadius: AppRadii.roundedLg,
              ),
              child: Column(
                children: [
                  _buildFeatureBullet(
                    isDark: isDark,
                    icon: Icons.timer_outlined,
                    iconColor: AppColors.brandBlue,
                    title: 'Synchronized Session Heartbeat',
                    desc: 'Timestamp-based timer keeps everyone in sync down to the second.',
                  ),
                  const SizedBox(height: 14),
                  _buildFeatureBullet(
                    isDark: isDark,
                    icon: Icons.music_note_rounded,
                    iconColor: AppColors.gamifyPurple,
                    title: 'Multiplayer Ambient Audio',
                    desc: 'Host controls ambient background audio with synchronized progress.',
                  ),
                  const SizedBox(height: 14),
                  _buildFeatureBullet(
                    isDark: isDark,
                    icon: Icons.free_breakfast_rounded,
                    iconColor: AppColors.streakOrange,
                    title: 'Peer Break Requests',
                    desc: 'Request 5/10/15m breaks with real-time host approval & countdown.',
                  ),
                  const SizedBox(height: 14),
                  _buildFeatureBullet(
                    isDark: isDark,
                    icon: Icons.bolt_rounded,
                    iconColor: AppColors.gamifyEmerald,
                    title: 'Study XP & Gamification',
                    desc: 'Earn +25 XP for personal goals and focus XP for completing group sessions.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

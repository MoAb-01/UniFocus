import 'package:flutter/material.dart';
import '../models/study_room.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import 'status_indicator.dart';

/// Flagship Participant Node in the Study Arena.
/// Features circular avatar, animated status ring, current subject pill, and level/major.
/// Zero Unicode emojis: uses vector icons and colored status rings.
class ParticipantNode extends StatefulWidget {
  final RoomParticipant participant;
  final bool isSelf;
  final VoidCallback? onTap;

  const ParticipantNode({
    super.key,
    required this.participant,
    this.isSelf = false,
    this.onTap,
  });

  @override
  State<ParticipantNode> createState() => _ParticipantNodeState();
}

class _ParticipantNodeState extends State<ParticipantNode> with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;
  late final Animation<double> _ringPulse;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _ringPulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.participant;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = p.status.color;
    final isOnBreak = p.status == ParticipantStatus.onBreak;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar + Animated Status Ring Stack
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Animated Pulse Aura
              AnimatedBuilder(
                animation: _ringPulse,
                builder: (context, child) {
                  return Container(
                    width: 76 * (isOnBreak ? _ringPulse.value : 1.0),
                    height: 76 * (isOnBreak ? _ringPulse.value : 1.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ringColor.withValues(alpha: isOnBreak ? 0.35 : 0.2),
                          blurRadius: isOnBreak ? 14 : 8,
                          spreadRadius: isOnBreak ? 2 : 1,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Status Ring Border
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringColor,
                    width: 3.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CircleAvatar(
                    backgroundColor: widget.isSelf
                        ? AppColors.brandBlue
                        : (isDark ? AppColors.surfaceElevatedDark : const Color(0xFFE2E8F0)),
                    child: Text(
                      _getInitials(p.displayName),
                      style: AppTypography.title.copyWith(
                        color: widget.isSelf
                            ? Colors.white
                            : (isDark ? Colors.white : AppColors.textPrimaryLight),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),

              // Host Crown / Star Badge
              if (p.isHost)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.gamifyYellow,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33D97706),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Status Icon Badge at bottom right of Avatar
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ringColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.backgroundDark : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    p.status.icon,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Name + Level/Major
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  p.displayName,
                  style: AppTypography.title.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isSelf) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withValues(alpha: 0.15),
                    borderRadius: AppRadii.roundedXs,
                  ),
                  child: Text(
                    'YOU',
                    style: AppTypography.label.copyWith(
                      fontSize: 8.5,
                      color: AppColors.brandBlue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 2),

          // Major · Lvl
          Text(
            '${p.major.split(' ').first} · L${p.level}',
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          // Current Study Subject Pill
          Container(
            constraints: const BoxConstraints(maxWidth: 130),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceElevatedDark
                  : AppColors.surfaceSubtle,
              borderRadius: AppRadii.roundedPill,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOnBreak ? Icons.free_breakfast_rounded : Icons.menu_book_rounded,
                  size: 11,
                  color: isOnBreak ? AppColors.streakOrange : AppColors.brandBlue,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    isOnBreak
                        ? (p.breakMinutesRemaining != null
                            ? '${p.breakMinutesRemaining}m Break'
                            : 'Break')
                        : p.currentSubject,
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isOnBreak
                          ? AppColors.streakOrangeDark
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/models/study_room.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';

/// Floating interactive group break voting banner broadcast to all room members.
/// Allows each participant to cast an individual vote on the proposed group break.
/// Zero Unicode emojis.
class GroupBreakVotingBanner extends StatelessWidget {
  final GroupBreakProposal proposal;
  final int totalParticipants;
  final String currentUserId;
  final String? currentUserName;
  final Function(bool accept) onVote;

  const GroupBreakVotingBanner({
    super.key,
    required this.proposal,
    required this.totalParticipants,
    required this.currentUserId,
    this.currentUserName,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myVote = proposal.votes[currentUserId];
    final isRequester = proposal.requesterId == currentUserId ||
        (currentUserName != null &&
            currentUserName!.isNotEmpty &&
            proposal.requesterName.trim().toLowerCase() == currentUserName!.trim().toLowerCase());
    final hasAccepted = isRequester || myVote == true;
    final acceptCount = proposal.acceptCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF271C0C) : const Color(0xFFFFFBEB),
        borderRadius: AppRadii.roundedXl,
        border: Border.all(
          color: AppColors.brandOrange.withValues(alpha: 0.6),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandOrange.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brandOrange.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  size: 20,
                  color: AppColors.brandOrange,
                ),
              ),
              const SizedBox(width: 12),

              // Title and Requester
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${proposal.requesterName} requested a group break',
                      style: AppTypography.title.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$acceptCount / $totalParticipants accepted · ${proposal.breakMinutes} min break',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.streakOrangeDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Vote Count Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandOrange.withValues(alpha: 0.15),
                  borderRadius: AppRadii.roundedPill,
                ),
                child: Text(
                  '$acceptCount / $totalParticipants',
                  style: AppTypography.label.copyWith(
                    color: AppColors.brandOrange,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // User Voting Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isRequester) ...[
                Text(
                  'Waiting for other students ($acceptCount/$totalParticipants)...',
                  style: AppTypography.caption.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dangerRed,
                    side: const BorderSide(color: AppColors.dangerRed),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => onVote(false),
                  child: const Text('Cancel Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ] else ...[
                // Decline Button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: myVote == false ? Colors.white : AppColors.dangerRed,
                    backgroundColor: myVote == false ? AppColors.dangerRed : Colors.transparent,
                    side: BorderSide(
                      color: myVote == false ? AppColors.dangerRed : AppColors.dangerRed.withValues(alpha: 0.6),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: myVote == false ? null : () => onVote(false),
                  child: Text(
                    myVote == false ? 'Declined' : 'Decline',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),

                const SizedBox(width: 10),

                // Accept Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasAccepted ? AppColors.gamifyEmerald : AppColors.brandOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  ),
                  icon: Icon(
                    hasAccepted ? Icons.check_circle_rounded : Icons.check_rounded,
                    size: 16,
                  ),
                  label: Text(
                    hasAccepted ? 'Accepted' : 'Accept',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  onPressed: hasAccepted ? null : () => onVote(true),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

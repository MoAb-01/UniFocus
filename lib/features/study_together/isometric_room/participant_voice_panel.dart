import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/study_room.dart';
import '../../../core/services/study_together_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';

/// Flagship Multiplayer Voice Panel for Study Lounge:
/// Displays real connected participants with live microphone states,
/// animated equalizer sound-waves on active speakers, and interactive voice controls.
/// Zero Unicode emojis.
class ParticipantVoicePanel extends StatefulWidget {
  final StudyRoom room;
  final StudyTogetherService studyService;
  final String currentUserId;

  const ParticipantVoicePanel({
    super.key,
    required this.room,
    required this.studyService,
    required this.currentUserId,
  });

  @override
  State<ParticipantVoicePanel> createState() => _ParticipantVoicePanelState();
}

class _ParticipantVoicePanelState extends State<ParticipantVoicePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final participants = widget.room.participants;
    final speakingCount = participants.where((p) => p.isSpeaking && !p.isMicMuted).length;

    if (speakingCount > 0 && !_waveController.isAnimating) {
      _waveController.repeat(reverse: true);
    } else if (speakingCount == 0 && _waveController.isAnimating) {
      _waveController.stop();
    }

    // Get current user's participant record
    final currentUserPart = participants.firstWhere(
      (p) => p.userId == widget.currentUserId,
      orElse: () => participants.first,
    );
    final isMeMuted = currentUserPart.isMicMuted;
    final isMeSpeaking = currentUserPart.isSpeaking && !isMeMuted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Voice Panel Header & User Controls
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.gamifyPurple.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.record_voice_over_rounded,
                  size: 16,
                  color: AppColors.gamifyPurple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temporary Voice Lounge',
                      style: AppTypography.label.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      widget.studyService.liveKitVoice.isPermissionDenied
                          ? 'MIC PERMISSION DENIED · ENABLE IN SETTINGS'
                          : (widget.studyService.liveKitVoice.isPublicationFailed
                              ? 'MIC PUBLICATION FAILED'
                              : (widget.studyService.liveKitVoice.isRemoteAudioPlaybackFailed
                                  ? 'AUDIO BLOCKED · TAP TO PLAY'
                                  : (widget.studyService.liveKitVoice.isConnecting
                                      ? 'VOICE CONNECTING...'
                                      : (!widget.studyService.liveKitVoice.isConnected && widget.room.isGroupBreakActive
                                          ? 'VOICE RECONNECTING...'
                                          : '${participants.length} connected · $speakingCount speaking')))),
                      style: AppTypography.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: widget.studyService.liveKitVoice.hasVoiceError
                            ? AppColors.dangerRed
                            : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
              ),

              // Autoplay / Remote Audio Retry Action (for Web/Chrome autoplay restrictions)
              if (widget.studyService.liveKitVoice.isRemoteAudioPlaybackFailed) ...[
                InkWell(
                  onTap: () {
                    widget.studyService.liveKitVoice.retryAudioPlayback();
                  },
                  borderRadius: AppRadii.roundedPill,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.brandOrange.withValues(alpha: 0.15),
                      borderRadius: AppRadii.roundedPill,
                      border: Border.all(color: AppColors.brandOrange),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up_rounded, size: 14, color: AppColors.brandOrange),
                        SizedBox(width: 4),
                        Text(
                          'Enable Sound',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],

              // Current User Mute / Unmute Button
              InkWell(
                onTap: () {
                  widget.studyService.toggleLocalMic(userId: widget.currentUserId);
                },
                borderRadius: AppRadii.roundedPill,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isMeMuted
                        ? AppColors.dangerRed.withValues(alpha: 0.12)
                        : AppColors.gamifyEmerald.withValues(alpha: 0.15),
                    borderRadius: AppRadii.roundedPill,
                    border: Border.all(
                      color: isMeMuted ? AppColors.dangerRed : AppColors.gamifyEmerald,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isMeMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        size: 14,
                        color: isMeMuted ? AppColors.dangerRed : AppColors.gamifyEmerald,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isMeMuted ? 'Muted' : 'Live',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isMeMuted ? AppColors.dangerRed : AppColors.gamifyEmerald,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (!isMeMuted && isMeSpeaking) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gamifyEmerald.withValues(alpha: 0.15),
                    borderRadius: AppRadii.roundedPill,
                    border: Border.all(color: AppColors.gamifyEmerald),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VoiceEqualizerBars(controller: _waveController),
                      const SizedBox(width: 4),
                      const Text(
                        'Speaking',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gamifyEmerald,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: 10),

          // 2. Real Connected Participants List
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: participants.map((participant) {
              final isMe = participant.userId == widget.currentUserId;
              final isMuted = participant.isMicMuted;
              final isSpeaking = participant.isSpeaking && !isMuted;

              return _buildParticipantVoiceCard(
                participant: participant,
                isMe: isMe,
                isMuted: isMuted,
                isSpeaking: isSpeaking,
                isDark: isDark,
              );
            }).toList(),
          ),

          // 3. Peer Simulation Quick Action Bar (For multi-user acceptance testing)
          if (participants.any((p) => p.userId == 'user_ahmed_peer')) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
              children: [
                Text(
                  'PEER SIMULATION:',
                  style: AppTypography.label.copyWith(
                    fontSize: 9,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    final ahmed = participants.firstWhere((p) => p.userId == 'user_ahmed_peer');
                    widget.studyService.simulateAhmedMic(ahmed.isMicMuted);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Toggle Ahmed Mic',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    final ahmed = participants.firstWhere((p) => p.userId == 'user_ahmed_peer');
                    widget.studyService.simulateAhmedSpeaking(!ahmed.isSpeaking);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.brandOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.brandOrange.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'Toggle Ahmed Speaking',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandOrange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    final isAhmedReady = widget.room.readyToResumeUserIds.contains('user_ahmed_peer');
                    widget.studyService.simulateAhmedResume(!isAhmedReady);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gamifyEmerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.gamifyEmerald.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      widget.room.readyToResumeUserIds.contains('user_ahmed_peer')
                          ? 'Ahmed: Ready'
                          : 'Simulate Ahmed Resume',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gamifyEmerald,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipantVoiceCard({
    required RoomParticipant participant,
    required bool isMe,
    required bool isMuted,
    required bool isSpeaking,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSpeaking
            ? AppColors.gamifyEmerald.withValues(alpha: 0.08)
            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
        borderRadius: AppRadii.roundedMd,
        border: Border.all(
          color: isSpeaking
              ? AppColors.gamifyEmerald
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isSpeaking ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with speaking animated glow ring
          Stack(
            alignment: Alignment.center,
            children: [
              if (isSpeaking)
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    final pulse = 24.0 + (_waveController.value * 6.0);
                    return Container(
                      width: pulse,
                      height: pulse,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gamifyEmerald.withValues(
                          alpha: 0.25 - (_waveController.value * 0.15),
                        ),
                      ),
                    );
                  },
                ),
              CircleAvatar(
                radius: 12,
                backgroundColor: isSpeaking
                    ? AppColors.gamifyEmerald
                    : (isMe ? AppColors.brandOrange : AppColors.gamifyPurple),
                child: Text(
                  participant.displayName.isNotEmpty
                      ? participant.displayName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Name and Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    participant.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '(You)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandOrange,
                      ),
                    ),
                  ],
                  if (widget.room.readyToResumeUserIds.contains(participant.userId)) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.gamifyEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.gamifyEmerald, width: 0.6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 9, color: AppColors.gamifyEmerald),
                          SizedBox(width: 2),
                          Text(
                            'Ready',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gamifyEmerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green online connection dot
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.gamifyEmerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSpeaking ? 'Speaking' : (isMuted ? 'Muted' : 'Online'),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isSpeaking
                          ? AppColors.gamifyEmerald
                          : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 10),

          // Live Equalizer Sound-Wave Animation or Muted Icon
          if (isSpeaking) ...[
            VoiceEqualizerBars(controller: _waveController),
            const SizedBox(width: 4),
            const Icon(
              Icons.mic_rounded,
              size: 15,
              color: AppColors.gamifyEmerald,
            ),
          ] else if (isMuted) ...[
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_off_rounded,
                size: 13,
                color: AppColors.dangerRed,
              ),
            ),
          ] else ...[
            const Icon(
              Icons.mic_none_rounded,
              size: 15,
              color: AppColors.gamifyEmerald,
            ),
          ],
        ],
      ),
    );
  }
}

/// Subtle animated equalizer bars responding to live audio speech.
class VoiceEqualizerBars extends StatelessWidget {
  final AnimationController controller;

  const VoiceEqualizerBars({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final val = controller.value;
        final h1 = 4.0 + (math.sin(val * math.pi) * 8.0);
        final h2 = 4.0 + (math.sin((val + 0.3) * math.pi) * 11.0);
        final h3 = 4.0 + (math.sin((val + 0.6) * math.pi) * 7.0);

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(h1),
            const SizedBox(width: 2),
            _buildBar(h2),
            const SizedBox(width: 2),
            _buildBar(h3),
          ],
        );
      },
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 2.5,
      height: height.clamp(3.0, 15.0),
      decoration: BoxDecoration(
        color: AppColors.gamifyEmerald,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}

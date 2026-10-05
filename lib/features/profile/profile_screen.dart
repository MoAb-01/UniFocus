import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/program.dart';
import '../../core/services/academic_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/streak_badge.dart';
import '../../core/widgets/xp_bar.dart';
import '../onboarding/academic_onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AcademicService academicService;
  final StorageService storage;

  const ProfileScreen({
    super.key,
    required this.academicService,
    required this.storage,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = widget.academicService.profile;
    final programs = widget.academicService.programs;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('STUDENT PROFILE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.6)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: StreakBadge(streakDays: profile.studyStreakDays),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            children: [
              // User Identity Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: AppColors.brandBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x332563EB), blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          profile.name.isNotEmpty
                              ? profile.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
                              : 'MA',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        '${profile.university} • ${profile.academicYear}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Gamification XP Progression Box
              XpBar(
                level: profile.level,
                currentXp: profile.xp,
                maxXp: profile.maxXp,
              ),
              const SizedBox(height: 18),

              // Gamified Achievements Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'STUDY ACHIEVEMENTS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '${profile.achievements.length} Unlocked',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gamifyEmeraldDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.achievements.map((ach) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            ach,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Academic Programs
              const SectionHeader(
                title: 'Enrolled Degree Programs',
                subtitle: 'Main & Double Major (ÇAP)',
              ),
              ...programs.map((prog) {
                final isCap = prog.type == ProgramType.cap;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCap ? AppColors.gamifyPurple.withValues(alpha: 0.3) : AppColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isCap ? AppColors.gamifyPurple : AppColors.brandBlue).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isCap ? Icons.alt_route_rounded : Icons.school_rounded,
                          size: 22,
                          color: isCap ? AppColors.gamifyPurple : AppColors.brandBlue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prog.typeLabel.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: isCap ? AppColors.gamifyPurple : AppColors.brandBlue,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              prog.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${prog.completedAkts} Completed AKTS',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('GANO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                          Text(
                            prog.gano.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isCap ? AppColors.gamifyPurple : AppColors.brandBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Settings & Controls
              const SectionHeader(title: 'Preferences & Actions'),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit_outlined, size: 20, color: AppColors.brandBlue),
                      title: const Text('Reconfigure Academic Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Change university, department, or ÇAP/Yandal', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AcademicOnboardingScreen(
                              academicService: widget.academicService,
                              storage: widget.storage,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.streakOrange),
                      title: const Text('Restore Realistic Demo Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Reset courses, assignments, and grades for Mohamed Abdou', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () async {
                        await widget.storage.initializeWithSeedData();
                        widget.academicService.loadData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Demo data restored successfully!')),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline, size: 20, color: Color(0xFF64748B)),
                      title: const Text('About UniFocus', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      subtitle: Text('${AppConstants.developerCredit} • v${AppConstants.appVersion}', style: const TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: AppConstants.appName,
                          applicationVersion: AppConstants.appVersion,
                          applicationLegalese: 'Developed by Mohamed Abdou for university students in Türkiye.',
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

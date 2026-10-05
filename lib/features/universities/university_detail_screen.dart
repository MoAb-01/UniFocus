import 'package:flutter/material.dart';
import '../../core/models/university.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';

class UniversityDetailScreen extends StatelessWidget {
  final University university;

  const UniversityDetailScreen({
    super.key,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(university.shortName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            university.type,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Established ${university.establishedYear}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      university.name,
                      style: AppTypography.displaySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      university.turkishName,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondaryLight),
                        const SizedBox(width: 6),
                        Text(
                          '${university.campus}, ${university.city}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      university.description,
                      style: AppTypography.bodyMedium.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Faculties Section
              SectionHeader(
                title: 'Faculties & Academic Units',
                countBadge: university.faculties.length,
              ),

              ...university.faculties.map((fac) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.apartment_rounded, size: 18, color: AppColors.primaryNavy),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            fac,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 20),

              // Sample Departments
              SectionHeader(
                title: 'Sample Departments',
                countBadge: university.departments.length,
              ),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: university.departments.map((dept) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevatedLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      dept,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

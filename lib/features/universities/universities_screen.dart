import 'package:flutter/material.dart';
import '../../core/constants/turkish_universities_data.dart';
import '../../core/models/university.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'university_detail_screen.dart';

class UniversitiesScreen extends StatefulWidget {
  const UniversitiesScreen({super.key});

  @override
  State<UniversitiesScreen> createState() => _UniversitiesScreenState();
}

class _UniversitiesScreenState extends State<UniversitiesScreen> {
  String _selectedCity = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<University> _getFiltered() {
    final all = TurkishUniversitiesData.seedUniversities;
    return all.where((uni) {
      final matchesCity = _selectedCity == 'All' || uni.city == _selectedCity;
      final matchesQuery = _searchQuery.isEmpty ||
          uni.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          uni.turkishName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          uni.shortName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          uni.city.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCity && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFiltered();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Universities in Türkiye'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search university, city, or code (e.g. İKÇÜ, ODTÜ)...',
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMutedLight),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // City Filter Chips
            Container(
              color: AppColors.surfaceLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCityChip('All'),
                    const SizedBox(width: 8),
                    _buildCityChip('İzmir'),
                    const SizedBox(width: 8),
                    _buildCityChip('Istanbul'),
                    const SizedBox(width: 8),
                    _buildCityChip('Ankara'),
                  ],
                ),
              ),
            ),

            // University List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final uni = filtered[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UniversityDetailScreen(university: uni),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              uni.shortName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  uni.name,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  uni.turkishName,
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondaryLight),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${uni.city} • ${uni.type}',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text('•', style: TextStyle(color: AppColors.textMutedLight)),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Est. ${uni.establishedYear}',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 20, color: AppColors.textMutedLight),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityChip(String city) {
    final isSelected = _selectedCity == city;
    return ChoiceChip(
      label: Text(city),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedCity = city),
      selectedColor: AppColors.primaryNavy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }
}

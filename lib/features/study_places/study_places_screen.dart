import 'package:flutter/material.dart';
import '../../core/constants/study_places_data.dart';
import '../../core/models/study_place.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class StudyPlacesScreen extends StatefulWidget {
  const StudyPlacesScreen({super.key});

  @override
  State<StudyPlacesScreen> createState() => _StudyPlacesScreenState();
}

class _StudyPlacesScreenState extends State<StudyPlacesScreen> {
  String _selectedCity = 'All';
  final String _selectedType = 'All';

  List<StudyPlace> _getFiltered() {
    final all = StudyPlacesData.seedPlaces;
    return all.where((place) {
      final matchesCity = _selectedCity == 'All' || place.city == _selectedCity;
      final matchesType = _selectedType == 'All' || place.type == _selectedType;
      return matchesCity && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFiltered();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Study Places & Libraries'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Bar
            Container(
              color: AppColors.surfaceLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Cities', _selectedCity == 'All', () => setState(() => _selectedCity = 'All')),
                    const SizedBox(width: 8),
                    _buildFilterChip('İzmir', _selectedCity == 'İzmir', () => setState(() => _selectedCity = 'İzmir')),
                    const SizedBox(width: 8),
                    _buildFilterChip('Istanbul', _selectedCity == 'Istanbul', () => setState(() => _selectedCity = 'Istanbul')),
                    const SizedBox(width: 8),
                    _buildFilterChip('Ankara', _selectedCity == 'Ankara', () => setState(() => _selectedCity = 'Ankara')),
                  ],
                ),
              ),
            ),

            // Study Places List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final place = filtered[index];
                  return _buildPlaceCard(place);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceCard(StudyPlace place) {
    Color crowdColor;
    String crowdLabel;
    switch (place.crowdLevel.toLowerCase()) {
      case 'quiet':
        crowdColor = AppColors.successEmerald;
        crowdLabel = 'Quiet';
        break;
      case 'moderate':
        crowdColor = AppColors.academicAmber;
        crowdLabel = 'Moderate';
        break;
      default:
        crowdColor = AppColors.errorRose;
        crowdLabel = 'Crowded';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  place.type.toUpperCase(),
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: crowdColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: crowdColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      crowdLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: crowdColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            place.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${place.campusOrDistrict}, ${place.city}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: AppColors.academicAmber),
                  const SizedBox(width: 3),
                  Text(
                    place.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time_outlined, size: 13, color: AppColors.textMutedLight),
              const SizedBox(width: 4),
              Text(
                place.openingHours,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          // Amenities Tags
          Row(
            children: [
              if (place.hasWifi) _buildAmenityTag('Fast Wi-Fi', Icons.wifi),
              if (place.hasOutlets) ...[
                const SizedBox(width: 8),
                _buildAmenityTag('Power Outlets', Icons.power),
              ],
              if (place.isSilentZone) ...[
                const SizedBox(width: 8),
                _buildAmenityTag('Silent Zone', Icons.volume_off_outlined),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondaryLight),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primaryNavy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }
}

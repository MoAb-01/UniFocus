import 'package:flutter/material.dart';
import '../../core/models/calendar_event.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/calendar_event_tile.dart';
import '../../core/widgets/empty_state.dart';
import 'add_calendar_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  final AcademicService academicService;

  const CalendarScreen({
    super.key,
    required this.academicService,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    widget.academicService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.academicService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  List<CalendarEvent> _getFilteredEvents() {
    final all = widget.academicService.events;
    if (_selectedFilter == 'All') return all;
    if (_selectedFilter == 'Exams') {
      return all.where((e) => e.type == 'Exam' || e.type == 'Quiz').toList();
    }
    if (_selectedFilter == 'Deadlines') {
      return all.where((e) => e.type == 'Assignment' || e.type == 'Project' || e.type == 'Presentation').toList();
    }
    if (_selectedFilter == 'Classes') {
      return all.where((e) => e.type == 'Class').toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredEvents();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Academic Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Event',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddCalendarEventScreen(
                    academicService: widget.academicService,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips
            Container(
              color: AppColors.surfaceLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Deadlines'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Exams'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Classes'),
                  ],
                ),
              ),
            ),

            // Events List
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.event_available_outlined,
                      title: 'Nothing scheduled',
                      message: 'Enjoy your free time or add exams and assignment deadlines.',
                      buttonText: '+ Add Event',
                      onButtonPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddCalendarEventScreen(
                              academicService: widget.academicService,
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 108),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final event = filtered[index];
                        return CalendarEventTile(
                          event: event,
                          onTap: () => _showEventDetailsModal(context, event),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = label),
      selectedColor: AppColors.primaryNavy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  void _showEventDetailsModal(BuildContext context, CalendarEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    event.type.toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.errorRose, size: 20),
                  onPressed: () {
                    widget.academicService.deleteEvent(event.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(event.title, style: AppTypography.displaySmall),
            const SizedBox(height: 8),
            if (event.courseCode != null)
              Text('Course: ${event.courseCode}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
            const SizedBox(height: 6),
            Text(
              'Date & Time: ${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year} at ${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
            ),
            if (event.notes != null && event.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(event.notes!, style: AppTypography.bodyMedium),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

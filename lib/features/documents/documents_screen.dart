import 'package:flutter/material.dart';
import '../../core/models/scanned_document.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/empty_state.dart';
import 'document_scanner_sheet.dart';

class DocumentsScreen extends StatefulWidget {
  final AcademicService academicService;

  const DocumentsScreen({
    super.key,
    required this.academicService,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    widget.academicService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.academicService.removeListener(_onServiceUpdate);
    _searchController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  List<ScannedDocument> _getFilteredDocuments() {
    final all = widget.academicService.documents;
    return all.where((doc) {
      final matchesCat = _selectedCategory == 'All' || doc.category == _selectedCategory;
      final matchesText = doc.matchesSearch(_searchQuery);
      return matchesCat && matchesText;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredDocuments();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Course Documents & OCR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined),
            tooltip: 'Scan Document',
            onPressed: _openScannerSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search notes, slides, or OCR text (e.g. "TCP", "Laplace")...',
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

            // Category Chips
            Container(
              color: AppColors.surfaceLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCatChip('All'),
                    const SizedBox(width: 8),
                    _buildCatChip('Lecture Notes'),
                    const SizedBox(width: 8),
                    _buildCatChip('Exam Review'),
                    const SizedBox(width: 8),
                    _buildCatChip('Handwritten'),
                  ],
                ),
              ),
            ),

            // Document List
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.document_scanner_outlined,
                      title: 'No documents found',
                      message: _searchQuery.isNotEmpty
                          ? 'No scanned notes match "$_searchQuery" inside OCR text.'
                          : 'Scan your first lecture document for your courses.',
                      buttonText: '+ Scan Document',
                      onButtonPressed: _openScannerSheet,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        return InkWell(
                          onTap: () => _showDocumentDetails(doc),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryNavy.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        doc.courseCode,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      doc.category,
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${doc.pageCount} ${doc.pageCount == 1 ? 'page' : 'pages'}',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedLight),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  doc.title,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                if (doc.ocrText.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevatedLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.document_scanner, size: 14, color: AppColors.primaryBlue),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            doc.ocrText,
                                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openScannerSheet,
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        tooltip: 'Scan Document',
        child: const Icon(Icons.camera_alt_outlined),
      ),
    );
  }

  Widget _buildCatChip(String cat) {
    final isSelected = _selectedCategory == cat;
    return ChoiceChip(
      label: Text(cat),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedCategory = cat),
      selectedColor: AppColors.primaryNavy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  void _openScannerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DocumentScannerSheet(
        academicService: widget.academicService,
      ),
    );
  }

  void _showDocumentDetails(ScannedDocument doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(22),
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
                Text('${doc.courseCode} • ${doc.category}', style: AppTypography.labelUppercase),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.errorRose),
                  onPressed: () {
                    widget.academicService.deleteDocument(doc.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Text(doc.title, style: AppTypography.displaySmall),
            const SizedBox(height: 14),
            const Text('Extracted OCR Text:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevatedLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                doc.ocrText.isNotEmpty ? doc.ocrText : 'No OCR text available.',
                style: const TextStyle(fontSize: 13, height: 1.45),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

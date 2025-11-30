import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_provider.dart';

// Custom input formatter to limit text and show message when page is full
class PageLimitFormatter extends TextInputFormatter {
  final int maxLength;
  final VoidCallback onLimitReached;

  PageLimitFormatter({required this.maxLength, required this.onLimitReached});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > maxLength) {
      onLimitReached();
      return oldValue;
    }
    return newValue;
  }
}

class WordNoteEditScreen extends StatefulWidget {
  final Note? note;

  const WordNoteEditScreen({super.key, this.note});

  @override
  State<WordNoteEditScreen> createState() => _WordNoteEditScreenState();
}

class _WordNoteEditScreenState extends State<WordNoteEditScreen> {
  final List<TextEditingController> _pageControllers = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasChanges = false;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    if (isEditing && widget.note!.pages.isNotEmpty) {
      // Load existing pages
      for (var pageContent in widget.note!.pages) {
        final controller = TextEditingController(text: pageContent);
        controller.addListener(_onTextChanged);
        _pageControllers.add(controller);
      }
    } else if (isEditing && widget.note!.content.isNotEmpty) {
      // Legacy: Load from content field
      final controller = TextEditingController(text: widget.note!.content);
      controller.addListener(_onTextChanged);
      _pageControllers.add(controller);
    } else {
      // New note - start with one empty page
      final controller = TextEditingController();
      controller.addListener(_onTextChanged);
      _pageControllers.add(controller);
    }
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _addNewPage() {
    setState(() {
      final controller = TextEditingController();
      controller.addListener(_onTextChanged);
      _pageControllers.add(controller);
      _hasChanges = true;
    });

    // Scroll to the new page
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    for (var controller in _pageControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    // Collect all pages content
    final pages = _pageControllers.map((c) => c.text).toList();
    final allContent = pages.join('\n\n--- Page Break ---\n\n');

    // Check if all pages are empty
    if (pages.every((p) => p.trim().isEmpty)) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notesProvider = context.read<NotesProvider>();

      // Get title from first non-empty line
      String title = '';
      for (var page in pages) {
        if (page.trim().isNotEmpty) {
          title = page.split('\n').first.trim();
          if (title.length > 50) {
            title = '${title.substring(0, 50)}...';
          }
          break;
        }
      }

      if (isEditing) {
        await notesProvider.updateNote(
          id: widget.note!.id,
          title: title,
          content: allContent,
          userId: widget.note!.userId,
          noteType: NoteType.word,
          pages: pages,
        );
      } else {
        await notesProvider.addNote(
          title: title,
          content: allContent,
          noteType: NoteType.word,
          pages: pages,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    // Simply exit without saving - user must press Save button to save
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final loc = AppLocalizations.fromLocale(localeProvider.locale);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate page dimensions (A4 ratio: 1:1.414)
    // Make it fill most of the screen like PDF viewers
    final availableHeight = screenHeight - 200; // Account for AppBar and padding
    final pageHeight = availableHeight > 600 ? 600.0 : availableHeight;
    final pageWidth = pageHeight / 1.414; // A4 ratio

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF3d3d3d) : const Color(0xFFe8e8e8),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF2d2d2d) : Colors.white,
          elevation: 2,
          shadowColor: Colors.black26,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_rounded,
                color: isDark ? Colors.greenAccent : const Color(0xFF4CAF50),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                loc.t('word_note'),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: [
            // Page count
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_pageControllers.length} ${loc.t('pages')}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Save button
            GestureDetector(
              onTap: _isLoading ? null : _saveNote,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        loc.t('save'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Center(
              child: Column(
                children: [
                  // Pages
                  ..._pageControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    return _buildPage(
                      context: context,
                      controller: controller,
                      pageNumber: index + 1,
                      pageWidth: pageWidth,
                      pageHeight: pageHeight,
                      isDark: isDark,
                      loc: loc,
                    );
                  }),
                  const SizedBox(height: 12),
                  // Add page button - small and on the right
                  SizedBox(
                    width: pageWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _addNewPage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required BuildContext context,
    required TextEditingController controller,
    required int pageNumber,
    required double pageWidth,
    required double pageHeight,
    required bool isDark,
    required AppLocalizations loc,
  }) {
    // Calculate max characters based on page dimensions
    // fontSize = 14, lineHeight = 1.7, padding = 20 on all sides
    const fontSize = 14.0;
    const lineHeight = 1.7;
    const padding = 20.0;

    final availableHeight = pageHeight - (padding * 2);
    final availableWidth = pageWidth - (padding * 2);
    final lineHeightPixels = fontSize * lineHeight;
    final maxLines = (availableHeight / lineHeightPixels).floor();

    // Approximate characters per line (Arabic/English average)
    final charsPerLine = (availableWidth / (fontSize * 0.6)).floor();
    final maxChars = maxLines * charsPerLine;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // Page header
          SizedBox(
            width: pageWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${loc.t('page')} $pageNumber',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black45,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_pageControllers.length > 1)
                  GestureDetector(
                    onTap: () => _deletePage(pageNumber - 1),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.red.shade400,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // White paper
          Container(
            width: pageWidth,
            height: pageHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: pageNumber == 1 ? loc.t('start_writing') : '',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
                maxLines: maxLines,
                scrollPhysics: const NeverScrollableScrollPhysics(),
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                inputFormatters: [
                  PageLimitFormatter(
                    maxLength: maxChars,
                    onLimitReached: () => _showPageFullMessage(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPageFullMessage(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'الصفحة ممتلئة! اضغط على + لإضافة صفحة جديدة',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _deletePage(int index) {
    if (_pageControllers.length <= 1) return;

    setState(() {
      _pageControllers[index].dispose();
      _pageControllers.removeAt(index);
      _hasChanges = true;
    });
  }
}

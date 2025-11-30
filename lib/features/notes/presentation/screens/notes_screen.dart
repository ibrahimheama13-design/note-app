import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_dialog.dart';
import 'word_note_edit_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final loc = AppLocalizations.of(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: isDark
          ? const Color(0xFF0f0e17)
          : const Color(0xFFf8f9fa),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1a1a2e),
                      const Color(0xFF16213e),
                      const Color(0xFF0f3460),
                    ]
                  : [
                      const Color(0xFFfafafa),
                      const Color(0xFFf3e5f5),
                      const Color(0xFFe8eaf6),
                    ],
            ),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDark
                ? [const Color(0xFFbb86fc), const Color(0xFFf093fb)]
                : [const Color(0xFF667eea), const Color(0xFF764ba2)],
          ).createShader(bounds),
          child: Text(
            loc.t('my_notes'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _showSettingsSheet(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.3, -0.3),
                    radius: 1.2,
                    colors: [
                      Color(0xFFffd89b),
                      Color(0xFFff6b6b),
                      Color(0xFFc44569),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(width: 3, color: Colors.white),
                ),
                child: Center(
                  child: Text(
                    _getUserInitial(context),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: notesProvider.notesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                loc.t('error_loading'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return Center(
              child: Text(
                loc.t('no_notes'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final noteNumber = index + 1;
              // Check if Word Note by noteType OR if it has pages (for backwards compatibility)
              final isWordNote = note.noteType == NoteType.word || note.pages.isNotEmpty;

              return Dismissible(
                key: Key(note.id),
                background: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFef5350),
                        Color(0xFFe53935),
                        Color(0xFFc62828),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24.0),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(context),
                onDismissed: (_) async {
                  try {
                    await notesProvider.deleteNote(note.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم حذف الملاحظة'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('خطأ في حذف الملاحظة: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isWordNote
                          ? (isDark
                              ? [
                                  const Color(0xFF4CAF50).withValues(alpha: 0.15),
                                  const Color(0xFF2E7D32).withValues(alpha: 0.15),
                                  const Color(0xFF1B5E20).withValues(alpha: 0.12),
                                ]
                              : [
                                  const Color(0xFF4CAF50).withValues(alpha: 0.08),
                                  const Color(0xFF66BB6A).withValues(alpha: 0.08),
                                  const Color(0xFF81C784).withValues(alpha: 0.08),
                                ])
                          : (isDark
                              ? [
                                  const Color(0xFF667eea).withValues(alpha: 0.15),
                                  const Color(0xFF764ba2).withValues(alpha: 0.15),
                                  const Color(0xFF8e44ad).withValues(alpha: 0.12),
                                ]
                              : [
                                  const Color(0xFF667eea).withValues(alpha: 0.08),
                                  const Color(0xFF764ba2).withValues(alpha: 0.08),
                                  const Color(0xFFf093fb).withValues(alpha: 0.08),
                                ]),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      width: 3,
                      color: isWordNote
                          ? (isDark
                              ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                              : const Color(0xFF4CAF50).withValues(alpha: 0.3))
                          : (isDark
                              ? const Color(0xFF667eea).withValues(alpha: 0.4)
                              : const Color(0xFF667eea).withValues(alpha: 0.3)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isWordNote
                            ? Colors.green.withValues(alpha: 0.2)
                            : (isDark ? Colors.purple : Colors.blue)
                                .withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Note type badge (Word or Standard)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isWordNote
                                  ? [
                                      const Color(0xFF4CAF50),
                                      const Color(0xFF2E7D32),
                                      const Color(0xFF1B5E20),
                                    ]
                                  : (isDark
                                      ? [
                                          const Color(0xFF667eea),
                                          const Color(0xFF764ba2),
                                          const Color(0xFF8e44ad),
                                        ]
                                      : [
                                          const Color(0xFF667eea),
                                          const Color(0xFF764ba2),
                                          const Color(0xFFf093fb),
                                        ]),
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: isWordNote
                                    ? Colors.green.withValues(alpha: 0.4)
                                    : Colors.purple.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isWordNote
                                ? const Icon(
                                    Icons.description_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Text(
                                    '$noteNumber',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // Note content
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 64,
                          right: 16,
                          top: 16,
                          bottom: 16,
                        ),
                        child: InkWell(
                          onTap: () {
                            if (isWordNote) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => WordNoteEditScreen(note: note),
                                ),
                              );
                            } else {
                              _showNoteDialog(context, notesProvider, note);
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Word Note: Show content only (no separate title)
                              if (isWordNote) ...[
                                if (note.pages.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      '${note.pages.length} ${note.pages.length == 1 ? 'صفحة' : 'صفحات'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.green.shade300
                                            : Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                // Show content preview - use pages if available, otherwise use content
                                Text(
                                  _getWordNotePreview(note),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? const Color(0xFF81C784)
                                        : const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                              // Regular Note: Show title + content
                              if (!isWordNote) ...[
                                Text(
                                  note.title.isEmpty ? 'بدون عنوان' : note.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isDark
                                        ? const Color(0xFFbb86fc)
                                        : const Color(0xFF5e35b1),
                                  ),
                                ),
                                if (note.content.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    note.content,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? const Color(0xFFffa726)
                                          : const Color(0xFFf57c00),
                                    ),
                                  ),
                                ],
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: isWordNote
                                        ? (isDark
                                            ? Colors.green.shade300
                                            : Colors.green.shade700)
                                        : (isDark
                                            ? Colors.orange.shade300
                                            : Colors.orange.shade700),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    notesProvider.formatDate(note.date),
                                    style: TextStyle(
                                      color: isWordNote
                                          ? (isDark
                                              ? Colors.green.shade300
                                              : Colors.green.shade700)
                                          : (isDark
                                              ? Colors.orange.shade300
                                              : Colors.orange.shade700),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF8e44ad)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.5),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(35),
            onTap: () => _showNoteDialog(context, notesProvider, null),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }

  String _getUserInitial(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    final name = user?.displayName ?? user?.email ?? '';
    if (name.isEmpty) return '';
    return name.trim().characters.first.toUpperCase();
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الملاحظة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Get preview text for Word Note - uses pages if available, otherwise content
  String _getWordNotePreview(Note note) {
    // First try to use pages
    if (note.pages.isNotEmpty && note.pages.first.trim().isNotEmpty) {
      return note.pages.first.trim();
    }
    // Fallback to content (for old Word Notes without pages)
    if (note.content.isNotEmpty) {
      // Remove page break markers if present
      final cleanContent = note.content
          .replaceAll('--- Page Break ---', '')
          .trim();
      return cleanContent.isNotEmpty ? cleanContent : 'ملاحظة فارغة';
    }
    return 'ملاحظة فارغة';
  }

  void _showSettingsSheet(BuildContext context) {
    // Capture providers BEFORE showing modal to avoid deactivated widget exception
    final themeProvider = context.read<ThemeProvider>();
    final localeProvider = context.read<LocaleProvider>();
    final authProvider = context.read<AuthProvider>();
    final loc = AppLocalizations.fromLocale(localeProvider.locale);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                  : [const Color(0xFFfafafa), const Color(0xFFf8f9fa)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF667eea).withValues(alpha: 0.5),
                        const Color(0xFFf093fb).withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF667eea).withValues(alpha: 0.1),
                        const Color(0xFF764ba2).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF667eea).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.palette_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      loc.t('theme'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Switch(
                      value: themeProvider.isDark,
                      onChanged: (_) {
                        // Close bottom sheet before changing theme
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Future.microtask(() => themeProvider.toggleTheme());
                      },
                      activeTrackColor: const Color(0xFF667eea),
                      activeThumbColor: Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF764ba2).withValues(alpha: 0.1),
                        const Color(0xFFf093fb).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF764ba2).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF764ba2), Color(0xFFf093fb)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.language_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      loc.t('language'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () =>
                        _showLanguageSelection(context, localeProvider),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withValues(alpha: 0.1),
                        Colors.orange.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFef5350), Color(0xFFff6b6b)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      loc.t('logout'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // Close bottom sheet before signing out
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Future.microtask(() => authProvider.signOut());
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSelection(
    BuildContext context,
    LocaleProvider localeProvider,
  ) {
    // Capture values BEFORE showing modal to avoid deactivated widget exception
    final loc = AppLocalizations.fromLocale(localeProvider.locale);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                  : [const Color(0xFFfafafa), const Color(0xFFf8f9fa)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF667eea).withValues(alpha: 0.5),
                        const Color(0xFFf093fb).withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFFf093fb)],
                    ).createShader(bounds),
                    child: Text(
                      loc.t('select_language'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLanguageOption(
                  context: ctx,
                  locale: const Locale('ar'),
                  currentLocale: localeProvider.locale,
                  title: 'العربية',
                  icon: '🇸🇦',
                  onTap: () {
                    // Close all bottom sheets before changing locale
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Future.microtask(
                      () => localeProvider.setLocale(const Locale('ar')),
                    );
                  },
                ),
                _buildLanguageOption(
                  context: ctx,
                  locale: const Locale('en'),
                  currentLocale: localeProvider.locale,
                  title: 'English',
                  icon: '🇬🇧',
                  onTap: () {
                    // Close all bottom sheets before changing locale
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Future.microtask(
                      () => localeProvider.setLocale(const Locale('en')),
                    );
                  },
                ),
                _buildLanguageOption(
                  context: ctx,
                  locale: const Locale('fr'),
                  currentLocale: localeProvider.locale,
                  title: 'Français',
                  icon: '🇫🇷',
                  onTap: () {
                    // Close all bottom sheets before changing locale
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Future.microtask(
                      () => localeProvider.setLocale(const Locale('fr')),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required Locale locale,
    required Locale currentLocale,
    required String title,
    required String icon,
    required VoidCallback onTap,
  }) {
    final isSelected = locale.languageCode == currentLocale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              )
            : LinearGradient(
                colors: [
                  const Color(0xFF667eea).withValues(alpha: 0.1),
                  const Color(0xFF764ba2).withValues(alpha: 0.1),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : const Color(0xFF667eea).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 28)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFFbb86fc) : const Color(0xFF667eea)),
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: Colors.white)
            : null,
        onTap: onTap,
      ),
    );
  }

  Future<void> _showNoteDialog(
    BuildContext context,
    NotesProvider notesProvider,
    Note? note,
  ) async {
    final result = await showDialog(
      context: context,
      builder: (_) => NoteDialog(note: note),
    );

    if (result == null || !context.mounted) return;

    String title = '';
    String content = '';

    try {
      if (result is Map) {
        title = (result['title'] ?? '') as String;
        content = (result['content'] ?? '') as String;
      } else {
        // Try record-like access or named fields
        try {
          title = (result.title ?? '') as String;
          content = (result.content ?? '') as String;
        } catch (_) {
          try {
            title = result.$1 as String;
            content = result.$2 as String;
          } catch (_) {
            return;
          }
        }
      }
    } catch (_) {
      return;
    }

    if (title.isEmpty && content.isEmpty) return;

    try {
      final user = context.read<AuthProvider>().currentUser;
      final userId = user?.id ?? '';

      if (note == null) {
        await notesProvider.addNote(title: title, content: content);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت إضافة الملاحظة بنجاح'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await notesProvider.updateNote(
          id: note.id,
          title: title,
          content: content,
          userId: userId,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الملاحظة بنجاح'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

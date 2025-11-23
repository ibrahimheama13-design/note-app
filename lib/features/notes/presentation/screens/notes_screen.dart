import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_dialog.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('my_notes')),
        actions: [
          GestureDetector(
            onTap: () => _showSettingsSheet(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(
                child: Text(
                  _getUserInitial(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.all(8.0),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Dismissible(
                key: Key(note.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16.0),
                  child: const Icon(Icons.delete, color: Colors.white),
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
                child: Card(
                  child: ListTile(
                    title: Text(
                      note.title.isEmpty ? 'بدون عنوان' : note.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (note.content.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            notesProvider.formatDate(note.date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showNoteDialog(context, notesProvider, note),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(context, notesProvider, null),
        child: const Icon(Icons.add),
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

  void _showSettingsSheet(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final themeProvider = context.read<ThemeProvider>();
        final localeProvider = context.read<LocaleProvider>();
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.palette),
                title: Text(loc.t('theme')),
                trailing: Switch(
                  value: themeProvider.isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(loc.t('language')),
                onTap: () => _showLanguageSelection(context, localeProvider),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(loc.t('logout')),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<AuthProvider>().signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSelection(
    BuildContext context,
    LocaleProvider localeProvider,
  ) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(loc.t('select_language'))),
              RadioListTile<Locale>(
                value: const Locale('ar'),
                groupValue: localeProvider.locale,
                title: const Text('العربية'),
                onChanged: (v) {
                  if (v != null) localeProvider.setLocale(v);
                  Navigator.pop(ctx);
                },
              ),
              RadioListTile<Locale>(
                value: const Locale('en'),
                groupValue: localeProvider.locale,
                title: const Text('English'),
                onChanged: (v) {
                  if (v != null) localeProvider.setLocale(v);
                  Navigator.pop(ctx);
                },
              ),
              RadioListTile<Locale>(
                value: const Locale('fr'),
                groupValue: localeProvider.locale,
                title: const Text('Français'),
                onChanged: (v) {
                  if (v != null) localeProvider.setLocale(v);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
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

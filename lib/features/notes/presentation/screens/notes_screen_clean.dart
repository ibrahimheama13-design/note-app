import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // تعيين لون الستاتوس بار بـ gradient style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark
            ? const Color(0xFF0f0e17)
            : const Color(0xFFf8f9fa),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: isDark
          ? const Color(0xFF0a0412)
          : const Color(0xFFfaf8ff),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF2d1b69),
                      const Color(0xFF1a1045),
                      const Color(0xFF0f0731),
                    ]
                  : [
                      const Color(0xFFffffff),
                      const Color(0xFFf0e6ff),
                      const Color(0xFFe8d5ff),
                    ],
            ),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFFe0b3ff),
                    const Color(0xFFc084fc),
                    const Color(0xFFa855f7),
                  ]
                : [
                    const Color(0xFF6366f1),
                    const Color(0xFF8b5cf6),
                    const Color(0xFF9333ea),
                  ],
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    radius: 1.2,
                    colors: isDark
                        ? [
                            const Color(0xFFe0b3ff),
                            const Color(0xFFb466ff),
                            const Color(0xFF8e24ff),
                            const Color(0xFF6200ea),
                          ]
                        : [
                            const Color(0xFFffeaa7),
                            const Color(0xFFffb347),
                            const Color(0xFFff6b6b),
                            const Color(0xFFee5a6f),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.purple : Colors.pink).withValues(
                        alpha: 0.5,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getUserInitial(context),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
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
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withValues(alpha: 0.1),
                      Colors.orange.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 2,
                    color: Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFef5350), Color(0xFFe53935)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFef5350), Color(0xFFe53935)],
                      ).createShader(bounds),
                      child: Text(
                        loc.t('error_loading'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF667eea).withValues(alpha: 0.2),
                            const Color(0xFF764ba2).withValues(alpha: 0.2),
                          ]
                        : [
                            const Color(0xFF667eea).withValues(alpha: 0.1),
                            const Color(0xFF764ba2).withValues(alpha: 0.1),
                          ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                      Color(0xFFf093fb),
                    ],
                  ).createShader(bounds),
                  child: const CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            );
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF667eea).withValues(alpha: 0.1),
                            const Color(0xFFf093fb).withValues(alpha: 0.1),
                          ]
                        : [
                            const Color(0xFF667eea).withValues(alpha: 0.05),
                            const Color(0xFFf093fb).withValues(alpha: 0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    width: 2,
                    color: const Color(0xFF667eea).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF9333ea),
                                  const Color(0xFF7c3aed),
                                  const Color(0xFF6d28d9),
                                ]
                              : [
                                  const Color(0xFF818cf8),
                                  const Color(0xFF6366f1),
                                  const Color(0xFF4f46e5),
                                ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF7c3aed,
                            ).withValues(alpha: 0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.note_add_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: isDark
                            ? [const Color(0xFFbb86fc), const Color(0xFFf093fb)]
                            : [
                                const Color(0xFF667eea),
                                const Color(0xFF764ba2),
                              ],
                      ).createShader(bounds),
                      child: Text(
                        loc.t('no_notes'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final noteNumber = index + 1;

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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24.0),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(context, isDark),
                onDismissed: (_) async {
                  try {
                    await notesProvider.deleteNote(note.id);
                    if (context.mounted) {
                      _showGradientSnackBar(
                        context,
                        'تم حذف الملاحظة',
                        isDark,
                        isError: false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      _showGradientSnackBar(
                        context,
                        'خطأ في حذف الملاحظة: ${e.toString()}',
                        isDark,
                        isError: true,
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
                      colors: isDark
                          ? [
                              const Color(0xFF7c3aed).withValues(alpha: 0.20),
                              const Color(0xFF9333ea).withValues(alpha: 0.18),
                              const Color(0xFFa855f7).withValues(alpha: 0.15),
                            ]
                          : [
                              const Color(0xFF818cf8).withValues(alpha: 0.12),
                              const Color(0xFFa78bfa).withValues(alpha: 0.10),
                              const Color(0xFFc084fc).withValues(alpha: 0.08),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 0, color: Colors.transparent),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.purple : Colors.blue)
                            .withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  // إضافة gradient border
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 0, color: Colors.transparent),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0xFF8b5cf6).withValues(alpha: 0.7),
                              const Color(0xFFa855f7).withValues(alpha: 0.6),
                              const Color(0xFFc084fc).withValues(alpha: 0.5),
                            ]
                          : [
                              const Color(0xFF818cf8).withValues(alpha: 0.5),
                              const Color(0xFF9333ea).withValues(alpha: 0.5),
                              const Color(0xFFc084fc).withValues(alpha: 0.4),
                            ],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF1a0f2e),
                                const Color(0xFF160b2a),
                                const Color(0xFF120820),
                              ]
                            : [
                                Colors.white,
                                const Color(0xFFfaf8ff),
                                const Color(0xFFf5f3ff),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Stack(
                      children: [
                        // Note number badge with gradient
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
                                colors: isDark
                                    ? [
                                        const Color(0xFF8b5cf6),
                                        const Color(0xFF7c3aed),
                                        const Color(0xFF6d28d9),
                                      ]
                                    : [
                                        const Color(0xFF818cf8),
                                        const Color(0xFF6366f1),
                                        const Color(0xFF4f46e5),
                                      ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF8b5cf6,
                                  ).withValues(alpha: 0.6),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
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

                        // Three dots menu
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(
                                          0xFF8b5cf6,
                                        ).withValues(alpha: 0.3),
                                        const Color(
                                          0xFF7c3aed,
                                        ).withValues(alpha: 0.3),
                                      ]
                                    : [
                                        const Color(
                                          0xFF818cf8,
                                        ).withValues(alpha: 0.2),
                                        const Color(
                                          0xFF6366f1,
                                        ).withValues(alpha: 0.2),
                                      ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                color: isDark
                                    ? const Color(0xFFbb86fc)
                                    : const Color(0xFF6366f1),
                                size: 22,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: isDark
                                  ? const Color(0xFF1a0f2e)
                                  : Colors.white,
                              offset: const Offset(-10, 40),
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  final confirm = await _confirmDelete(
                                    context,
                                    isDark,
                                  );
                                  if (confirm && context.mounted) {
                                    try {
                                      await notesProvider.deleteNote(note.id);
                                      if (context.mounted) {
                                        _showGradientSnackBar(
                                          context,
                                          'تم حذف الملاحظة',
                                          isDark,
                                          isError: false,
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        _showGradientSnackBar(
                                          context,
                                          'خطأ في حذف الملاحظة',
                                          isDark,
                                          isError: true,
                                        );
                                      }
                                    }
                                  }
                                } else if (value == 'copy_title') {
                                  await Clipboard.setData(
                                    ClipboardData(
                                      text: note.title.isEmpty
                                          ? 'بدون عنوان'
                                          : note.title,
                                    ),
                                  );
                                  if (context.mounted) {
                                    _showGradientSnackBar(
                                      context,
                                      'تم نسخ العنوان',
                                      isDark,
                                      isError: false,
                                    );
                                  }
                                } else if (value == 'copy_content') {
                                  await Clipboard.setData(
                                    ClipboardData(text: note.content),
                                  );
                                  if (context.mounted) {
                                    _showGradientSnackBar(
                                      context,
                                      'تم نسخ المحتوى',
                                      isDark,
                                      isError: false,
                                    );
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFef5350),
                                              Color(0xFFe53935),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.delete_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'حذف الملاحظة',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'copy_title',
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isDark
                                                ? [
                                                    const Color(0xFF8b5cf6),
                                                    const Color(0xFF7c3aed),
                                                  ]
                                                : [
                                                    const Color(0xFF818cf8),
                                                    const Color(0xFF6366f1),
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.copy_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'نسخ العنوان',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'copy_content',
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isDark
                                                ? [
                                                    const Color(0xFFffa726),
                                                    const Color(0xFFff9800),
                                                  ]
                                                : [
                                                    const Color(0xFFfb8c00),
                                                    const Color(0xFFf57c00),
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.content_copy_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'نسخ المحتوى',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Note content
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 64,
                            right: 50,
                            top: 16,
                            bottom: 16,
                          ),
                          child: InkWell(
                            onTap: () =>
                                _showNoteDialog(context, notesProvider, note),
                            borderRadius: BorderRadius.circular(17),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: isDark
                                        ? [
                                            const Color(0xFFbb86fc),
                                            const Color(0xFFf093fb),
                                          ]
                                        : [
                                            const Color(0xFF5e35b1),
                                            const Color(0xFF7b1fa2),
                                          ],
                                  ).createShader(bounds),
                                  child: Text(
                                    note.title.isEmpty
                                        ? 'بدون عنوان'
                                        : note.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (note.content.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    note.content,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFFffa726)
                                          : const Color(0xFFf57c00),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDark
                                              ? [
                                                  Colors.orange.shade700,
                                                  Colors.deepOrange.shade700,
                                                ]
                                              : [
                                                  Colors.orange.shade600,
                                                  Colors.deepOrange.shade600,
                                                ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            colors: isDark
                                                ? [
                                                    Colors.orange.shade300,
                                                    Colors.deepOrange.shade300,
                                                  ]
                                                : [
                                                    Colors.orange.shade700,
                                                    Colors.deepOrange.shade700,
                                                  ],
                                          ).createShader(bounds),
                                      child: Text(
                                        notesProvider.formatDate(note.date),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF9333ea),
                    const Color(0xFF7c3aed),
                    const Color(0xFF6d28d9),
                    const Color(0xFF5b21b6),
                  ]
                : [
                    const Color(0xFF818cf8),
                    const Color(0xFF6366f1),
                    const Color(0xFF4f46e5),
                    const Color(0xFF4338ca),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7c3aed).withValues(alpha: 0.7),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFF6366f1).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(34),
            onTap: () => _showNoteDialog(context, notesProvider, null),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
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

  Future<bool> _confirmDelete(BuildContext context, bool isDark) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                  : [Colors.white, const Color(0xFFf8f9fa)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFef5350), Color(0xFFe53935)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFef5350), Color(0xFFe53935)],
                ).createShader(bounds),
                child: const Text(
                  'تأكيد الحذف',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'هل أنت متأكد من حذف هذه الملاحظة؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade500],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.of(ctx).pop(false),
                          child: const Center(
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFef5350), Color(0xFFe53935)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.of(ctx).pop(true),
                          child: const Center(
                            child: Text(
                              'حذف',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  void _showGradientSnackBar(
    BuildContext context,
    String message,
    bool isDark, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isError
                  ? [const Color(0xFFef5350), const Color(0xFFe53935)]
                  : isDark
                  ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
                  : [const Color(0xFF667eea), const Color(0xFF8e44ad)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (isError ? Colors.red : Colors.purple).withValues(
                  alpha: 0.4,
                ),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Capture providers BEFORE showing modal to avoid deactivated widget exception
    final themeProvider = context.read<ThemeProvider>();
    final localeProvider = context.read<LocaleProvider>();
    final authProvider = context.read<AuthProvider>();

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
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
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
                    border: Border.all(width: 0, color: Colors.transparent),
                  ),
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(width: 0, color: Colors.transparent),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF667eea).withValues(alpha: 0.5),
                        const Color(0xFF764ba2).withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                            : [Colors.white, const Color(0xFFf8f9fa)],
                      ),
                      borderRadius: BorderRadius.circular(14),
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
                        onChanged: (_) => themeProvider.toggleTheme(),
                        activeTrackColor: const Color(0xFF667eea),
                        activeThumbColor: Colors.white,
                      ),
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
                  ),
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(width: 0, color: Colors.transparent),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF764ba2).withValues(alpha: 0.5),
                        const Color(0xFFf093fb).withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                            : [Colors.white, const Color(0xFFf8f9fa)],
                      ),
                      borderRadius: BorderRadius.circular(14),
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
                  ),
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(width: 0, color: Colors.transparent),
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withValues(alpha: 0.5),
                        Colors.orange.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                            : [Colors.white, const Color(0xFFf8f9fa)],
                      ),
                      borderRadius: BorderRadius.circular(14),
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
                        Navigator.pop(ctx);
                        authProvider.signOut();
                      },
                    ),
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
    final loc = AppLocalizations.of(context);
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
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
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
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(ctx);
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
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(ctx);
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
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(ctx);
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
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = locale.languageCode == currentLocale.languageCode;

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
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      foregroundDecoration: isSelected
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0, color: Colors.transparent),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667eea).withValues(alpha: 0.4),
                  const Color(0xFF764ba2).withValues(alpha: 0.3),
                ],
              ),
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? const Color(0xFFbb86fc)
                                : const Color(0xFF667eea)),
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNoteDialog(
    BuildContext context,
    NotesProvider notesProvider,
    Note? note,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog(
      context: context,
      builder: (_) => NoteDialog(note: note),
    );

    if (result == null) return;

    String title = '';
    String content = '';

    try {
      if (result is Map) {
        title = (result['title'] ?? '') as String;
        content = (result['content'] ?? '') as String;
      } else {
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
    if (!context.mounted) return;

    final user = context.read<AuthProvider>().currentUser;
    final userId = user?.id ?? '';

    try {
      if (note == null) {
        await notesProvider.addNote(title: title, content: content);
        if (context.mounted) {
          _showGradientSnackBar(
            context,
            'تمت إضافة الملاحظة بنجاح',
            isDark,
            isError: false,
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
          _showGradientSnackBar(
            context,
            'تم تحديث الملاحظة بنجاح',
            isDark,
            isError: false,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showGradientSnackBar(
          context,
          'خطأ: ${e.toString()}',
          isDark,
          isError: true,
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_provider.dart';
import 'note_edit_screen.dart';
import 'word_note_edit_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Note> _filterNotes(List<Note> notes) {
    if (_searchQuery.isEmpty) return notes;
    return notes
        .where((note) => note.title.toLowerCase().startsWith(_searchQuery))
        .toList();
  }

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
        title: _isSearching
            ? Container(
                height: 45,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF667eea).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _updateSearchQuery,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: loc.t('search_by_title'),
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ).createShader(bounds),
                      child: Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              )
            : ShaderMask(
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
          // Search button
          GestureDetector(
            onTap: () {
              if (_isSearching) {
                _stopSearch();
              } else {
                _startSearch();
              }
            },
            child: Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isSearching
                      ? [const Color(0xFFef5350), const Color(0xFFe53935)]
                      : isDark
                          ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
                          : [const Color(0xFF667eea), const Color(0xFF8b5cf6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isSearching
                            ? Colors.red
                            : const Color(0xFF667eea))
                        .withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
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

          final allNotes = snapshot.data ?? [];
          final notes = _filterNotes(allNotes);

          if (allNotes.isEmpty) {
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

          // Show "no results" when searching but no matches found
          if (notes.isEmpty && _searchQuery.isNotEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFFff9800).withValues(alpha: 0.1),
                            const Color(0xFFff5722).withValues(alpha: 0.1),
                          ]
                        : [
                            const Color(0xFFff9800).withValues(alpha: 0.05),
                            const Color(0xFFff5722).withValues(alpha: 0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    width: 2,
                    color: const Color(0xFFff9800).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFff9800),
                            Color(0xFFff5722),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFff9800).withValues(alpha: 0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFff9800), Color(0xFFff5722)],
                      ).createShader(bounds),
                      child: Text(
                        loc.t('no_search_results'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"$_searchQuery"',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.black45,
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
                confirmDismiss: (_) => _confirmDelete(context, isDark, loc),
                onDismissed: (_) async {
                  try {
                    await notesProvider.deleteNote(note.id);
                    if (context.mounted) {
                      _showGradientSnackBar(
                        context,
                        loc.t('note_deleted'),
                        isDark,
                        isError: false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      _showGradientSnackBar(
                        context,
                        '${loc.t('delete_error')}: ${e.toString()}',
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
                      colors: (note.noteType == NoteType.word || note.pages.isNotEmpty)
                          ? (isDark
                              ? [
                                  const Color(0xFF4CAF50).withValues(alpha: 0.20),
                                  const Color(0xFF2E7D32).withValues(alpha: 0.18),
                                  const Color(0xFF1B5E20).withValues(alpha: 0.15),
                                ]
                              : [
                                  const Color(0xFF4CAF50).withValues(alpha: 0.12),
                                  const Color(0xFF66BB6A).withValues(alpha: 0.10),
                                  const Color(0xFF81C784).withValues(alpha: 0.08),
                                ])
                          : (isDark
                              ? [
                                  const Color(0xFF7c3aed).withValues(alpha: 0.20),
                                  const Color(0xFF9333ea).withValues(alpha: 0.18),
                                  const Color(0xFFa855f7).withValues(alpha: 0.15),
                                ]
                              : [
                                  const Color(0xFF818cf8).withValues(alpha: 0.12),
                                  const Color(0xFFa78bfa).withValues(alpha: 0.10),
                                  const Color(0xFFc084fc).withValues(alpha: 0.08),
                                ]),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 0, color: Colors.transparent),
                    boxShadow: [
                      BoxShadow(
                        color: (note.noteType == NoteType.word || note.pages.isNotEmpty)
                            ? Colors.green.withValues(alpha: 0.2)
                            : (isDark ? Colors.purple : Colors.blue).withValues(alpha: 0.2),
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
                      colors: (note.noteType == NoteType.word || note.pages.isNotEmpty)
                          ? (isDark
                              ? [
                                  const Color(0xFF4CAF50).withValues(alpha: 0.7),
                                  const Color(0xFF66BB6A).withValues(alpha: 0.6),
                                  const Color(0xFF81C784).withValues(alpha: 0.5),
                                ]
                              : [
                                  const Color(0xFF4CAF50).withValues(alpha: 0.5),
                                  const Color(0xFF66BB6A).withValues(alpha: 0.5),
                                  const Color(0xFF81C784).withValues(alpha: 0.4),
                                ])
                          : (isDark
                              ? [
                                  const Color(0xFF8b5cf6).withValues(alpha: 0.7),
                                  const Color(0xFFa855f7).withValues(alpha: 0.6),
                                  const Color(0xFFc084fc).withValues(alpha: 0.5),
                                ]
                              : [
                                  const Color(0xFF818cf8).withValues(alpha: 0.5),
                                  const Color(0xFF9333ea).withValues(alpha: 0.5),
                                  const Color(0xFFc084fc).withValues(alpha: 0.4),
                                ]),
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
                        // Note badge - icon for Word Note, number for Standard
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
                                colors: (note.noteType == NoteType.word || note.pages.isNotEmpty)
                                    ? [
                                        const Color(0xFF4CAF50),
                                        const Color(0xFF2E7D32),
                                        const Color(0xFF1B5E20),
                                      ]
                                    : (isDark
                                        ? [
                                            const Color(0xFF8b5cf6),
                                            const Color(0xFF7c3aed),
                                            const Color(0xFF6d28d9),
                                          ]
                                        : [
                                            const Color(0xFF818cf8),
                                            const Color(0xFF6366f1),
                                            const Color(0xFF4f46e5),
                                          ]),
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (note.noteType == NoteType.word || note.pages.isNotEmpty)
                                      ? Colors.green.withValues(alpha: 0.6)
                                      : const Color(0xFF8b5cf6).withValues(alpha: 0.6),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: (note.noteType == NoteType.word || note.pages.isNotEmpty)
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
                                    loc,
                                  );
                                  if (confirm && context.mounted) {
                                    try {
                                      await notesProvider.deleteNote(note.id);
                                      if (context.mounted) {
                                        _showGradientSnackBar(
                                          context,
                                          loc.t('note_deleted'),
                                          isDark,
                                          isError: false,
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        _showGradientSnackBar(
                                          context,
                                          loc.t('delete_error'),
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
                                          ? loc.t('title')
                                          : note.title,
                                    ),
                                  );
                                  if (context.mounted) {
                                    _showGradientSnackBar(
                                      context,
                                      loc.t('title_copied'),
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
                                      loc.t('content_copied'),
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
                                        loc.t('delete_note'),
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
                                        loc.t('copy_title'),
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
                                        loc.t('copy_content'),
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
                            onTap: () => _openNote(context, note),
                            borderRadius: BorderRadius.circular(17),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Word Note: Show content only (no title/content separation)
                                if (note.noteType == NoteType.word || note.pages.isNotEmpty) ...[
                                  // Page count for Word Note
                                  if (note.pages.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        '${note.pages.length} ${note.pages.length == 1 ? 'صفحة' : 'صفحات'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  // Content preview from pages
                                  Text(
                                    _getWordNotePreview(note),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFF81C784) : const Color(0xFF4CAF50),
                                    ),
                                  ),
                                ] else ...[
                                  // Standard Note: Show title + content
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: isDark
                                          ? [const Color(0xFFbb86fc), const Color(0xFFf093fb)]
                                          : [const Color(0xFF5e35b1), const Color(0xFF7b1fa2)],
                                    ).createShader(bounds),
                                    child: Text(
                                      note.title.isEmpty ? 'بدون عنوان' : note.title,
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
                                        color: isDark ? const Color(0xFFffa726) : const Color(0xFFf57c00),
                                      ),
                                    ),
                                  ],
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
            onTap: () => _showNoteTypeSelector(context),
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

  Future<bool> _confirmDelete(BuildContext context, bool isDark, AppLocalizations loc) async {
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
                child: Text(
                  loc.t('confirm_delete'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.t('delete_confirm_message'),
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
                          child: Center(
                            child: Text(
                              loc.t('cancel'),
                              style: const TextStyle(
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
                          child: Center(
                            child: Text(
                              loc.t('delete'),
                              style: const TextStyle(
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
                        // Close all bottom sheets before signing out
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Future.microtask(() => authProvider.signOut());
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
                  isDark: isDark,
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
                  isDark: isDark,
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

  void _openNote(BuildContext context, Note note) {
    // Open the appropriate screen based on note type
    if (note.noteType == NoteType.word) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WordNoteEditScreen(note: note),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NoteEditScreen(note: note),
        ),
      );
    }
  }

  void _showNoteTypeSelector(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    final loc = AppLocalizations.fromLocale(localeProvider.locale);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a1035) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ).createShader(bounds),
                  child: Text(
                    loc.t('create_note_type'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Standard Note Option
                _buildNoteTypeOption(
                  context: context,
                  icon: Icons.note_add_rounded,
                  title: loc.t('standard_note'),
                  description: loc.t('standard_note_desc'),
                  isDark: isDark,
                  colors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NoteEditScreen(note: null),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Word Note Option
                _buildNoteTypeOption(
                  context: context,
                  icon: Icons.description_rounded,
                  title: loc.t('word_note'),
                  description: loc.t('word_note_desc'),
                  isDark: isDark,
                  colors: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WordNoteEditScreen(note: null),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteTypeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors[0].withValues(alpha: 0.3),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors[0].withValues(alpha: isDark ? 0.15 : 0.08),
                colors[1].withValues(alpha: isDark ? 0.1 : 0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors[0].withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colors[0],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
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
}

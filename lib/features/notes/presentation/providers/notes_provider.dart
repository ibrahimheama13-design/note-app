import 'package:flutter/material.dart';

import '../../domain/entities/note.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_all_notes.dart';
import '../../domain/usecases/update_note.dart';

class NotesProvider extends ChangeNotifier {
  final GetAllNotes _getAllNotes;
  final AddNote _addNote;
  final UpdateNote _updateNote;
  final DeleteNote _deleteNote;

  NotesProvider({
    required GetAllNotes getAllNotes,
    required AddNote addNote,
    required UpdateNote updateNote,
    required DeleteNote deleteNote,
  }) : _getAllNotes = getAllNotes,
       _addNote = addNote,
       _updateNote = updateNote,
       _deleteNote = deleteNote;

  Stream<List<Note>> get notesStream => _getAllNotes();

  Future<void> addNote({
    required String title,
    required String content,
    NoteType noteType = NoteType.standard,
    List<String> pages = const [],
  }) async {
    try {
      final note = Note(
        id: '', // Will be set by Firebase
        title: title,
        content: content,
        date: DateTime.now(),
        userId: '', // Will be set by repository
        noteType: noteType,
        pages: pages,
      );

      await _addNote(note);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
    required String userId,
    NoteType noteType = NoteType.standard,
    List<String> pages = const [],
  }) async {
    try {
      final note = Note(
        id: id,
        title: title,
        content: content,
        date: DateTime.now(),
        userId: userId,
        noteType: noteType,
        pages: pages,
      );

      await _updateNote(note);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _deleteNote(id);
    } catch (e) {
      rethrow;
    }
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} $hour:$minute';
  }
}

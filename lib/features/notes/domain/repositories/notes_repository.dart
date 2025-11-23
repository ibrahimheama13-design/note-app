import '../entities/note.dart';

abstract class NotesRepository {
  Stream<List<Note>> getAllNotes();
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
}

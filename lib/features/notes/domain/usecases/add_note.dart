import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class AddNote {
  final NotesRepository _notesRepository;

  const AddNote(this._notesRepository);

  Future<void> call(Note note) => _notesRepository.addNote(note);
}

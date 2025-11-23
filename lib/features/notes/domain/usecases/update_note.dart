import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class UpdateNote {
  final NotesRepository _notesRepository;

  const UpdateNote(this._notesRepository);

  Future<void> call(Note note) => _notesRepository.updateNote(note);
}

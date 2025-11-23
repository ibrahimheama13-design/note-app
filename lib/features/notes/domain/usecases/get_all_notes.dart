import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class GetAllNotes {
  final NotesRepository _notesRepository;

  const GetAllNotes(this._notesRepository);

  Stream<List<Note>> call() => _notesRepository.getAllNotes();
}

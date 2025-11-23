import '../repositories/notes_repository.dart';

class DeleteNote {
  final NotesRepository _notesRepository;

  const DeleteNote(this._notesRepository);

  Future<void> call(String id) => _notesRepository.deleteNote(id);
}

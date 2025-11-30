import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../models/note_model.dart';

class FirebaseNotesRepository implements NotesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseNotesRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _notesCollection =>
      _firestore.collection('notes');

  @override
  Stream<List<Note>> getAllNotes() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw UnauthorizedException('المستخدم غير مسجل الدخول');

    return _notesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NoteModel.fromDocument(doc))
              .toList();
        });
  }

  @override
  Future<void> addNote(Note note) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw UnauthorizedException('المستخدم غير مسجل الدخول');

    final noteModel = NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      date: note.date,
      userId: userId,
      noteType: note.noteType,
      pages: note.pages,
    );

    await _notesCollection.add(noteModel.toMap());
  }

  @override
  Future<void> updateNote(Note note) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw UnauthorizedException('المستخدم غير مسجل الدخول');
    if (note.userId != userId) {
      throw UnauthorizedException('ليس لديك صلاحية تعديل هذه الملاحظة');
    }

    final noteModel = NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      date: note.date,
      userId: userId,
      noteType: note.noteType,
      pages: note.pages,
    );

    await _notesCollection.doc(note.id).update(noteModel.toMap());
  }

  @override
  Future<void> deleteNote(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw UnauthorizedException('المستخدم غير مسجل الدخول');

    final doc = await _notesCollection.doc(id).get();
    if (!doc.exists) throw NotFoundException('الملاحظة غير موجودة');

    final note = NoteModel.fromDocument(doc);
    if (note.userId != userId) {
      throw UnauthorizedException('ليس لديك صلاحية حذف هذه الملاحظة');
    }

    await _notesCollection.doc(id).delete();
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  @override
  String toString() => message;
}

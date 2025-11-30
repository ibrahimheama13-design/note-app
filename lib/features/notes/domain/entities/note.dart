import 'package:equatable/equatable.dart';

enum NoteType { standard, word }

class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String userId;
  final NoteType noteType;
  final List<String> pages; // For word notes - each page content

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.userId,
    this.noteType = NoteType.standard,
    this.pages = const [],
  });

  @override
  List<Object> get props => [id, title, content, date, userId, noteType, pages];

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    String? userId,
    NoteType? noteType,
    List<String>? pages,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      noteType: noteType ?? this.noteType,
      pages: pages ?? this.pages,
    );
  }
}

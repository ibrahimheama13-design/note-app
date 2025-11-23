import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String userId;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.userId,
  });

  @override
  List<Object> get props => [id, title, content, date, userId];

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    String? userId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
}

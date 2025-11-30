import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.date,
    required super.userId,
    super.noteType = NoteType.standard,
    super.pages = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'userId': userId,
      'noteType': noteType.name,
      'pages': pages,
    };
  }

  factory NoteModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Parse date safely with fallback to current time
    DateTime parsedDate;
    try {
      final dateValue = data['date'];
      if (dateValue is String) {
        parsedDate = DateTime.parse(dateValue);
      } else if (dateValue is Timestamp) {
        parsedDate = dateValue.toDate();
      } else {
        parsedDate = DateTime.now();
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }

    // Parse note type
    NoteType noteType = NoteType.standard;
    final typeValue = data['noteType'] as String?;
    if (typeValue == 'word') {
      noteType = NoteType.word;
    }

    // Parse pages
    List<String> pages = [];
    final pagesData = data['pages'];
    if (pagesData is List) {
      pages = pagesData.map((e) => e.toString()).toList();
    }

    return NoteModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      date: parsedDate,
      userId: data['userId'] as String? ?? '',
      noteType: noteType,
      pages: pages,
    );
  }
}

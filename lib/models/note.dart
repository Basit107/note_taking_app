import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String noteId;
  final String title;
  final String content;
  final Timestamp? createdAt;
  final String userId;

  Note({
    required this.noteId,
    required this.title,
    required this.content,
    this.createdAt,
    required this.userId,
  });

  // Convert to/from Firestore document
  factory Note.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Note(
      noteId: doc.id,
      title: data['title'],
      content: data['content'],
      createdAt: data['createdAt'],
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId,
    };
  }
}

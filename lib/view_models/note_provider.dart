import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_taking_app/models/note.dart';

class NotesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  List<Note> _notes = [];

  List<Note> get notes => _notes;

  List<String> _getSearchTerms(String title, String content) {
    // Combine title and content, split into words
    final combinedText = '$title $content'.toLowerCase();

    // Split into words and remove empty/duplicate entries
    return combinedText
        .split(RegExp(r'\W+')) // Split by non-word characters
        .where((word) => word.isNotEmpty)
        .toSet()
        .toList();
  }

  // Get the total number of notes
  Future<int> getNotesCount(String userId) async {
    final snapshot = await _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<void> fetchNotes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      _notes = snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
      print('Manual query found ${snapshot.docs.length} docs');
      notifyListeners();
    } catch (e) {
      rethrow;
      print(e);
    }
  }

  Future<void> addNote(Note note) async {
    try {
      await _firestore.collection('notes').add(note.toMap());
      await fetchNotes(note.userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNote(String noteId, String userId) async {
    await _firestore.collection('notes').doc(noteId).delete();
    await fetchNotes(userId);
  }

  Future<void> updateNote(Note note) async {
    try {
      final searchTerms = _getSearchTerms(note.title, note.content);

      await _firestore.collection('notes').doc(note.noteId).update({
        'title': note.title,
        'content': note.content,
        'searchTerms': searchTerms, // Update search terms
      });
      // Refresh the notes list
      await fetchNotes(note.userId);
    } catch (e) {
      rethrow;
    }
  }
}

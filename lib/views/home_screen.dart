import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:note_taking_app/view_models/auth_provider.dart';
import 'package:note_taking_app/view_models/note_provider.dart';
import 'package:note_taking_app/views/edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Notes'), actions: [
        IconButton(
            onPressed: () => authProvider.logout(), icon: Icon(Icons.logout)),
      ]),
      body: ListView.builder(
        itemCount: notesProvider.notes.length,
        itemBuilder: (ctx, index) {
          final note = notesProvider.notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            trailing: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditNoteScreen(note: note),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () =>
                      notesProvider.deleteNote(note.noteId, note.userId),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddEditNoteScreen()),
        ),
      ),
    );
  }
}

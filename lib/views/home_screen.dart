import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:note_taking_app/view_models/custom_auth_provider.dart';
import 'package:note_taking_app/view_models/note_provider.dart';
import 'package:note_taking_app/views/edit_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notes when the screen loads
    final authProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    notesProvider.fetchNotes(authProvider.user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<CustomAuthProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Notes'), actions: [
        IconButton(
            onPressed: () => authProvider.logout(), icon: Icon(Icons.logout)),
      ]),
      body: _buildNotesList(notesProvider),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddEditNoteScreen()),
        ),
      ),
    );
  }

  Widget _buildNotesList(NotesProvider notesProvider) {
    if (notesProvider.notes.isEmpty) {
      return Center(child: Text('No notes yet! Tap + to add one.'));
    }

    return ListView.builder(
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
    );
  }
}

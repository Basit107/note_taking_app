import 'package:flutter/material.dart';
import 'package:note_taking_app/models/note.dart';
import 'package:provider/provider.dart';
import 'package:note_taking_app/view_models/custom_auth_provider.dart';
import 'package:note_taking_app/view_models/note_provider.dart';
import 'package:note_taking_app/views/edit_add_note_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
        IconButton(
            onPressed: () => {},
            icon: Icon(Icons.account_circle, size: 30, color: Colors.white)),
      ]),
      body: _buildNotesList(notesProvider, authProvider),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddEditNoteScreen()),
        ),
      ),
    );
  }

  Widget _buildNotesList(
      NotesProvider notesProvider, CustomAuthProvider authProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder(
      future: notesProvider.firestore
          .collection("notes")
          .where('userId', isEqualTo: authProvider.user!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No notes yet! Tap + to add one.',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          );
        }

        return Container(
          height: double.maxFinite,
          width: double.maxFinite,
          constraints: BoxConstraints.expand(),
          // Add this
          child: ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) {
              final doc = snapshot.data!.docs[index];
              final noteData = doc.data() as Map<String, dynamic>;

              return Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(noteData['title']?.toString() ?? 'No Title'),
                      subtitle:
                          Text(noteData['content']?.toString() ?? 'No Content'),
                      trailing: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditNoteScreen(
                                  note: Note(
                                    noteId: doc.id,
                                    title: noteData['title'],
                                    content: noteData['content'],
                                    createdAt: noteData['createdAt'],
                                    userId: noteData['userId'],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => notesProvider.deleteNote(
                              doc.id,
                              authProvider.user!.uid,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

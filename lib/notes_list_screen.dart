import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notes_provider.dart';
import 'auth_provider.dart';
import 'notes_service.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notes when the screen is initialized
    Provider.of<NotesProvider>(context, listen: false).notes;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _addNote() async {
    String? noteText = await _showNoteDialog(context);
    if (noteText != null && noteText.isNotEmpty) {
      try {
        await Provider.of<NotesProvider>(
          context,
          listen: false,
        ).addNote(noteText);
        _showSnackBar('Note added successfully');
      } catch (e) {
        _showSnackBar('Failed to add note: ${e.toString()}');
      }
    }
  }

  Future<void> _editNote(Note note) async {
    String? noteText = await _showNoteDialog(context, initialText: note.text);
    if (noteText != null && noteText.isNotEmpty) {
      try {
        await Provider.of<NotesProvider>(
          context,
          listen: false,
        ).updateNote(note.id, noteText);
        _showSnackBar('Note updated successfully');
      } catch (e) {
        _showSnackBar('Failed to update note: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteNote(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Note'),
            content: const Text(
              'Are you sure you want to delete this note? This action is irreversible.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    try {
      await Provider.of<NotesProvider>(context, listen: false).deleteNote(id);
      _showSnackBar('Note deleted successfully');
    } catch (e) {
      _showSnackBar('Failed to delete note:  ${e.toString()}');
    }
  }

  Future<String?> _showNoteDialog(
    BuildContext context, {
    String? initialText,
  }) async {
    TextEditingController textController = TextEditingController(
      text: initialText ?? '',
    ); // Set initial value here

    return showDialog<String>(
      // Return String? which is the note text
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(initialText == null ? 'Add Note' : 'Edit Note'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Enter your note'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Return null on cancel
              },
            ),
            ElevatedButton(
              child: Text(initialText == null ? 'Add' : 'Save'),
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(textController.text); // Return the entered text
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
      // If user is not logged in, navigate back to AuthScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
    }

    if (notesProvider.isLoading && notesProvider.notes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Your Notes')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body:
          notesProvider.notes.isEmpty
              ? const Center(
                child: Text(
                  'Nothing here yet—tap ➕ to add a note.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: notesProvider.notes.length,
                itemBuilder: (context, index) {
                  final note = notesProvider.notes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: ListTile(
                      title: Text(note.text),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editNote(note),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteNote(note.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

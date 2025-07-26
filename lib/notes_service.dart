import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Note {
  final String id;
  final String text;
  final String userId;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Note({
    required this.id,
    required this.text,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final now = Timestamp.now();
    return Note(
      id: doc.id,
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] ?? now,
      updatedAt: data['updatedAt'] ?? now,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<List<Note>> fetchNotes() {
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: currentUser!.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
        });
  }

  Future<void> addNote(String text) async {
    if (currentUser == null) return;
    final now = Timestamp.now();
    await _firestore.collection('notes').add({
      'text': text,
      'userId': currentUser!.uid,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> updateNote(String id, String text) async {
    await _firestore.collection('notes').doc(id).update({
      'text': text,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteNote(String id) async {
    await _firestore.collection('notes').doc(id).delete();
  }
}

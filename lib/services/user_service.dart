import 'dart:math';

import 'package:meet_christ/models/user.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meet_christ/repositories/events_repository.dart';

class UserService {

  UserModel user = UserModel.empty();

  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  /// Get user by id from Firestore
  Future<UserModel?> getUser(String id) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(id).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        user = UserModel.fromMap(data, doc.id);
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Create a new user in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      throw e; // rethrow or handle accordingly
    }
  }
}

class FirestoreUserRepository extends DatabaseService2<String, UserModel> {
  @override
  Future<UserModel> create(UserModel data) async {
    var col = FirebaseFirestore.instance.collection('users');
    final docRef = col.doc(data.id);
    await docRef.set(data.toMap());
    return data;
  }

  @override
  Future<List<UserModel>> createAll(List<UserModel> allData) {
    throw UnimplementedError();
  }

  @override
  Future<List<UserModel>> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<List<UserModel>?> getAllById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<UserModel>> getAllByUserIds(List<String> userIds) async {
    var col = FirebaseFirestore.instance.collection('users');
    var snapshot = await col
        .where(FieldPath.documentId, whereIn: userIds)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<UserModel?> getById(String id) async {
    var col = FirebaseFirestore.instance.collection('users');
    var docRef = col.doc(id);

    var docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      return UserModel.fromMap(docSnapshot.data()!, docSnapshot.id);
    } else {
      return null;
    }
  }

  @override
  Future<bool> update(UserModel data) async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    try {
      await usersRef.doc(data.id).update(data.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }
}

final bibleNames = [
  // Old Testament
  "Adam",
  "Eve",
  "Noah",
  "Abraham",
  "Sarah",
  "Isaac",
  "Rebekah",
  "Jacob",
  "Rachel",
  "Leah",
  "Joseph",
  "Moses",
  "Aaron",
  "Miriam",
  "Joshua",
  "Caleb",
  "Samuel",
  "David",
  "Jonathan",
  "Solomon",
  "Elijah",
  "Elisha",
  "Isaiah",
  "Jeremiah",
  "Ezekiel",
  "Daniel",
  "Hosea",
  "Joel",
  "Amos",
  "Obadiah",
  "Jonah",
  "Micah",
  "Nahum",
  "Habakkuk",
  "Zephaniah",
  "Haggai",
  "Zechariah",
  "Malachi",
  "Job",
  "Esther",
  "Ruth",
  "Boaz",
  "Gideon",
  "Deborah",
  "Samson",
  "Delilah",
  "Saul",
  "Rehoboam",
  "Jeroboam",
  "Hezekiah",
  "Josiah",
  "Ezra",
  "Nehemiah",
  "Esther",
  "Mordecai",

  // New Testament
  "Mary",
  "Joseph",
  "Jesus",
  "John",
  "Peter",
  "Paul",
  "James",
  "Andrew",
  "Philip",
  "Bartholomew",
  "Thomas",
  "Matthew",
  "Simon",
  "Thaddaeus",
  "Judas",
  "Barnabas",
  "Timothy",
  "Titus",
  "Silas",
  "Lydia",
  "Priscilla",
  "Aquila",
  "Apollos",
  "Stephen",
  "Philip",
  "Cornelius",
  "Luke",
  "Mark",

  // Extra Biblical figures
  "Herod",
  "Pilate",
  "Caiaphas",
  "Nicodemus",
  "Zacchaeus",
  "Martha",
  "Mary Magdalene",
  "Elizabeth", "Zechariah", "Anna", "Simeon",
];

final random = Random();

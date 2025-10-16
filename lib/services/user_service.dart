import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:meet_christ/models/user.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meet_christ/pages/chat_list_page.dart';
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
        return UserModel.fromMap(data, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  void setLoggedInUser(UserModel loggedInUser) {
    user = loggedInUser;
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

  /// Fetch all users from Firestore without my id
  Future<List<UserModel>> fetchUsers() async {
    try {
      QuerySnapshot snapshot = await _usersCollection
          .where('isAnonym', isEqualTo: false)
          .where(FieldPath.documentId, isNotEqualTo: user.id)
          .get();
      return snapshot.docs
          .map(
            (doc) =>
                UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .where((user) => user.id != this.user.id)
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future fetchNewChatUsers() async {}

  Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      print('Error deleting user: $e');
      throw e; 
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

class ChatListRepository {
  Future<bool> createChat(SingleChatEntity chat) async {
    var col = FirebaseFirestore.instance.collection('singlechats');
    try {
      final docRef = col.doc(chat.id);
      await docRef.set(chat.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<SingleChatEntity>> fetchChats(String myId) async {
    final col = FirebaseFirestore.instance.collection('singlechats');

    final chatsQuery = await col
        .where('participantIds', arrayContains: myId)
        .get();

    final allDocs = chatsQuery.docs;

    // Fetch all messages for each chat
    final chats = await Future.wait(
      allDocs.map((doc) async {
        final data = doc.data();
        final chatId = doc.id;

        // 🔥 Fetch subcollection "messages"
        final messagesSnap = await doc.reference
            .collection('messages')
            .orderBy('createdAt', descending: false)
            .get();

        final messages = messagesSnap.docs.map((msgDoc) {
          return ChatMessageEntity.fromMap(msgDoc.data());
        }).toList();

        // 🧩 Combine messages into chat
        final chatEntity = SingleChatEntity.fromMap({...data}, messages);

        // chatEntity.copyWith(messages: messages);

        return chatEntity;
      }),
    );

    return chats;
  }

  Future startChatWithUser(
    UserModel me,
    UserModel chatPartner,
    ChatMessageEntity message,
  ) async {
    var col = FirebaseFirestore.instance.collection('chats');
    var chatQuery = await col
        .where('meId', isEqualTo: chatPartner.id)
        .where('otherId', isEqualTo: chatPartner.id)
        .get();

    if (chatQuery.docs.isNotEmpty) {
      return chatQuery.docs.first.id;
    } else {
      var newChat = SingleChatEntity.fromMap(
        {
          'meId': me.id,
          'otherId': chatPartner.id,
          'messages': [message.toMap()],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        [message],
      );
      var docRef = await col.add(newChat.toMap());
      return docRef.id;
    }
  }

  Future<SingleChatEntity> getChatById(String chatId) async {
    var chats = await fetchChats(GetIt.I.get<UserService>().user.id);
    var chat = chats.where((chat) => chat.id == chatId).first;

    return chat;
  }

  Future<bool> sendMessage({
    required String chatId,
    required ChatMessageEntity message,
  }) async {
    try {
      var col = FirebaseFirestore.instance
          .collection('singlechats')
          .doc(chatId)
          .collection('messages');
      final docRef = col.doc(message.id);
      await docRef.set(message.toMap());
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<void> markAllMessagesAsSeen(String chatId) async {
    final userId = GetIt.I.get<UserService>().user.id;

    try {
      final chatRef = FirebaseFirestore.instance
          .collection('singlechats')
          .doc(chatId)
          .collection('messages');

      // 🔹 Get recent messages (avoid loading thousands)
      final querySnapshot = await chatRef
          .limit(100) // adjust as needed
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final seenBy = List<String>.from(data['seenBy'] ?? []);

        // Only update if userId not already there
        if (!seenBy.contains(userId)) {
          seenBy.add(userId);
          batch.update(doc.reference, {
            'seenBy': FieldValue.arrayUnion([userId]),
          });
        }
      }

      await batch.commit();
      print('✅ All messages marked as seen by $userId');
    } catch (e, st) {
      print('🔥 Error marking messages as seen: $e\n$st');
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

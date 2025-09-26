import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/models/user_credentails.dart';
import 'package:meet_christ/repositories/auth_repository.dart';
import 'package:meet_christ/repositories/events_repository.dart';

class UserService {
  final DatabaseService2<String, User> userRepository;
  final IAuthRepository authRepository;

  User? loggedInUser;
  User get user => loggedInUser!;

  UserService({required this.userRepository, required this.authRepository});

  Future<bool> updatePassword(
    String email,
    String oldPassword,
    String newPassword,
  ) async {
    return false;
  }

  Future<AuthUser?> emailAvailable(String email) async {
    var newUser = await authRepository.emailIsAvailable(email);
    if (newUser?.user != null) {
      var user = User(
        id: newUser!.user!.uid,
        firstname: "",
        email: email,
        lastname: "",
      );
      loggedInUser = user;
    }
    return newUser;
  }

  Future<User?> login(UserCredentials userCredentials) async {
    var authUser = await authRepository.loginWithUserCredentials(
      userCredentials,
    );

    var user = await userRepository.getById(authUser.uid);
    loggedInUser = user;
    /*
    var user = await userRepository.getById(
      (collection) => collection.where("uid", isEqualTo: authUser.uid),
    );
    loggedInUser = user.dataOrNull![0]; */
    return loggedInUser;
  }

  Future<User?> loginAnonymously() async {
    var authUser = await authRepository.signInAnonymously();

    var id = authUser.uid;
    var loadedUser = await userRepository.getById(id);
    if (loadedUser == null) {
      loggedInUser = await userRepository.create(
        User(
          email: "",
          firstname: bibleNames[random.nextInt(bibleNames.length)],
          lastname: "",
          id: id,
          isAnonym: authUser.isAnonymous,
        ),
      );
    } else {
      loggedInUser = loadedUser;
    }

    await saveAnonymUserIdLocally(id);
    /*
    var user = await userRepository.getById(
      (collection) => collection.where("uid", isEqualTo: authUser.uid),
    );
    loggedInUser = user.dataOrNull![0]; */
    return loggedInUser;
  }

  Future<User> signUp(UserCredentials userCredentials, User newUserData) async {
    var authUser = await authRepository.signupWithUserCredentials(
      userCredentials,
    );
    if (authUser != null) {
      User user = User(
        id: authUser.uid,
        email: newUserData.email,
        firstname: newUserData.firstname,
        lastname: newUserData.lastname,
        birthday: newUserData.birthday
      );
      return await userRepository.create(user);
    }
    throw Exception('Signup failed');
  }

  Future<void> saveAnonymUserIdLocally(String userId) async {
    var localStorage = FlutterSecureStorage();
    await localStorage.write(key: 'anonym', value: "true");
    await localStorage.write(key: 'userId', value: userId);
  }

  Future<void> saveUserdataLocally(LoginData user) async {
    var localStorage = FlutterSecureStorage();
    await localStorage.write(key: 'anonym', value: "false");
    await localStorage.write(key: 'name', value: user.name);
    await localStorage.write(key: 'password', value: user.password);
  }

  Future<(LoginData?, bool)> loadLogindataLocally() async {
    var localStorage = FlutterSecureStorage();
    var name = await localStorage.read(key: 'name');
    var isAnonymString = await localStorage.read(key: 'anonym');
    var isAnonym = false;
    if (isAnonymString?.isEmpty == true) {
      isAnonym = false;
    } else {
      isAnonym = bool.parse(isAnonymString!);
      return (null, isAnonym);
    }
    var password = await localStorage.read(key: 'password');
    if (name == null || password == null) {
      return (null, false);
    } else {
      return (LoginData(name: name, password: password), isAnonym);
    }
  }

  Future<void> logout() async {
    loggedInUser = null;
    var localStorage = FlutterSecureStorage();
    await localStorage.delete(key: 'name');
    await localStorage.delete(key: 'password');
    await localStorage.delete(key: 'anonym');
    await authRepository.logout();
  }
}

class FirestoreUserRepository extends DatabaseService2<String, User> {
  @override
  Future<User> create(User data) async {
    var col = FirebaseFirestore.instance.collection('users');
    final docRef = col.doc(data.id);
    await docRef.set(data.toMap());
    return data;
  }

  @override
  Future<List<User>> createAll(List<User> allData) {
    throw UnimplementedError();
  }

  @override
  Future<List<User>> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<List<User>?> getAllById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<User>> getAllByUserIds(List<String> userIds) async {
    var col = FirebaseFirestore.instance.collection('users');
    var snapshot = await col
        .where(FieldPath.documentId, whereIn: userIds)
        .get();
    return snapshot.docs
        .map((doc) => User.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<User?> getById(String id) async {
    var col = FirebaseFirestore.instance.collection('users');
    var docRef = col.doc(id);

    var docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      return User.fromMap(docSnapshot.data()!, docSnapshot.id);
    } else {
      return null;
    }
  }

  @override
  Future<bool> update(User data) async {
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

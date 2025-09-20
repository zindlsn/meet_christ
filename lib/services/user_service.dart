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

  /// Signs up a new user with the given credentials and user data.
  Future<User> signUp(UserCredentials userCredentials, User newUserData) async {
    var authUser = await authRepository.signupWithUserCredentials(
      userCredentials,
    );
    if (authUser != null) {
      User user = User(id: authUser.uid, email: newUserData.email, firstname: newUserData.firstname, lastname: newUserData.lastname);
      return await userRepository.create(user);
    }
    throw Exception('Signup failed');
  }

  Future<void> saveUserdataLocally(LoginData user) async {
    var localStorage = FlutterSecureStorage();
    await localStorage.write(key: 'name', value: user.name);
    await localStorage.write(key: 'password', value: user.password);
  }

  Future<LoginData?> loadLogindataLocally() async {
    var localStorage = FlutterSecureStorage();
    var name = await localStorage.read(key: 'name');
    var password = await localStorage.read(key: 'password');
    if (name == null || password == null) {
      return null;
    } else {
      return LoginData(name: name, password: password);
    }
  }

  Future<void> logout() async {
    loggedInUser = null;
    var localStorage = FlutterSecureStorage();
    await localStorage.delete(key: 'name');
    await localStorage.delete(key: 'password');
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

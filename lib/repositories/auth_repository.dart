import 'package:firebase_auth/firebase_auth.dart';

import 'package:meet_christ/models/user_credentails.dart';

abstract class IAuthRepository {
  Future<User> loginWithUserCredentials(UserCredentials userCredentials);
  Future<User?> signupWithUserCredentials(UserCredentials userCredentials);
  Future<void> checkActionCode(String actionCode);
  Future<void> logout();
}

class FirestoreAuthRepository implements IAuthRepository {
  @override
  Future<User> loginWithUserCredentials(UserCredentials userCredentials) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    final UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: userCredentials.email,
      password: userCredentials.password,
    );
    return userCredential.user!;
  }

  @override
  Future<User?> signupWithUserCredentials(
    UserCredentials userCredentials,
  ) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      final UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(
            email: userCredentials.email,
            password: userCredentials.password,
          );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else {
        print('Signup failed: ${e.message}');
      }
      return null;
    } catch (e) {
      print('Signup failed: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> checkActionCode(String actionCode) async {
    try {
      // Example: verifying a password reset code
    ActionCodeInfo info =   await FirebaseAuth.instance.checkActionCode(actionCode);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'expired-action-code':
          print('The action code has expired.');
          // Handle expired code (e.g., prompt the user to request a new one)
          break;
        case 'invalid-action-code':
          print('The action code is invalid or has already been used.');
          // Handle invalid code (e.g., inform the user)
          break;
        case 'user-disabled':
          print('The user corresponding to the action code has been disabled.');
          // Handle disabled user (e.g., show support contact info)
          break;
        default:
          print('An unexpected error occurred: ${e.message}');
        // Handle other errors
      }
    } catch (e) {
      print('An unknown error occurred: $e');
      // Handle non-Firebase errors
    }
  }
}

class BackendAuthFactory {
  BackendType type;

  BackendAuthFactory({required this.type});

  IAuthRepository getRepository() {
    switch (type) {
      case BackendType.firestore:
        return FirestoreAuthRepository();
    }
  }
}

enum BackendType { firestore }

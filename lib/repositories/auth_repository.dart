import 'package:firebase_auth/firebase_auth.dart';

import 'package:meet_christ/models/user_credentails.dart';
import 'package:uuid/uuid.dart';

abstract class IAuthRepository {
  Future<User> loginWithUserCredentials(UserCredentials userCredentials);
  Future<User?> signupWithUserCredentials(UserCredentials userCredentials);
  Future<void> checkActionCode(String actionCode);
  Future<User> signInAnonymously();
  Future<void> logout();
  Future<bool> emailIsAvailable(String email);
  Future<bool> updatePassword(
    String email,
    String oldPassword,
    String newPassword,
  );
}

class AuthRepository implements IAuthRepository {
  @override
  Future<User> loginWithUserCredentials(UserCredentials userCredentials) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      final UserCredential userCredential = await auth
          .signInWithEmailAndPassword(
            email: userCredentials.email,
            password: userCredentials.password,
          );
      final user = userCredential.user;
      await user?.reload();
      if (user != null && user.emailVerified) {
        print("Email verified");
      } else {
        print("Email not verified");
      }
      print(userCredential.toString());
      if (userCredential.user?.emailVerified == false) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Email not verified',
        );
      }
      if (userCredential.user != null) {
        return userCredential.user!;
      }
      throw FirebaseAuthException(code: 'no-login', message: 'could not login');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-not-verified') {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'verify your email before login',
        );
      } else if (e.code == 'user-not-found') {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'could not login',
        );
      } else if (e.code == 'wrong-password') {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'could not login',
        );
      } else if (e.code == 'invalid-credential') {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'could not login',
        );
      }
    } catch (e) {
      throw FirebaseAuthException(code: 'no-login', message: 'could not login');
    }
    throw FirebaseAuthException(code: 'no-login', message: 'could not login');
  }

  @override
  Future<User> signInAnonymously() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      var authUser = FirebaseAuth.instance.currentUser;

      if (authUser != null) {
        return authUser;
      } else {
        var crendetials = await auth.signInAnonymously();
        if (crendetials.user != null) {
          return crendetials.user!;
        }
      }
    } catch (e) {
      throw FirebaseAuthException(
        code: 'no-sign-in-anonym',
        message: 'could not sign in anonymously',
      );
    }

    throw FirebaseAuthException(
      code: 'no-sign-in-anonym',
      message: 'could not sign in anonymously',
    );
  }

  @override
  Future<User> signupWithUserCredentials(
    UserCredentials userCredentials,
  ) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    auth.authStateChanges();
    try {
      final UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(
            email: userCredentials.email.trim(),
            password: userCredentials.password.trim(),
          );
      await userCredential.user?.sendEmailVerification();
      User? user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'unknown-error',
          message: 'User is null after signup',
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else {
        errorMessage = 'Signup failed: ${e.message}';
      }
      throw FirebaseAuthException(code: e.code, message: errorMessage);
    } catch (e) {
      throw Exception('Signup failed: $e');
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
      await FirebaseAuth.instance.checkActionCode(actionCode);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'expired-action-code':
          // print('The action code has expired.');
          // Handle expired code (e.g., prompt the user to request a new one)
          break;
        case 'invalid-action-code':
          //print('The action code is invalid or has already been used.');
          // Handle invalid code (e.g., inform the user)
          break;
        case 'user-disabled':
          //print('The user corresponding to the action code has been disabled.');
          // Handle disabled user (e.g., show support contact info)
          break;
        default:
        // print('An unexpected error occurred: ${e.message}');
        // Handle other errors
      }
    } catch (e) {
      //print('An unknown error occurred: $e');
      // Handle non-Firebase errors
    }
  }

  @override
  Future<bool> emailIsAvailable(String email) async {
    String password = "thisIsFakePassword123!${Uuid().v4()}";
    try {
      var credentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseAuth.instance.currentUser?.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return false;
      }
      if (e.code == 'wrong-password') {
        return false;
      }
    } on Exception catch (e) {
      return false;
    }
    return false;
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      print('Error sending password reset email: ${e.message}');
      return false;
    } catch (e) {
      print('Unknown error: $e');
      return false;
    }
  }

  @override
  Future<bool> updatePassword(
    String email,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No user currently signed in.',
        );
      }

      // Reauthenticate user with old password
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return true; // Password updated successfully
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors here if needed
      print('Error during password update: ${e.message}');
      return false;
    } catch (e) {
      print('Unknown error: $e');
      return false;
    }
  }

}

class BackendAuthFactory {
  BackendType type;

  BackendAuthFactory({required this.type});

  IAuthRepository getRepository() {
    switch (type) {
      case BackendType.firestore:
        return AuthRepository();
    }
  }
}

enum BackendType { firestore }

class AuthUser {
  User? user;
  String password;

  AuthUser({required this.password, required this.user});
}


/*


class AuthRepository {
  User? _cachedUser;

  Future<User?> getSavedUser() async {
    // load from local storage (simplified)
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email != null) {
      return User(email: email);
    }
    return null;
  }

  Future<void> persistUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', user.email);
    _cachedUser = user;
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    _cachedUser = null;
  }
}


*/
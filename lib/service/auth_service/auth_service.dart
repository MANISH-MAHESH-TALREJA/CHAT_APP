import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_chat_app/model/user_model.dart';
import 'package:flutter_web_chat_app/utils/app.dart';
import 'package:flutter_web_chat_app/utils/app_state.dart';
import 'package:flutter_web_chat_app/utils/exception.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class AuthService {
  Future<void> signUp(UserModel userModel) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email!,
        password: userModel.password!,
      );
      userModel.uid = userCredential.user!.uid;
      await firebaseAuth.currentUser!.updateDisplayName(userModel.name);
      await firebaseAuth.currentUser!.updatePhotoURL(userModel.profilePicture);
      await userService.createUser(userModel);
    } catch (e) {
      handleException(e);
      rethrow;
    }
  }

  Future<void> signIn(UserModel userModel) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: userModel.email!,
        password: userModel.password!,
      );
      await userService.getUser(userCredential.user!.uid).then((value){
        appState.currentUser = UserModel.fromMap(value.data() as Map<String, dynamic>);
      });
    } catch (e) {
      handleException(e);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      handleException(e);
      rethrow;
    }
  }

  bool isUserLoggedIn() {
    return firebaseAuth.currentUser != null;
  }

  Future<void> forgotPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      handleException(e);
      rethrow;
    }
  }
}

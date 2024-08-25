import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/model/user_model.dart';
import 'package:untitled/utils/utils.dart';
import 'package:untitled/views/authentication/login_page.dart';
import 'package:untitled/views/home2_page.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  User? _user;
  String? _userId;
  String get userId => _userId!;
  String? _email;
  String get email => _email!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  AuthProvider() {
    checkSigned();
  }

  Future<void> checkSigned() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    if (_isSignedIn) {
      _user = _firebaseAuth.currentUser;
      _email = _user?.email;
      _userId = _user!.uid;
    }
    notifyListeners();
  }

  Future<void> _saveSignInStatus(bool isSignedIn) async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.setBool("is_signedin", isSignedIn);
    _isSignedIn = isSignedIn;
    if (!isSignedIn) {
      _user = null;
      _email = null;
    }
    notifyListeners();
  }

  Future<void> signInWithEmail(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      CustomSnackBar.show(context, "Signed in successfully");
      _user = userCredential.user;
      _email = _user?.email;
      if (_user != null) {
        await _saveSignInStatus(true);
        UserModel? userModel = await getUserByUid(_user!.email);
        if (userModel != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage2(userModel: userModel),
            ),
          );
        } else {
          print('UserModel not found for user ${_user!.email}');
          CustomSnackBar.show(context, "User not found");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        CustomSnackBar.show(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        CustomSnackBar.show(context, 'Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        print('Invalid email address format.');
        CustomSnackBar.show(context, 'Invalid email address format.');
      } else {
        print('Error signing in: ${e.message}');
        CustomSnackBar.show(context, 'Error signing in: ${e.message}');
      }
    } catch (e) {
      print('Error signing in: $e');
      CustomSnackBar.show(context, 'Error signing in: $e');
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _firebaseAuth.signOut();
      await _saveSignInStatus(false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LogInPage(),
        ),
      );
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  Future<bool> checkExistingUser(String email) async {
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection("users")
        .where("email", isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> updateUserProfile(UserModel userModel) async {
    try {
      await _firebaseFirestore.collection('users').doc(userModel.uid).update({
        'name': userModel.name,
        'email': userModel.email,
        'birthday': userModel.birthday,
        'address': userModel.address,
        'photo': userModel.photo,
        'phonenumber': userModel.phonenumber,
      });
      print('User profile updated successfully');
    } catch (error) {
      print('Error updating user profile: $error');
      throw error;
    }
  }

  Future<UserModel?> getUserByUid(String? email) async {
    try {
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromMap(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        print("User not found");
        return null;
      }
    } catch (error) {
      print('Error getting user by UID: $error');
      return null;
    }
  }
}

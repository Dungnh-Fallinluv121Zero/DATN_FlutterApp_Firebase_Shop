import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/utils/utils.dart';

class UserModel {
  final String name;
  final String email;
  final String photo;
  final String uid;
  final String createtime;
  final String birthday;
  final String address;
  final String phonenumber;
  late bool verifyMail;
  late bool verifyPhone;

  UserModel({
    required this.name,
    required this.email,
    required this.photo,
    required this.uid,
    required this.createtime,
    required this.birthday,
    required this.address,
    required this.phonenumber,
    this.verifyMail = false,
    this.verifyPhone = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> userInfoMap) {
    return UserModel(
      name: userInfoMap['name'] ?? '',
      email: userInfoMap['email'] ?? '',
      photo: userInfoMap['photo'] ?? '',
      uid: userInfoMap['uid'] ?? '',
      createtime: userInfoMap['createtime'] ?? '',
      birthday: userInfoMap['birthday'] ?? '',
      address: userInfoMap['address'] ?? '',
      phonenumber: userInfoMap['phonenumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "photo": photo,
      "uid": uid,
      "createtime": createtime,
      "birthday": birthday,
      "address": address,
      "phonenumber": phonenumber,
    };
  }

  // Phương thức để lấy dữ liệu người dùng từ Firestore bằng cách so sánh UID
  static Future<UserModel?> getUserByUid(
      BuildContext context, String? email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(
              1) // Giới hạn số lượng kết quả trả về (trong trường hợp UID là duy nhất)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Trả về UserModel từ dữ liệu tài liệu đầu tiên trong kết quả truy vấn
        return UserModel.fromMap(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        CustomSnackBar.show(context, "User not found");
        return null;
      }
    } catch (error) {
      print('Error getting user by UID: $error');
      return null;
    }
  }
}

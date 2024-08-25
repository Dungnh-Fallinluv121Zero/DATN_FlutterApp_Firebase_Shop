import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:untitled/model/user_model.dart';
import 'package:untitled/provider/auth_provider.dart';
import 'package:untitled/utils/utils.dart';
import 'package:untitled/views/user/account_page.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel userModel;

  const EditProfilePage({Key? key, required this.userModel}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _birthdayController;
  late TextEditingController _addressController;

  DateTime? _selectedDate;
  late String oldImageUrl = widget.userModel.photo;
  late String imageUrl = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userModel.name);
    _emailController = TextEditingController(text: widget.userModel.email);
    _birthdayController =
        TextEditingController(text: widget.userModel.birthday);
    _addressController = TextEditingController(text: widget.userModel.address);
    _selectedDate = DateTime.now();
    // Khởi tạo ngày đã chọn bằng ngày hiện tại
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _uploadImageAndSetUrl() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return;
    }

    String uniqueFilename = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImage = referenceRoot.child('image');
    Reference referenceImageToUpload = referenceDirImage.child(uniqueFilename);

    try {
      // Tải ảnh lên Firebase Storage
      await referenceImageToUpload.putFile(File(file.path));

      // Lấy URL của ảnh đã tải lên
      String newImageUrl = await referenceImageToUpload.getDownloadURL();

      // Cập nhật URL mới và hiển thị ảnh lên giao diện

      CustomSnackBar.show(context, imageUrl);
      setState(() {
        imageUrl = newImageUrl;
      });

      // Nếu có ảnh cũ, xoá nó
      if (oldImageUrl.isNotEmpty) {
        Reference oldImageRef =
            FirebaseStorage.instance.refFromURL(oldImageUrl);
        await oldImageRef.delete();
      }
    } catch (e) {
      CustomSnackBar.show(context, e.toString());
      print(e.toString());
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate!, // Ngày ban đầu là ngày đã chọn trước đó hoặc ngày hiện tại
      firstDate: DateTime(1900), // Ngày đầu tiên có thể chọn (ví dụ: năm 1900)
      lastDate: DateTime.now(), // Ngày cuối cùng có thể chọn là ngày hiện tại
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(
            _selectedDate!); // Hiển thị ngày đã chọn trong TextFormField
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(CupertinoIcons.clear),
                ),
                title: Text(
                  'Edit Profile',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Stack(
                children: [
                  oldImageUrl == ""
                      ? const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          radius: 50,
                          child: Icon(
                            Icons.account_circle,
                            size: 50,
                            color: Colors.white,
                          ))
                      : CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(oldImageUrl),
                        ),
                  Positioned(
                    bottom: -10,
                    left: 60,
                    child: IconButton(
                      onPressed: _uploadImageAndSetUrl,
                      icon: const Icon(Icons.add_a_photo_rounded),
                      color: Colors.purple,
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Họ tên'),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _birthdayController,
                      decoration: InputDecoration(labelText: 'Ngày sinh'),
                      onTap: () {
                        _selectDate(
                            context); // Gọi hàm chọn ngày khi người dùng nhấn vào trường "birthday"
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Địa chỉ'),
                    ),
                    SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: () async {
                        // Lấy thông tin mới từ các trường nhập liệu
                        String newName = _nameController.text;
                        String newEmail = _emailController.text;
                        String newBirthday = _birthdayController.text;
                        String newAddress = _addressController.text;
                        String newImage = '';
                        String newPhone = '';
                        if (imageUrl.isEmpty) {
                          CustomSnackBar.show(context, "You can upload image");
                        } else {
                          newImage = imageUrl;
                        }

                        // Tạo một UserModel mới với thông tin đã được cập nhật
                        UserModel updatedUser = UserModel(
                          uid: widget.userModel.uid,
                          name: newName,
                          email: newEmail,
                          photo: newImage,
                          createtime: widget.userModel.createtime,
                          birthday: newBirthday,
                          address: newAddress,
                          phonenumber: newPhone,
                          verifyMail: widget.userModel.verifyMail,
                          verifyPhone: widget.userModel.verifyPhone,
                        );
                        try {
                          await Provider.of<AuthProvider>(context,
                                  listen: false)
                              .updateUserProfile(updatedUser);
                          if (mounted) {
                            CustomSnackBar.show(
                                context, "User profile updated successfully");
                          }
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AccountPage(userModel: updatedUser),
                              ),
                              (route) => false);
                        } catch (error) {
                          print('Error updating user profile: $error');
                        }
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

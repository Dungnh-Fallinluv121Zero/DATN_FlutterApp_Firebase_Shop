import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/model/address_model.dart';
import 'package:untitled/views/user/address/user_address_page.dart';
import 'package:untitled/widgets/button_custom.dart';

class AddNewAddressPage extends StatefulWidget {
  final String userId;
  final AddressModel? address;

  const AddNewAddressPage({
    Key? key,
    required this.userId,
    this.address,
  }) : super(key: key);

  @override
  _AddNewAddressPageState createState() => _AddNewAddressPageState();
}

class _AddNewAddressPageState extends State<AddNewAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _nameController.text = widget.address!.name;
      _phoneController.text = widget.address!.phone;
      _addressController.text = widget.address!.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.arrow_left_circle),
        ),
        title: Text(
          widget.address == null ? 'Add New Address' : 'Edit Address',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(CupertinoIcons.person),
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(CupertinoIcons.phone),
                    labelText: 'Phone Number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(CupertinoIcons.location),
                    labelText: 'Address',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ButtonCustomW(
                  text: "Save Address",
                  onPressed: _saveAddress,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final addressCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId) // Sử dụng widget.userId để lấy userId
            .collection('addresses');

        if (widget.address != null) {
          // Update existing address
          await addressCollection.doc(widget.address!.id).update({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address updated successfully')),
          );
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => UserAddressPage(
                  userId: widget.userId,
                ),
              ),
              (route) => false);
          // Trả về true nếu địa chỉ đã được cập nhật
        } else {
          // Add new address
          await addressCollection.add({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
            'created_at': FieldValue.serverTimestamp(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address saved successfully')),
          );
          // Trả về true nếu địa chỉ mới đã được

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => UserAddressPage(
                  userId: widget.userId,
                ),
              ),
              (route) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not signed in')),
        );
      }
    }
  }
}

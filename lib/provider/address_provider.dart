import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/model/address_model.dart';

class AddressProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId;
  bool _isDisposed = false;

  AddressProvider({required this.userId});

  List<AddressModel> _addresses = [];
  int? _selectedAddressIndex;

  List<AddressModel> get addresses => _addresses;
  int? get selectedAddressIndex => _selectedAddressIndex;

  Future<void> init(String userId) async {
    this.userId = userId;
    if (userId.isNotEmpty) {
      await loadAddresses();
    }
  }

  Future<void> loadAddresses() async {
    if (userId.isEmpty) throw Exception("User ID is empty");
    try {
      var addressSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();
      _addresses = addressSnapshot.docs
          .map((doc) => AddressModel.fromMap(doc.data()))
          .toList();

      if (!_isDisposed) notifyListeners();
    } catch (e) {
      print('Error fetching addresses: $e');
    }
  }

  Future<void> addAddress(AddressModel address) async {
    if (userId.isEmpty) throw Exception("User ID is empty");
    try {
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .add(address.toMap());
      address.id = docRef.id;
      _addresses.add(address);
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      print('Error adding address: $e');
    }
  }

  Future<void> updateAddress(AddressModel address) async {
    if (userId.isEmpty) throw Exception("User ID is empty");
    if (address.id == null) throw Exception("Address ID is null");
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(address.id)
          .update(address.toMap());
      int index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
        if (!_isDisposed) notifyListeners();
      }
    } catch (e) {
      print('Error updating address: $e');
    }
  }

  Future<void> removeAddress(String addressId) async {
    if (userId.isEmpty) throw Exception("User ID is empty");
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete();
      _addresses.removeWhere((address) => address.id == addressId);
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      print('Error removing address: $e');
    }
  }

  void selectAddress(int index, bool isSelected) {
    _selectedAddressIndex = isSelected ? index : null;
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

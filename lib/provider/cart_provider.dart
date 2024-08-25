import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/model/book_model.dart';
import 'package:untitled/model/cart_model.dart';
import 'package:collection/collection.dart';
import 'package:synchronized/synchronized.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId;
  bool _isDisposed = false;
  final Lock _lock = Lock();

  CartProvider({required this.userId});

  List<CartModel> _cart = [];
  List<bool> _checkedList = [];
  final double _shoppingCost = 10.0;

  double get shoppingCost => _shoppingCost;
  double get totalPrice => getTotalPrice();
  double get payPrice => getPayPrice();
  List<CartModel> get cart => _cart;
  List<bool> get checkedList => _checkedList;

  Future<void> init(String userId) async {
    this.userId = userId;
    if (userId.isNotEmpty) {
      await loadCart();
    }
  }

  Future<void> updateCartInFirestore(CartModel? cartItem) async {
    if (userId.isEmpty) throw Exception("User ID is empty");
    if (cartItem != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItem.bookId)
          .set(cartItem.toMap());
    }
  }

  Future<void> removeCartItemFromFirestore(String bookId) async {
    if (userId.isEmpty) throw Exception("User ID is empty");
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(bookId)
        .delete();
  }

  Future<void> addToCart(BookModel b) async {
    if (userId.isEmpty) throw Exception("User ID is empty");

    // Sử dụng biến nullable cho cartItem
    CartModel? cartItem = _cart.firstWhereOrNull(
          (element) => element.bookId == b.bookId,
    );

    // Khóa toàn bộ đoạn thêm sản phẩm để tránh vấn đề khi nhấn nhiều lần
    await _lock.synchronized(() async {
      if (cartItem == null) {
        // Tạo mới CartModel nếu không tìm thấy sản phẩm trong giỏ hàng
        cartItem = CartModel(
          bookId: b.bookId,
          title: b.title,
          price: (b.price).toDouble(),
          image: b.image,
          quantity: 1,
          book: b,
        );
        _cart.add(cartItem!);
        _checkedList.add(false);
      } else {

        cartItem?.quantity++;
      }


      await updateCartInFirestore(cartItem);
      if (!_isDisposed) notifyListeners();
    });
  }

  Future<void> deleteItem(String id) async {
    if (userId.isEmpty) throw Exception("User ID is empty");

    _cart.removeWhere((element) => element.bookId == id);
    _checkedList = List<bool>.filled(_cart.length, false);

    await removeCartItemFromFirestore(id);

    if (!_isDisposed) notifyListeners();
  }

  Future<void> incrementQty(String id) async {
    if (userId.isEmpty) throw Exception("User ID is empty");
    var item = _cart.firstWhere((element) => element.bookId == id);
    item.quantity++;
    if (!_isDisposed) notifyListeners();
    await updateCartInFirestore(item);
  }

  Future<void> decrementQty(String id) async {
    if (userId.isEmpty) throw Exception("User ID is empty");
    var item = _cart.firstWhere((element) => element.bookId == id);

    if (item.quantity > 1) {
      item.quantity--;
    } else {
      int index = _cart.indexWhere((element) => element.bookId == id);
      if (index != -1) {
        _cart.removeAt(index);
        _checkedList.removeAt(index);
      }
      await removeCartItemFromFirestore(item.bookId);
    }
    if (!_isDisposed) notifyListeners();
    await updateCartInFirestore(item);
  }


  double getTotalPrice() {
    double total = _cart.fold(0, (total, item) => total + (item.book?.price ?? 0) * item.quantity);
    return double.parse(total.toStringAsFixed(2));
  }
  double getPayPrice() {
    double payPrice = (getTotalPrice()+_shoppingCost)*0.9;
    return double.parse(payPrice.toStringAsFixed(2));
  }
  Future<void> loadCart() async {
    if (userId.isEmpty) throw Exception("User ID is empty");
    var cartSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();
    _cart = cartSnapshot.docs.map((doc) => CartModel.fromMap(doc.data())).toList();
    _checkedList = List<bool>.filled(_cart.length, false); // Initialize checked list
    if (!_isDisposed) notifyListeners();
  }

  void toggleChecked(int index) {
    _checkedList[index] = !_checkedList[index];
    if (!_isDisposed) notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _checkedList.clear();
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

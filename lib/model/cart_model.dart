import 'package:untitled/model/book_model.dart';

class CartModel {
  final String bookId;
  final String title;
  final double price;
  final String image;
  int quantity;
  final BookModel? book;

  CartModel({
    required this.bookId,
    required this.title,
    required this.price,
    required this.image,
    this.quantity = 1,
    this.book,
  });

  factory CartModel.fromSimpleMap(Map<String, dynamic> map) {
    return CartModel(
      bookId: map['bookId'],
      title: map['title'],
      price: map['price'],
      image: map['image'],
    );
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      bookId: map['bookId'],
      title: map['title'],
      price: (map['price'] as num).toDouble(),
      image: map['image'],
      quantity: map['quantity'] ?? 1,
      book: map['book'] != null ? BookModel.fromMap(map['book']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
      'book': book?.toMap(),
    };
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/model/book_model.dart';
import 'package:untitled/views/product/searchBook_page.dart';

class BookProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<BookModel> _books = []; // Danh sách sách

  // Hàm để lấy dữ liệu sách từ Firestore
  Future<void> fetchBooks() async {
    try {
      QuerySnapshot<Map<String, dynamic>> bookSnapshot =
          await _firestore.collection('books').get();

      // Xóa dữ liệu cũ trước khi cập nhật mới
      _books.clear();

      // Lặp qua các documents trong collection và thêm vào danh sách sách
      bookSnapshot.docs.forEach((doc) {
        BookModel book = BookModel.fromMap(doc.data());
        _books.add(book);
      });

      notifyListeners(); // Thông báo cho các widget đã đăng ký nghe thay đổi
    } catch (error) {
      print('Error fetching books: $error');
    }
  }

  // Getter để truy cập danh sách sách từ bên ngoài
  List<BookModel> get books {
    return [
      ..._books
    ]; // Trả về một bản sao của danh sách sách để đảm bảo an toàn dữ liệu
  }

  // Hàm để thêm sách mới vào Firestore
  Future<void> addBook(BookModel book) async {
    try {
      await _firestore.collection('books').add(book.toMap());
      fetchBooks(); // Cập nhật lại danh sách sách sau khi thêm
    } catch (error) {
      print('Error adding book: $error');
    }
  }

  // Hàm để cập nhật thông tin sách trong Firestore
  Future<void> updateBook(String bookId, BookModel newBook) async {
    try {
      await _firestore.collection('books').doc(bookId).update(newBook.toMap());
      fetchBooks(); // Cập nhật lại danh sách sách sau khi cập nhật
    } catch (error) {
      print('Error updating book: $error');
    }
  }

  // Hàm để xóa sách khỏi Firestore
  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
      fetchBooks(); // Cập nhật lại danh sách sách sau khi xóa
    } catch (error) {
      print('Error deleting book: $error');
    }
  }

  // Hàm để lấy dữ liệu sách qua ID
  Future<BookModel?> getBookById(String bookId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('products').doc(bookId).get();

      if (doc.exists) {
        return BookModel.fromMap(doc.data()!);
      } else {
        print('Book not found');
        return null;
      }
    } catch (error) {
      print('Error getting book: $error');
      return null;
    }
  }

  // tìm kiếm
  Future<void> searchBooks(SearchType searchType, String searchTerm) async {
    try {
      String fieldName =
          searchType == SearchType.author ? 'author' : 'publisher';

      QuerySnapshot<Map<String, dynamic>> bookSnapshot = await _firestore
          .collection('books')
          .where(fieldName, isEqualTo: searchTerm)
          .get();

      _books.clear();

      bookSnapshot.docs.forEach((doc) {
        BookModel book = BookModel.fromMap(doc.data());
        _books.add(book);
      });

      notifyListeners();
    } catch (error) {
      print('Error searching books: $error');
    }
  }
}

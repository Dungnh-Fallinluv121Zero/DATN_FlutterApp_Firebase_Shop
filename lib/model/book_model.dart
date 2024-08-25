class BookModel {
  final String bookId;
  final String title;
  final String author;
  final String description;
  final String image;
  final double price;
  final int stockQuantity;
  final int publicationYear;
  final String publisher; // Trường năm xuất bản

  BookModel({
    required this.bookId,
    required this.title,
    required this.author,
    required this.description,
    required this.image,
    required this.price,
    required this.stockQuantity,
    required this.publicationYear,
    required this.publisher,
  });

  factory BookModel.fromMap(Map<String, dynamic> bookInfoMap) {
    return BookModel(
      bookId: bookInfoMap['id'] ?? '',
      title: bookInfoMap['title'] ?? '',
      author: bookInfoMap['author'] ?? '',
      description: bookInfoMap['description'] ?? '',
      image: bookInfoMap['image'] ?? '',
      price: (bookInfoMap['price'] as num).toDouble(),
      stockQuantity: bookInfoMap['stockQuantity'] ?? 0,
      publicationYear: bookInfoMap['publicationYear'] ?? 0,
      publisher: bookInfoMap['publisher'] ?? 0,
    );
  }

  BookModel copyWith(
      {String? bookId,
      String? title,
      String? author,
      String? image,
      String? description,
      String? publisher,
      double? price,
      int? stockQuantity,
      int? publicationYear}) {
    return BookModel(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      image: image ?? this.image,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      publicationYear: publicationYear ?? this.publicationYear,
      publisher: publisher ?? this.publisher,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": bookId,
      "title": title,
      "author": author,
      "description": description,
      "image": image,
      "price": price,
      "stockQuantity": stockQuantity,
      "publicationYear": publicationYear,
      "publisher": publisher,
    };
  }
}

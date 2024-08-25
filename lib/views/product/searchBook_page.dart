import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/model/book_model.dart';
import 'package:untitled/provider/book_provider.dart';
import 'package:untitled/views/product/item_page.dart';

enum SearchType {
  author,
  publisher,
}

class SearchBooksPage extends StatefulWidget {
  final String searchTerm;
  const SearchBooksPage({Key? key, required this.searchTerm}) : super(key: key);
  get _searchTerm => searchTerm;

  @override
  _SearchBooksPageState createState() => _SearchBooksPageState();
}

class _SearchBooksPageState extends State<SearchBooksPage> {
  TextEditingController _searchController = TextEditingController();
  SearchType _searchType = SearchType.author;

  get _searchTerm => widget.searchTerm;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _searchTerm);
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    String searchTerm = _searchController.text.trim();
    Provider.of<BookProvider>(context, listen: false)
        .searchBooks(_searchType, searchTerm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Books'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Enter ${_searchType == SearchType.author ? 'author' : 'publisher'} name',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Radio(
                value: SearchType.author,
                groupValue: _searchType,
                onChanged: (SearchType? value) {
                  setState(() {
                    _searchType = value!;
                    _onSearch(); // Gọi tìm kiếm lại khi thay đổi loại tìm kiếm
                  });
                },
              ),
              Text('Author'),
              Radio(
                value: SearchType.publisher,
                groupValue: _searchType,
                onChanged: (SearchType? value) {
                  setState(() {
                    _searchType = value!;
                    _onSearch(); // Gọi tìm kiếm lại khi thay đổi loại tìm kiếm
                  });
                },
              ),
              Text('Publisher'),
            ],
          ),
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                if (bookProvider.books.isEmpty) {
                  return Center(child: Text('No books found.'));
                }
                return ListView.builder(
                  itemCount: bookProvider.books.length,
                  itemBuilder: (context, index) {
                    BookModel book = bookProvider.books[index];
                    return ListTile(
                      leading: Image.network(book.image),
                      title: Text(book.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Author: ${book.author}'),
                          Text('Publisher: ${book.publisher}'),
                          Text('Price: \$${book.price.toStringAsFixed(2)}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemPage(idItem: book.bookId),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

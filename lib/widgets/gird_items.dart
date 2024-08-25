import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/model/book_model.dart';
import 'package:untitled/provider/cart_provider.dart';
import 'package:untitled/utils/utils.dart';
import 'package:untitled/views/product/item_page.dart';

class GridItems extends StatefulWidget {
  final String searchQuery;

  const GridItems({Key? key, required this.searchQuery}) : super(key: key);

  @override
  State<GridItems> createState() => _GridItemsState();
}

class _GridItemsState extends State<GridItems> {
  late Future<List<Map<String, dynamic>>> gridData;

  @override
  void initState() {
    super.initState();
    gridData = fetchDataFromFirestore(); // Lấy dữ liệu từ Firestore
  }

  Future<List<Map<String, dynamic>>> fetchDataFromFirestore() async {
    // Truy vấn Firestore để lấy dữ liệu
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('products').get();

    // Chuyển đổi dữ liệu từ QuerySnapshot thành List<Map<String, dynamic>>
    List<Map<String, dynamic>> data = querySnapshot.docs.map((doc) {
      double price = doc['price'].toDouble();
      return {
        'title': doc['title'],
        'price': price,
        'image': doc['image'],
        'id': doc['id'],
      };
    }).toList();

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: gridData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        List<Map<String, dynamic>> gridMap = snapshot.data!;


        if (widget.searchQuery.isNotEmpty) {
          gridMap = gridMap.where((item) {
            return item['title']
                .toLowerCase()
                .contains(widget.searchQuery.toLowerCase());
          }).toList();
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio:
                0.75, // Tỷ lệ giữa chiều cao và chiều rộng của item
          ),
          itemCount: gridMap.length,
          itemBuilder: (context, index) {
            final book = gridMap[index];

            //final cartItem = CartModel.fromSimpleMap(product);

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemPage(
                      idItem: book['id'],
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                            ),
                            child: AspectRatio(
                              aspectRatio: 10 / 9,
                              child: Image.network(
                                book['image'],
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.red,
                          ),
                          child: const Text(
                            " 30% ",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book['title'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "\$99",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black26,
                                        decoration: TextDecoration.lineThrough),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "\$${book['price']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () async {
                                  final cartProvider =
                                      Provider.of<CartProvider>(context,
                                          listen: false);
                                  print(cartProvider.userId);
                                  try {
                                    await cartProvider.addToCart(BookModel(
                                      bookId: book['id'],
                                      title: book['title'],
                                      author:
                                          '',
                                      description:
                                          '',
                                      image: book['image'],
                                      price: (book['price']),
                                      stockQuantity:
                                          0,
                                      publicationYear:
                                          0,
                                      publisher:
                                          '',
                                    ));
                                    CustomSnackBar.show(
                                        context, "Add to cart successfully");
                                  } catch (error) {
                                    CustomSnackBar.show(context,
                                        "Failed to add to cart: $error");
                                  }
                                },
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.cart_fill_badge_plus,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:untitled/model/book_model.dart';
import 'package:untitled/provider/book_provider.dart';
import 'package:untitled/provider/cart_provider.dart';
import 'package:untitled/utils/utils.dart';
import 'package:untitled/views/product/searchBook_page.dart';
import 'package:untitled/widgets/image_slider.dart';

class ItemPage extends StatelessWidget {
  final String idItem;
  final ValueNotifier<int> quantityNotifier = ValueNotifier<int>(1);

  ItemPage({Key? key, required this.idItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sWidth = MediaQuery.of(context).size.width;
    final sHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<BookModel?>(
      future:
          Provider.of<BookProvider>(context, listen: false).getBookById(idItem),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Book not found'));
        } else {
          BookModel book = snapshot.data!;
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      height: sHeight / 2,
                      width: sWidth,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Stack(
                        children: [
                          const ImageSlider(), // Replace with your ImageSlider widget
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(
                                      CupertinoIcons.arrow_left_circle),
                                ),
                                InkWell(
                                  onTap: () {
                                    CustomSnackBar.show(context, "Share");
                                  },
                                  child: const Icon(Icons.share_outlined),
                                ),
                              ],
                            ),
                          ), // Left and Right icons
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  RatingBar.builder(
                                    initialRating: 3.5,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 25,
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {},
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text("(450)"),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "\$${book.price}",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text(
                                    "\$240",
                                    style: TextStyle(
                                      color: Colors.black,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: Colors.red,
                                    ),
                                    child: const Text(
                                      " Sale 30% ",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ListTileW(
                                title: "Author: ${book.author}",
                                icon: Icons.supervisor_account_sharp,
                                onPress: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchBooksPage(
                                        searchTerm: book.author,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ListTileW(
                                title: "Publisher: ${book.publisher}",
                                icon: Icons.pin_drop_outlined,
                                onPress: () {},
                              ),
                              ListTileW(
                                title: "Description:",
                                icon: Icons.wrap_text_outlined,
                                onPress: () {},
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 25,
                                ),
                                child: Text(
                                  book.description,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNav(
              sHeight: sHeight,
              book: book,
              quantityNotifier: quantityNotifier,
            ),
          );
        }
      },
    );
  }
}

class BottomNav extends StatelessWidget {
  const BottomNav({
    Key? key,
    required this.sHeight,
    required this.book,
    required this.quantityNotifier,
  }) : super(key: key);

  final double sHeight;
  final BookModel book;
  final ValueNotifier<int> quantityNotifier;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: sHeight / 12,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ButtonCustom(
              text: 'Add To Cart',
              onPressed: () async {
                final cartProvider =
                    Provider.of<CartProvider>(context, listen: false);
                try {
                  print(cartProvider.userId);
                  await cartProvider.addToCart(BookModel(
                    bookId: book.bookId,
                    title: book.title,
                    author: '',
                    description: '',
                    image: book.image,
                    price: book.price,
                    stockQuantity: 0,
                    publicationYear: 0,
                    publisher: '',
                  ));
                  CustomSnackBar.show(context, "Add to cart successfully");
                } catch (error) {
                  CustomSnackBar.show(context, "Failed to add to cart: $error");
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ButtonCustom(
              text: 'Buy Now',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => CustomBottomSheet(
                    book: book,
                    quantityNotifier: quantityNotifier,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ListTileW extends StatelessWidget {
  const ListTileW({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onPress,
    );
  }
}

class ButtonCustom extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const ButtonCustom({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.red[400],
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CustomBottomSheet extends StatelessWidget {
  final BookModel book;
  final ValueNotifier<int> quantityNotifier;

  const CustomBottomSheet({
    Key? key,
    required this.book,
    required this.quantityNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: quantityNotifier,
      builder: (context, quantity, _) {
        double totalPayment = book.price * quantity;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (quantity > 1) {
                            quantityNotifier.value = quantity - 1;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDDADA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            CupertinoIcons.minus,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () {
                          quantityNotifier.value = quantity + 1;
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDDADA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            CupertinoIcons.add,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$$totalPayment',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  // Implement your checkout logic here
                  // This function will be executed when the "Checkout" button is tapped
                  CustomSnackBar.show(context, 'Checkout tapped');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/model/cart_model.dart';
import 'package:untitled/provider/cart_provider.dart';
import 'package:untitled/utils/utils.dart';
import 'package:untitled/views/product/item_page.dart';

class CartPage extends StatefulWidget {
  final String userId;
  const CartPage({Key? key, required this.userId}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<void> _loadCartFuture;

  @override
  void initState() {
    super.initState();
    _loadCartFuture =
        Provider.of<CartProvider>(context, listen: false).loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder(
        future: _loadCartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                if (cartProvider.cart.isEmpty) {
                  return const Center(
                    child: Text('Your cart is empty'),
                  );
                }

                return ListView.builder(
                  itemCount: cartProvider.cart.length,
                  itemBuilder: (context, index) {
                    CartModel cartItem = cartProvider.cart[index];
                    return Dismissible(
                      key: Key(cartItem.bookId),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          cartProvider.deleteItem(cartItem.bookId);
                        });
                        CustomSnackBar.show(context, "${cartItem.title} removed from cart");
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: ListTile(
                        leading: Image.network(cartItem.image),
                        title: Text(cartItem.title),
                        subtitle: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                cartProvider.decrementQty(cartItem.bookId);
                              },
                            ),
                            Text('${cartItem.quantity}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                cartProvider.incrementQty(cartItem.bookId);
                              },
                            ),
                          ],
                        ),
                        trailing:
                            Text('\$${cartItem.price * cartItem.quantity}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ItemPage(idItem: cartItem.bookId),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Discount: ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '10%',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '\$${cartProvider.totalPrice + cartProvider.shoppingCost}',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '\$${cartProvider.payPrice}',
                              //'\$${double.parse({(cartProvider.totalPrice + cartProvider.shoppingCost) * 0.9}.toStringAsFixed(2))}',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: cartProvider.cart.isEmpty
                      ? null
                      : () {
                          CustomSnackBar.show(context, "Your cart is empty");
                          print(cartProvider.userId);
                        },
                  child: Text('Checkout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

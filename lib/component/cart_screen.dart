import 'dart:convert';
import 'package:easy_fooods_delivery/component/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_fooods_delivery/services/cart_service.dart';
import 'package:easy_fooods_delivery/model/cart_item.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartItem>> _cartItemsFuture;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() {
    setState(() {
      _cartItemsFuture = CartService().getCartItems();
    });
  }

  Future<void> _updateCartItem(int foodId, int quantity) async {
    try {
      await CartService().updateCartItem(foodId, quantity);
      _loadCartItems();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _deleteCartItem(int cartItemId) async {
    try {
      await CartService().deleteCartItem(cartItemId);
      _loadCartItems();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  double _calculateTotalPrice(List<CartItem> cartItems) {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<CartItem>>(
              future: _cartItemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Your cart is empty.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                } else {
                  final cartItems = snapshot.data!;
                  return ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(cartItem.imageUrl),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            cartItem.name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price: Tk ${cartItem.price.toStringAsFixed(2)}'),
                              Text(
                                'Total: Tk ${cartItem.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.deepOrange),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.red),
                                onPressed: () {
                                  if (cartItem.quantity > 1) {
                                    _updateCartItem(cartItem.foodId, cartItem.quantity - 1);
                                  } else {
                                    _deleteCartItem(cartItem.id);
                                  }
                                },
                              ),
                              Text(
                                '${cartItem.quantity}',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.green),
                                onPressed: () {
                                  _updateCartItem(cartItem.foodId, cartItem.quantity + 1);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.grey),
                                onPressed: () {
                                  _deleteCartItem(cartItem.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          FutureBuilder<List<CartItem>>(
            future: _cartItemsFuture,
            builder: (context, snapshot) {
              double totalPrice = 0;
              if (snapshot.hasData) {
                totalPrice = _calculateTotalPrice(snapshot.data!);
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Price:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Tk ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CheckoutScreen(totalPrice: totalPrice)),
                        );
                      },
                      child: Text('Proceed to Checkout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

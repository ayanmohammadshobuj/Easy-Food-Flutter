import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalPrice;

  CheckoutScreen({required this.totalPrice});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _restaurantId = "1"; // Static restaurantId for now
  String _paymentMethod = "CREDIT_CARD";
  String _paymentStatus = "PAID";
  String _apartment = "";
  String _street = "";
  String _city = "";
  String _landmark = "";
  String _label = "Home";
  String _phone = "";

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwtToken');

      if (token == null) {
        _showErrorDialog("JWT token not found");
        return;
      }

      final url = Uri.parse('http://localhost:8000/api/order');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "restaurantId": int.parse(_restaurantId),
          "paymentMethod": _paymentMethod,
          "paymentStatus": _paymentStatus,
          "apartment": _apartment,
          "street": _street,
          "city": _city,
          "landmark": _landmark,
          "label": _label,
          "phone": _phone,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final orderResponse = json.decode(response.body);
        _showSuccessDialog("Order placed successfully!");
      } else {
        _showErrorDialog("Failed to place order. Try again.");
      }
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/order_screen');
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showOrderConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Order'),
        content: Text('Do you want to place this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _placeOrder();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Order Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Total Price: Tk ${widget.totalPrice.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: "Apartment"),
                validator: (value) => value!.isEmpty ? "Please enter apartment" : null,
                onSaved: (value) => _apartment = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Street"),
                validator: (value) => value!.isEmpty ? "Please enter street" : null,
                onSaved: (value) => _street = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "City"),
                validator: (value) => value!.isEmpty ? "Please enter city" : null,
                onSaved: (value) => _city = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Landmark"),
                onSaved: (value) => _landmark = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Please enter phone number" : null,
                onSaved: (value) => _phone = value!,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                items: [
                  DropdownMenuItem(value: "CREDIT_CARD", child: Text("Credit Card")),
                  DropdownMenuItem(value: "CASH_ON_DELIVERY", child: Text("Cash on Delivery")),
                ],
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
                decoration: InputDecoration(labelText: "Payment Method"),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showOrderConfirmationDialog,
                child: Text('Confirm Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
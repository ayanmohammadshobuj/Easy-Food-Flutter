// lib/component/order_screen.dart
import 'package:easy_fooods_delivery/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../services/order_service.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future<List<Order>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = OrderService().getOrders();
  }

  void _showOrderDetailsDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order #${order.id} Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${order.customerName}'),
              Text('Status: ${order.orderStatus}'),
              Text('Total: \$${order.totalPrice.toStringAsFixed(2)}'),
              Text('Date: ${order.createdAt.toLocal()}'),
              Text('Items:'),
              ...order.orderItems.map((item) => Text('${item.foodName} x${item.quantity}')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () => _printOrderInvoice(order),
              child: Text('Print Invoice'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _printOrderInvoice(Order order) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Order #${order.id} Invoice', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Text('Customer: ${order.customerName}'),
              pw.Text('Status: ${order.orderStatus}'),
              pw.Text('Total: \$${order.totalPrice.toStringAsFixed(2)}'),
              pw.Text('Date: ${order.createdAt.toLocal()}'),
              pw.SizedBox(height: 16),
              pw.Text('Items:'),
              ...order.orderItems.map((item) => pw.Text('${item.foodName} x${item.quantity}')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: FutureBuilder<List<Order>>(
        future: _orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Order #${order.id} - ${order.orderStatus}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total: \$${order.totalPrice.toStringAsFixed(2)}'),
                      Text('Date: ${order.createdAt.toLocal()}'),
                      Text('Items: ${order.orderItems.length}'),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => _showOrderDetailsDialog(order),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
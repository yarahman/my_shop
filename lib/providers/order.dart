import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';

class OrderItem {
  final String? id;
  final double? amount;
  final List<CartItem>? products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Order with ChangeNotifier {
  List<OrderItem> _order = [];
  late String authToken;
  late String userId;
  Order(this.authToken, this._order, this.userId);

  List<OrderItem> get order {
    return [..._order];
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    var Url = Uri.parse(
        'https://quick-message-f46f3-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    var timesTamp = DateTime.now();
    final response = await http.post(
      Url,
      body: json.encode(
        {
          'amount': total,
          'dateTime': timesTamp.toIso8601String(),
          'products': cartProduct
              .map(
                (cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                },
              )
              .toList()
        },
      ),
    );
    _order.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProduct,
        dateTime: timesTamp,
      ),
    );
    notifyListeners();
  }

  Future<void> fectAndSetOrder() async {
    var Url = Uri.parse(
        'https://quick-message-f46f3-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');

    final response = await http.get(Url);
    final List<OrderItem> loadedOrder = [];
    final extractData = json.decode(response.body);
    if (extractData == null) {
      return;
    }
    extractData.forEach(
      (orderId, orderData) {
        loadedOrder.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            products: (orderData['products'] as List<dynamic>).map(
              (item) {
                return CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price'],
                );
              },
            ).toList(),
            dateTime: DateTime.parse(
              orderData['dateTime'],
            ),
          ),
        );
      },
    );
    _order = loadedOrder;
    notifyListeners();
  }
}

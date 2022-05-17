import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final String? imageUrl;
  bool? isFavourite;
  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavourite = false});

  Future<void> toggleFavourite(String authToken, String userId) async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite!;
    notifyListeners();
    final Url = Uri.parse(
        'https://quick-message-f46f3-default-rtdb.firebaseio.com/userFavorite/$userId/$id.json?auth=$authToken');
    try {
      final response = await http.put(
        Url,
        body: json.encode(
          isFavourite,
        ),
      );
      if (response.statusCode >= 400) {
        isFavourite = oldStatus;
        notifyListeners();
      }
    } catch (error) {
      isFavourite = oldStatus;
      notifyListeners();
    }
  }
}

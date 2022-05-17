import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/product.dart';
import '../modals/http_exception.dart';

class Products with ChangeNotifier {
  late String authToken;
  late String userId;
  Products(this.authToken, this._items, this.userId);
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get item {
    return [..._items];
  }

  List<Product> get favItem {
    return _items.where((prdItem) => prdItem.isFavourite!).toList();
  }

  Product findById(String id) {
    return _items.firstWhere(
      (itm) {
        return itm.id == id;
      },
    );
  }

  Future<void> fectAndSetProduct([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://quick-message-f46f3-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      url = Uri.parse(
          'https://quick-message-f46f3-default-rtdb.firebaseio.com/userFavorite/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProduct = [];
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(
          Product(
              id: prodId,
              title: prodData['title'].toString(),
              description: prodData['description'].toString(),
              price: double.parse(prodData['price'].toString()),
              imageUrl: prodData['imageUrl'].toString(),
              isFavourite:
                  favoriteData == null ? false : favoriteData[prodId] ?? false),
        );
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    var Url = Uri.parse(
        'https://quick-message-f46f3-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        Url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavorite': product.isFavourite,
            'creatorId': userId,
          },
        ),
      );
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final Url = Uri.parse(
        'https://quick-message-f46f3-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final prodIndex = _items.indexWhere((prd) => prd.id == id);
    if (prodIndex >= 0) {
      await http.patch(
        Url,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          },
        ),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('Products.dart : UpdateProduct method throwing eroor');
    }
  }

  Future<void> removeProducts(String id) async {
    final Url = Uri.parse(
        'https://quick-message-f46f3-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

    final existingIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingIndex];
    _items.removeAt(existingIndex);
    notifyListeners();
    final response = await http.delete(Url);
    if (response.statusCode >= 400) {
      _items.insert(existingIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}

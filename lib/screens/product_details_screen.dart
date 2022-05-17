import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = 'ProductDetailsScreen';
  const ProductDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final argsId = ModalRoute.of(context)!.settings.arguments as String;
    final productsData = Provider.of<Products>(context).findById(argsId);
    return Scaffold(
      appBar: AppBar(
        title: Text(productsData.title!),
      ),
      body: Column(
        children: [
          Container(
            height: 300.0,
            width: double.infinity,
            child: Image.network(
              productsData.imageUrl!,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Text(
            '\$${productsData.price}',
            style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            productsData.description!,
            textAlign: TextAlign.center,
            softWrap: true,
          )
        ],
      ),
    );
  }
}

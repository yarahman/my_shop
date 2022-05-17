import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../screens/product_details_screen.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // ProductItem({this.id, this.title, this.imageUrl});
  // final String? id;
  // final String? title;
  // final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    return GridTile(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProductDetailsScreen.routeName, arguments: product.id);
        },
        child: Image.network(
          product.imageUrl!,
          fit: BoxFit.cover,
        ),
      ),
      footer: GridTileBar(
        title: Text(
          product.title!,
          textAlign: TextAlign.center,
        ),
        leading: Consumer<Product>(
          builder: (ctx, prd, child) => IconButton(
            icon: Icon(
              prd.isFavourite!
                  ? Icons.favorite_outlined
                  : Icons.favorite_outline,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              prd.toggleFavourite(auth.token, auth.userId);
            },
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.shopping_cart,
            color: Theme.of(context).accentColor,
          ),
          onPressed: () {
            cart.addItem(product.id!, product.title!, product.price!);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Added item to cart!'),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    cart.removeSingleItem(product.id!);
                  },
                ),
              ),
            );
          },
        ),
        backgroundColor: Colors.black87,
      ),
    );
  }
}

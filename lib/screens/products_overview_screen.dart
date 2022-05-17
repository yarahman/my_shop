import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';

enum FilterOptions { MyFavourite, All }

class ProductOverviewScreen extends StatefulWidget {
  static const routeName = 'ProductOverviewScreen';
  const ProductOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showFavouriteProduct = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fectAndSetProduct().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showFavouriteProduct
            ? const Text('Your Favourites')
            : const Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              if (selectedValue == FilterOptions.MyFavourite) {
                setState(
                  () {
                    _showFavouriteProduct = true;
                  },
                );
              } else {
                setState(
                  () {
                    _showFavouriteProduct = false;
                  },
                );
              }
            },
            child: const Icon(Icons.more_vert),
            itemBuilder: ((context) => [
                  const PopupMenuItem(
                    child: Text('My Favourite'),
                    value: FilterOptions.MyFavourite,
                  ),
                  const PopupMenuItem(
                    child: Text('All'),
                    value: FilterOptions.All,
                  ),
                ]),
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCounter.toString(),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showFavouriteProduct),
      drawer: const AppDrawer(),
    );
  }
}

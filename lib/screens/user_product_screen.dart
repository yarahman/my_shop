import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import '../screens/edit_product_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = 'UserProductScreen';
  const UserProductScreen({Key? key}) : super(key: key);

  Future<void> _refreshProduct(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fectAndSetProduct(true);
  }

  @override
  Widget build(BuildContext context) {
    // final products = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Product'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProduct(context),
        child: FutureBuilder(
          future: _refreshProduct(context),
          builder: (ctx, snapShot) =>
              snapShot.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Consumer<Products>(
                        builder: (ctx, products, _) => ListView.builder(
                          itemBuilder: (context, index) {
                            return UserProductItem(
                                id: products.item[index].id,
                                title: products.item[index].title,
                                imageUrl: products.item[index].imageUrl);
                          },
                          itemCount: products.item.length,
                        ),
                      ),
                    ),
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}

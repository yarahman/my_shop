import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order.dart' show Order;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = 'OrderScreen';
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // var _isLoading = false;
  // @override
  // void initState() {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   Provider.of<Order>(context, listen: false).fectAndSetOrder().then(
  //         (_) => {
  //           setState(
  //             () {
  //               _isLoading = false;
  //             },
  //           ),
  //         },
  //       );
  //   super.initState();
  // }
  late Future _orderFuture;
  Future _obtainOrderFuture() {
    return Provider.of<Order>(context, listen: false).fectAndSetOrder();
  }

  @override
  void initState() {
    _orderFuture = _obtainOrderFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Order'),
      ),
      body: FutureBuilder(
        future: _orderFuture,
        builder: (ctx, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapShot.error != null) {
              return const Center(
                child: Text('Something is worng'),
              );
            } else {
              return Consumer<Order>(
                builder: (ctx, orderData, child) {
                  return ListView.builder(
                    itemBuilder: (ctx, index) {
                      return OrderItem(orderData.order[index]);
                    },
                    itemCount: orderData.order.length,
                  );
                },
              );
            }
          }
        },
      ),
      drawer: const AppDrawer(),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/order.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;
  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.order.amount!.toStringAsFixed(2),
            ),
            subtitle: Text(
                DateFormat('dd/MM/yyyy - hh:mm').format(widget.order.dateTime)),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(
                  () {
                    _isExpanded = !_isExpanded;
                  },
                );
              },
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: min(widget.order.products!.length * 20.0 + 10, 180),
              child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.order.products![index].title!,
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.order.products![index].quantity}x \$${widget.order.products![index].price}',
                          style: const TextStyle(
                              fontSize: 18.0, color: Colors.grey),
                        )
                      ],
                    );
                  },
                  itemCount: widget.order.products!.length),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:inventory/features/orderProduction/presentation/view/widget/orderProductionBody.dart';

class Orderproduction extends StatelessWidget {
var canedit;
Orderproduction({required this.canedit});
  @override
  Widget build(BuildContext context) {
    return OrderProductionBody(canedit: canedit,);
  }
}
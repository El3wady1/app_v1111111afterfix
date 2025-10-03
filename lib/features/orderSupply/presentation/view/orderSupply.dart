import 'package:flutter/material.dart';
import 'package:inventory/features/orderProduction/presentation/view/widget/orderProductionBody.dart';
import 'package:inventory/features/orderSupply/presentation/view/widget/orderSupplyBody.dart';

class orderSupply extends StatelessWidget {
var canedit;
orderSupply({required this.canedit});
  @override
  Widget build(BuildContext context) {
    return OrderSupplyBody(canedit: canedit,);
  }
}
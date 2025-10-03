import 'package:flutter/material.dart';
import 'package:inventory/features/out/presentation/view/widget/outBodyView.dart';
import 'package:inventory/features/scanBarCode/presentation/view/widget/scanbarCodeOutView.dart';

class Outview extends StatelessWidget {
  const Outview({super.key});

  @override
  Widget build(BuildContext context) {
    return  ScanbarcodeOutbodyview();
  }
}
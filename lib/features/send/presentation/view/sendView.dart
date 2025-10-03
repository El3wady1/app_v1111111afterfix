import 'package:flutter/material.dart';
import 'package:inventory/features/send/presentation/view/widget/sendBodyView.dart';

class Sendview extends StatelessWidget {
  const Sendview({super.key});

  @override
  Widget build(BuildContext context) {
    return Sendbodyview(role: 'admin',);
  }
}
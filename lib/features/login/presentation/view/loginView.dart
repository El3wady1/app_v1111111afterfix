import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory/features/login/presentation/controller/logincubit.dart';
import 'package:inventory/features/login/presentation/view/widget/loginBodyView.dart';

class Loginview extends StatelessWidget {
  const Loginview({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginBodyView();
  }
}
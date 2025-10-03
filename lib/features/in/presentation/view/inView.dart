import 'package:flutter/material.dart';
import 'package:inventory/core/utils/apiEndpoints.dart';
import 'package:inventory/features/home/data/repo/ReturnLastloginRepo.dart';
import 'package:inventory/features/in/presentation/view/widget/inBodyView.dart';

class Inview extends StatelessWidget {
  String initialBarcode;
  bool isExist;
  var SupplierData;
  var unitData;
  var mainProduct;
  var canAddPernew;
  Inview(
      {required this.initialBarcode,
      required this.isExist,
      required this.SupplierData,
      required this.mainProduct,
      required this.unitData,
      required this.canAddPernew});
  @override
  Widget build(BuildContext context) {
   
    return InviewBodyView(
      initialBarcode: initialBarcode,
      isExist: isExist,
      productID: '',
      unit: '',
      department: '',
      supplier: '',
      userID: '',
      SupplierData: SupplierData, 
      unitData: unitData, mainProduct: mainProduct, canAddPernew: canAddPernew,
    );
  }
}

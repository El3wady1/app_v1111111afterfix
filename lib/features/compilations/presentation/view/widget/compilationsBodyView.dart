import 'package:flutter/material.dart';

class Compilationsbodyview extends StatefulWidget {
  @override
  _DamagesScreenState createState() => _DamagesScreenState();
}

class _DamagesScreenState extends State<Compilationsbodyview> {
  String? selectedBranch;
  String? selectedProduct;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> selectedProducts = [];
  bool isLoading = false;

  final List<String> branches = [
    'الفرع الرئيسي',
    'فرع الرياض',
    'فرع جدة',
    'فرع الدمام',
  ];

  @override
  void initState() {
    super.initState();
    selectedProducts = [];
  }

  void _loadProducts(String branch) async {
    setState(() {
      isLoading = true;
      selectedProducts = []; // مسح الأصناف المختارة عند تغيير الفرع
      selectedProduct = null; // إعادة تعيين الصنف المختار
    });

    // محاكاة لجلب البيانات من الخادم
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      products = List.generate(10, (index) => {
        'id': index + 1,
        'name': 'صنف ${index + 1}',
        'available': (index + 1) * 10,
        'unit': index % 2 == 0 ? 'كجم' : 'عدد',
        'selectedQuantity': 0, // كمية مختارة مبدئياً صفر
      });
      isLoading = false;
    });
  }

  void _showQuantityDialog() {
    if (selectedProduct == null) return;
    
    var product = products.firstWhere((p) => p['name'] == selectedProduct);
    TextEditingController quantityController = TextEditingController(
      text: product['selectedQuantity'] > 0 ? product['selectedQuantity'].toString() : ''
    );
    final formKey = GlobalKey<FormState>();

    void _updateQuantity(int change) {
      int current = int.tryParse(quantityController.text) ?? 0;
      int newValue = current + change;
      if (newValue >= 0 && newValue <= product['available']) {
        quantityController.text = newValue.toString();
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('إدخال كمية التالف', textAlign: TextAlign.center),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${product['name']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'الكمية المتاحة: ${product['available']} ${product['unit']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _updateQuantity(-1),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: 'الكمية (${product['unit']})',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          ),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال الكمية';
                            }
                            if (int.tryParse(value) == null) {
                              return 'الرجاء إدخال رقم صحيح';
                            }
                            if (int.parse(value) > product['available']) {
                              return 'الكمية المدخلة أكبر من المتاحة';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _updateQuantity(1),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
              
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    _addProductToSelection(product, int.parse(quantityController.text));
                    Navigator.pop(context);
                    setState(() {
                      selectedProduct = null; // إعادة تعيين الصنف المختار بعد الإضافة
                    });
                  }
                },
                child: Text('إضافة', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addProductToSelection(Map<String, dynamic> product, int quantity) {
    setState(() {
      // تحديث كمية الصنف في القائمة الرئيسية
      int index = products.indexWhere((p) => p['id'] == product['id']);
      if (index != -1) {
        products[index]['selectedQuantity'] = quantity;
      }

      // إضافة أو تحديث الصنف في قائمة الأصناف المختارة
      int selectedIndex = selectedProducts.indexWhere((p) => p['id'] == product['id']);
      if (selectedIndex != -1) {
        if (quantity > 0) {
          selectedProducts[selectedIndex]['selectedQuantity'] = quantity;
        } else {
          selectedProducts.removeAt(selectedIndex);
        }
      } else if (quantity > 0) {
        selectedProducts.add({
          'id': product['id'],
          'name': product['name'],
          'unit': product['unit'],
          'selectedQuantity': quantity,
        });
      }
    });
  }

  void _saveAllDamages() async {
    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إضافة أصناف أولاً'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // محاكاة لعملية الحفظ
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isLoading = false;
      selectedProducts = []; // مسح الأصناف بعد الحفظ
      // مسح الكميات المختارة من القائمة الرئيسية
      for (var product in products) {
        product['selectedQuantity'] = 0;
      }
    });

    // عرض ملخص بالأصناف المحفوظة
    String summary = selectedProducts.map((p) => 
      '${p['name']}: ${p['selectedQuantity']} ${p['unit']}'
    ).join('\n');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ التوالف:\n$summary'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تسجيل التوالف'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step 1: Branch Selection
              Directionality(
                textDirection: TextDirection.rtl,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedBranch,
                  decoration: InputDecoration(
                    labelText: 'اختر الفرع',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store),
                  ),
                  items: branches.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          value,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedBranch = newValue;
                      _loadProducts(newValue!);
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'الرجاء اختيار الفرع';
                    }
                    return null;
                  },
                ),
              ),
              if (selectedBranch != null) ...[
                SizedBox(height: 20),
                Text(
                  'أصناف الإنتاج:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedProduct,
                    decoration: InputDecoration(
                      labelText: 'اختر صنف',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                      suffixIcon: selectedProduct != null 
                          ? IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                _showQuantityDialog();
                              },
                            )
                          : null,
                    ),
                    items: products.map((product) {
                      return DropdownMenuItem<String>(
                        value: product['name'],
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${product['name']}',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedProduct = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'الرجاء اختيار صنف';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),

                if (selectedProducts.isNotEmpty) ...[
                  Card(
                    elevation: 3,
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الأصناف المختارة:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          ...selectedProducts.map((product) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('${product['name']}'),
                                ),
                                Text('${product['selectedQuantity']} ${product['unit']}'),
                                IconButton(
                                  icon: Icon(Icons.edit, size: 20),
                                  onPressed: () {
                                    var originalProduct = products.firstWhere((p) => p['id'] == product['id']);
                                    setState(() {
                                      selectedProduct = originalProduct['name'];
                                    });
                                    _showQuantityDialog();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () {
                                    _addProductToSelection(product, 0);
                                  },
                                ),
                              ],
                            ),
                          )).toList(),
                          SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            onPressed: _saveAllDamages,
                            child: isLoading 
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text("حفظ", style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
                SizedBox(height: 10),

                if (selectedProduct != null)
                  ElevatedButton(
                    onPressed: _showQuantityDialog,
                    child: Text('إضافة كمية للصنف المختار'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                
                Expanded(child: Container()), // مساحة فارغة لدفع العناصر لأعلى
              ] else ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'الرجاء اختيار الفرع أولاً',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:inventory/core/utils/apiEndpoints.dart';
import 'package:intl/intl.dart';

class Lastsendview extends StatefulWidget {
  Lastsendview({super.key});

  @override
  State<Lastsendview> createState() => _LastsendviewState();
}

class _LastsendviewState extends State<Lastsendview> {
  List<dynamic> historyData = [];
  List<dynamic> filteredHistoryData = [];
  Map<String, dynamic> lastOrderByBranch = {};
  bool isLoading = true;
  bool isFilterVisible = false;
  String errorMessage = '';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  // الألوان المحددة من الصورة
  final Color primaryColor = Color(0xFF74826A); // الأخضر الداكن
  final Color accentColor = Color(0xFFEDBE2C); // الأصفر الذهبي
  final Color secondaryColor = Color(0xFFCDBCA2); // البيج الفاتح
  final Color backgroundColor = Color(0xFFF3F4EF); // الأبيض المائل للأخضر

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  Future<void> fetchHistoryData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
          Uri.parse(Apiendpoints.baseUrl + Apiendpoints.production.history));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          historyData = data['data'];

          // استخراج آخر طلب من كل فرع
          extractLastOrderByBranch();

          // عند تحميل البيانات لأول مرة، عرض بيانات اليوم الحالي فقط
          final today = DateTime.now();
          selectedStartDate = DateTime(today.year, today.month, today.day);
          selectedEndDate =
              DateTime(today.year, today.month, today.day, 23, 59, 59);

          filterDataByDate();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'فشل في جلب البيانات: ${response.statusCode}'.tr();
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'حدث خطأ: $e'.tr();
      });
    }
  }

  // دالة لاستخراج آخر طلب من كل فرع
  void extractLastOrderByBranch() {
    lastOrderByBranch.clear();

    for (var item in historyData) {
      final branchId = item['branchId'] ?? item['branch']?['_id'] ?? 'unknown';

      // إذا كان الفرع غير موجود أو إذا كان الطلب الحالي أحدث
      if (!lastOrderByBranch.containsKey(branchId) ||
          DateTime.parse(item['createdAt']).isAfter(
              DateTime.parse(lastOrderByBranch[branchId]['createdAt']))) {
        lastOrderByBranch[branchId] = item;
      }
    }
  }

  Future<void> updateHistoryItem(
      String id, List<Map<String, dynamic>> items) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${Apiendpoints.baseUrl}${Apiendpoints.production.updatehistory}$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'items': items}),
      );

      if (response.statusCode == 200) {
        // نجاح التحديث، إعادة تحميل البيانات
        fetchHistoryData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم التحديث بنجاح').tr(),
            backgroundColor: primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في التحديث: ${response.statusCode}'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteHistoryItem(String id) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '${Apiendpoints.baseUrl}${Apiendpoints.production.deletehistory}$id'),
      );

      if (response.statusCode == 200) {
        // نجاح الحذف، إعادة تحميل البيانات
        fetchHistoryData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم الحذف بنجاح').tr(),
            backgroundColor: primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في الحذف: ${response.statusCode}'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showEditDialog(Map<String, dynamic> item) {
    final List<Map<String, dynamic>> items = List.from(item['items']);
    final List<TextEditingController> controllers = [];

    for (var productItem in items) {
      controllers
          .add(TextEditingController(text: productItem['qty'].toString()));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'تعديل الكميات'.tr(),
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      // تحديث القيم مع التحقق من الصحة
                                      for (int i = 0; i < items.length; i++) {
                                        final newQty =
                                            int.tryParse(controllers[i].text) ??
                                                0;
                                        if (newQty < 0) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'الكمية لا يمكن أن تكون سالبة'
                                                        .tr())),
                                          );
                                          return;
                                        }
                                        items[i]['qty'] = newQty;
                                      }

                                      Navigator.of(context).pop();
                                      updateHistoryItem(item['_id'], items);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    )),
                                SizedBox(height: 5),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Icon(
                                    Icons.dangerous,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 5),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: secondaryColor.withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      items[index]['product']['name'],
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 75,
                                    child: TextField(
                                      controller: controllers[index],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        labelText: 'الكمية'.tr(),
                                        hintStyle: GoogleFonts.cairo(
                                            fontSize: 12, color: primaryColor),
                                        labelStyle: GoogleFonts.cairo(
                                            fontSize: 12, color: primaryColor),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: primaryColor),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: primaryColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'تأكيد الحذف'.tr(),
            style: GoogleFonts.cairo(
                color: primaryColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من أنك تريد حذف هذه العملية؟ لا يمكن التراجع عن هذا الإجراء.'
                .tr(),
            style: GoogleFonts.cairo(color: primaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'.tr(),
                  style: GoogleFonts.cairo(color: primaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteHistoryItem(id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('حذف'.tr(),
                  style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // دالة لفلترة البيانات حسب التاريخ
  void filterDataByDate() {
    if (selectedStartDate == null && selectedEndDate == null) {
      setState(() {
        filteredHistoryData = historyData;
      });
      return;
    }

    setState(() {
      filteredHistoryData = historyData.where((item) {
        final DateTime createdAt = DateTime.parse(item['createdAt']);

        bool isAfterStartDate = true;
        bool isBeforeEndDate = true;

        if (selectedStartDate != null) {
          isAfterStartDate = createdAt.isAfter(DateTime(selectedStartDate!.year,
                  selectedStartDate!.month, selectedStartDate!.day, 0, 0, 0)
              .subtract(Duration(seconds: 1)));
        }

        if (selectedEndDate != null) {
          isBeforeEndDate = createdAt.isBefore(DateTime(selectedEndDate!.year,
              selectedEndDate!.month, selectedEndDate!.day, 23, 59, 59));
        }

        return isAfterStartDate && isBeforeEndDate;
      }).toList();
    });
  }

  // دالة لعرض منتقي التاريخ
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (selectedStartDate ?? DateTime.now())
          : (selectedEndDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: backgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
        } else {
          selectedEndDate = picked;
        }
      });
      filterDataByDate();
    }
  }

  // دالة لإعادة تعيين الفلتر
  void resetFilter() {
    setState(() {
      selectedStartDate = null;
      selectedEndDate = null;
      filteredHistoryData = historyData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: Text('سجل العمليات'.tr(),
            style: GoogleFonts.cairo(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
                isFilterVisible ? Icons.filter_alt_off : Icons.filter_alt,
                color: Colors.white),
            onPressed: () {
              setState(() {
                isFilterVisible = !isFilterVisible;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style:
                            GoogleFonts.cairo(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchHistoryData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                        child: Text('إعادة المحاولة'.tr(),
                            style: GoogleFonts.cairo(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : historyData.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد بيانات متاحة'.tr(),
                        style: GoogleFonts.cairo(
                            fontSize: 18, color: primaryColor),
                      ),
                    )
                  : Column(
                      children: [
                        // قسم الفلترة (يظهر فقط عند الضغط على زر الفلتر)
                        if (isFilterVisible)
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            margin: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تصفية حسب التاريخ'.tr(),
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'من تاريخ'.tr(),
                                            style: GoogleFonts.cairo(
                                              fontSize: 14,
                                              color: primaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          InkWell(
                                            onTap: () =>
                                                _selectDate(context, true),
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: secondaryColor),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    selectedStartDate != null
                                                        ? DateFormat(
                                                                'yyyy/MM/dd')
                                                            .format(
                                                                selectedStartDate!)
                                                        : 'اختر التاريخ'.tr(),
                                                    style: GoogleFonts.cairo(
                                                      color:
                                                          selectedStartDate !=
                                                                  null
                                                              ? primaryColor
                                                              : Colors.grey,
                                                    ),
                                                  ),
                                                  Icon(Icons.calendar_today,
                                                      size: 20,
                                                      color: primaryColor),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'إلى تاريخ'.tr(),
                                            style: GoogleFonts.cairo(
                                              fontSize: 14,
                                              color: primaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          InkWell(
                                            onTap: () =>
                                                _selectDate(context, false),
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: secondaryColor),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    selectedEndDate != null
                                                        ? DateFormat(
                                                                'yyyy/MM/dd')
                                                            .format(
                                                                selectedEndDate!)
                                                        : 'اختر التاريخ'.tr(),
                                                    style: GoogleFonts.cairo(
                                                      color: selectedEndDate !=
                                                              null
                                                          ? primaryColor
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                  Icon(Icons.calendar_today,
                                                      size: 20,
                                                      color: primaryColor),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: resetFilter,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          foregroundColor: Colors.grey[800],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text('إعادة التعيين'.tr()),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: filterDataByDate,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text('تطبيق الفلتر'.tr(),
                                            style: GoogleFonts.cairo(
                                                color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                                if (selectedStartDate != null ||
                                    selectedEndDate != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Text(
                                      'عدد النتائج'.tr() +
                                          " :" +
                                          '${filteredHistoryData.length}'.tr(),
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        // معلومات الفلتر الحالي (تظهر دائمًا)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedStartDate != null ||
                                            selectedEndDate != null
                                        ? 'عرض البيانات من ${selectedStartDate != null ? DateFormat('yyyy/MM/dd').format(selectedStartDate!) : 'البداية'} إلى ${selectedEndDate != null ? DateFormat('yyyy/MM/dd').format(selectedEndDate!) : 'النهاية'}'
                                            .tr()
                                        : 'عرض جميع البيانات'.tr(),
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: primaryColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'النتائج'.tr() +
                                      " : " +
                                      '${filteredHistoryData.length}'.tr(),
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        // زر لعرض آخر طلب من كل فرع
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // عند الضغط على الزر، نعرض فقط آخر طلب من كل فرع
                                filteredHistoryData =
                                    lastOrderByBranch.values.toList();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'عرض آخر طلب من كل فرع'.tr(),
                              style: GoogleFonts.cairo(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: filteredHistoryData.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search_off,
                                              size: 50,
                                              color: primaryColor
                                                  .withOpacity(0.5)),
                                          SizedBox(height: 16),
                                          Text(
                                            'لا توجد نتائج للعرض'.tr(),
                                            style: GoogleFonts.cairo(
                                              fontSize: 16,
                                              color: primaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'جرب نطاق تواريخ مختلف'.tr(),
                                            style: GoogleFonts.cairo(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: filteredHistoryData.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredHistoryData[index];
                                        final branchName = item['branch']
                                                ?['name'] ??
                                            'غير محدد'.tr();

                                        return Container(
                                          margin: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: secondaryColor
                                                  .withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: ExpansionTile(
                                            initiallyExpanded: index == 0,
                                            collapsedBackgroundColor:
                                                Colors.white,
                                            backgroundColor: Colors.white,
                                            iconColor: primaryColor,
                                            collapsedIconColor: primaryColor,
                                            title: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: _getActionColor(
                                                            item['action'])
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: _getActionColor(
                                                            item['action'])),
                                                  ),
                                                  child: Text(
                                                    _getActionText(
                                                        item['action']),
                                                    style: GoogleFonts.cairo(
                                                      color: _getActionColor(
                                                          item['action']),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${'الفرع'.tr()}: $branchName',
                                                        style:
                                                            GoogleFonts.cairo(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color:
                                                              Colors.green[650],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            subtitle: Column(
                                              children: [
                                                Text(
                                                  '${'تاريخ التحديث'.tr()}: ${formatDate(item['updatedAt'])}',
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 8.0),
                                                  child: Text(
                                                    '${'تاريخ الإنشاء'.tr()}: ${formatDate(item['createdAt'])}',
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // جدول المنتجات
                                                    Text(
                                                      'المنتجات'.tr() + " : ",
                                                      style: GoogleFonts.cairo(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: primaryColor,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Table(
                                                      columnWidths: {
                                                        0: FlexColumnWidth(3),
                                                        1: FlexColumnWidth(1),
                                                      },
                                                      border: TableBorder(
                                                        horizontalInside:
                                                            BorderSide(
                                                          color: secondaryColor
                                                              .withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                        bottom: BorderSide(
                                                          color: secondaryColor
                                                              .withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                        top: BorderSide(
                                                          color: secondaryColor
                                                              .withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      children: [
                                                        // رأس الجدول
                                                        TableRow(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: primaryColor
                                                                .withOpacity(
                                                                    0.1),
                                                          ),
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          10.0),
                                                              child: Text(
                                                                'اسم المنتج'
                                                                    .tr(),
                                                                style:
                                                                    GoogleFonts
                                                                        .cairo(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      primaryColor,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          10.0),
                                                              child: Text(
                                                                'الكمية'.tr(),
                                                                style:
                                                                    GoogleFonts
                                                                        .cairo(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      primaryColor,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // بيانات الجدول
                                                        ...item['items']
                                                            .map<TableRow>(
                                                                (productItem) {
                                                          return TableRow(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10.0),
                                                                child: Text(
                                                                  productItem[
                                                                          'product']
                                                                      ['name'],
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      GoogleFonts
                                                                          .cairo(
                                                                    color:
                                                                        primaryColor,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10.0),
                                                                child: Text(
                                                                  productItem[
                                                                          'qty']
                                                                      .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      GoogleFonts
                                                                          .cairo(
                                                                    color:
                                                                        primaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        }).toList(),
                                                      ],
                                                    ),
                                                    SizedBox(height: 16),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            if (item[
                                                                    'action'] !=
                                                                'delete')
                                                              ElevatedButton(
                                                                onPressed: () =>
                                                                    showEditDialog(
                                                                        item),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      accentColor,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  'تعديل'.tr(),
                                                                  style: GoogleFonts.cairo(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            SizedBox(width: 8),
                                                          //   ElevatedButton(
                                                          //     onPressed: () =>
                                                          //         showDeleteConfirmationDialog(
                                                          //             item[
                                                          //                 '_id']),
                                                          //     style:
                                                          //         ElevatedButton
                                                          //             .styleFrom(
                                                          //       backgroundColor:
                                                          //           Colors.red,
                                                          //       shape:
                                                          //           RoundedRectangleBorder(
                                                          //         borderRadius:
                                                          //             BorderRadius
                                                          //                 .circular(
                                                          //                     8),
                                                          //       ),
                                                          //     ),
                                                          //     child: Text(
                                                          //       'حذف'.tr(),
                                                          //       style: GoogleFonts.cairo(
                                                          //           color: Colors
                                                          //               .white),
                                                          //     ),
                                                          //   ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  // دالة مساعدة لتنسيق التاريخ
  String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  // دالة للحصول على لون الحالة
  Color _getActionColor(String action) {
    switch (action) {
      case 'update':
        return Colors.green;
      case 'create':
        return Colors.blue;
      case 'approve':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // دالة للحصول على نص الحالة - تم إصلاح المشكلة هنا
  String _getActionText(String action) {
    switch (action) {
      case 'update':
        return 'تحديث'.tr();
      case 'create':
        return 'إضافة جديدة'.tr();
      case 'approve':
        return 'موافقة'.tr();
      case 'delete':
        return 'حذف'.tr();
      default:
        return action;
    }
  }
}

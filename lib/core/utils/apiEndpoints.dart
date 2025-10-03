class Apiendpoints {
//  static String host ="http://192.168.1.7:8000";
//  static String baseUrl = "$host/api/";
  //static String baseUrl ="https://6304f295-cc81-4d4d-8c41-308d95791113-00-39g1jxagegtcf.spock.replit.dev/api/";
     static String baseUrl ="https://saladfactorybackend-production.up.railway.app/api/";
  static Auth auth = Auth();
  static Product product = Product();
  static Unit unit = Unit();
  static Supplier supplier = Supplier();
  static Transaction transaction = Transaction();
  static User user = User();
  static Department department = Department();
  static Email email = Email();
  static MainProduct mainProduct = MainProduct();
  static Fatwra fatwra = Fatwra();
  static Branch branch = Branch();
  static ProductOP productOP =ProductOP();
  static OrderProduction orderProduction = OrderProduction();
  static OrderSupply orderSupply = OrderSupply();
  static MainProductOP mainProductOP = MainProductOP();
  static Production  production =Production();
  static ProductionSupply  productionSupply =ProductionSupply();
  static Send  send =Send();
  static Settings  settings =Settings();

}

class Auth {
  String login = "auth/login";
  String userData = "auth/user";
  String createuser = "users/create";
  String userDep = "auth/user/department";
  String userBranchOP = "auth/user/BranchOP";
  String userBranchOS = "auth/user/BranchOS";
}

class Product {
  String getByBarcode = "product/barcode";
  String add = "product/add";
  String getAll="product/getAll";
  String updateByid ="product/";
  String getByid="product/";
  String dowunloadXls="product/download/excel/";
  String updateminQty="product/minQty/";
  String deleteByid="product/";
  String downloadAll="product/downloadAll";
  String addqtyAndexpired="product/addqtyAndexpiredByBarcode";
  String outproduct="product/outproduct";
  String relatedOrderProduction="product/relatedOrderProduction";

}

class Unit {
  String getall = "unit/getAll";
    String getByid = "unit/";
  String addunit= "unit/addunit";
  String delete = "unit/";
    String updateByid = "unit/";

}

class Supplier {
  String add = "supplier/addSupplier";
  String getall = "supplier/getAll";
  String updateByid = "supplier/";
  String delete = "supplier/";
}

class Transaction {
  String add = "transaction/add";
  String Byid="transaction/";
  String getAll = "transaction/getAll";
  String addwhenaddnoProduct = "transaction/addwhenaddNewProduct";
  String downloadTrancByid="transaction/export/";
  String downloadAllTranc="transaction/exports/all";
}

class User {
  String getAll = "users/getAll";
  String delete = "users/";
  String update = "users/";
  String updateUserdep = "users/updateUserdep/";
  String verfiy = "users/activeAcouunt/";
  String canRemoveProduct = "users/perToremove/";
  String canAddProduct = "users/perToadd/";
    String canAddProductIN = "users/canAddProductIN/";
    
    String canReceiveProduct = "users/canReceiveProduct/";
    String canProduction = "users/canProduction/";
    String canOrderProduction = "users/canOrderProduction/";

    String  canEditLastOrderProduction= "users/canEditLastOrderProductionProduct/";
    String canEditLastSupply  = "users/canEditLastSupplyProduct/";


    String canSendProduct = "users/canSendProduct/";
    String canSupplyProduct = "users/canSupplyProduct/";
    String canDamagedProduct = "users/canDamagedProduct/";
    String add_branchOP = "users/add-branchOP";
    String remove_branchOP = "users/remove-branchOP";  String add_branchOS = "users/add-branchOS";
    String remove_branchOS = "users/remove-branchOS";

}

class Department {
  String getAll = "department/getAll";
  String getByid = "department/";
  String addDepartment = "department/addDepartment";
  String delete = "department/";
}
class Email {
  String getByid = "email/";
  String update = "email/";
}
class MainProduct {
  String add = "mainProduct/addmainProduct";
  String getAll = "mainProduct/getAll";
  String update = "mainProduct/";
  String delete= "mainProduct/";
}
class MainProductOP {
  String add = "mainProductOP/addmainProductOP";
  String getAll = "mainProductOP/getAll";
  String update = "mainProductOP/";
  String updateOrder="mainProductOP/updateProductsOrder";
  String delete= "mainProductOP/";
}
class Fatwra {
  String add = "fatwra/addfatwra";
  String getAll = "fatwra/getAll";
  String update = "fatwra/";
  String delete= "fatwra/";
}
class Branch{
  String getall="branch/getAll";
}
class OrderProduction{
    String add = "orderProduction/add";
    String getAll = "orderProduction/getAll";
    String update ="orderProduction/" ;
    String delete= "orderProduction/";
    String isSend= "orderProduction/isSended/";

}

class ProductOP{
    String add = "productOP/add";
  String getAll = "productOP/getAll";
  String getrelatedMainproductOP= "/getrelatedMainproductOP";
  String main= "productOP/";
  String update = "productOP/";
  String Issupply = "productOP/Issupply/";
  String delete= "productOP/";
}

class Production {
      String request = "production/request";
      String getPending = "production/requests/pending";
String approve = "production/approve";
String refusePendingRequest = "production/refusePendingRequest/";
String updateQty = "production/updateQty/";
String Qtyproduction = "production/Qtyproduction/";
String approved = "production/approved";
String delete= "production/refuseacceptedRequest/";

String history= "production//history";
String updatehistory= "production//history/";
String deletehistory= "production/deletehistory/";

}      
class OrderSupply{
     String add = "orderSupply/add";
    String getAll = "orderSupply/getAll";
    String update ="orderSupply/" ;
    String delete= "orderSupply/";
 String isSend= "orderSupply/isSended/";
}   


class Send{
      String getAll = "production/send/getAllSendHistory";
    String update ="production/send/updateHistorysend/" ;
    String delete= "production/send/deleteHistorysend/";
}

class ProductionSupply {
    String request = "ProductionSupply/request";
      String getPending = "ProductionSupply/requests/pending";
String approve = "ProductionSupply/approve";
String refusePendingRequest = "ProductionSupply/refusePendingRequest/";
String updateQty = "ProductionSupply/updateQty/";
String Qtyproduction = "ProductionSupply/QtyProductionSupply/";
String approved = "ProductionSupply/approved";
String delete= "ProductionSupply/refuseacceptedRequest/";

String history= "ProductionSupply//history";
String updatehistory= "ProductionSupply//history/";
String deletehistory= "ProductionSupply/deletehistory/";
}


class Settings{
     String add = "settings/create";
    String getAll = "settings/all";
    String update ="settings/" ;
    String delete= "settings/";
    String appstate="settings/68de82e16458107d3e5955d1";}
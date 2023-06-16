// ignore_for_file: invalid_use_of_protected_member

import 'package:clothes_app/users/model/cart.dart';
import 'package:get/get.dart';

class CartListController extends GetxController {
  //user all item in cart + record //5
  final RxList<Cart> _cartlist = <Cart>[].obs;

  //user select item for which user want to process and want place final order
  final RxList<int> _selectedItemList = <int>[].obs;
  final RxBool _isSelectedAll = false.obs;
  final RxDouble _total = 0.0.obs;

  List<Cart> get cartList => _cartlist.value;
  List<int> get selectedItemList => _selectedItemList.value;
  bool get isSelectedItem => _isSelectedAll.value;
  bool get isSelectedAll => _isSelectedAll.value;
  double get total => _total.value;

  setList(List<Cart> list) {
    _cartlist.value = list;
  }

  addSelectedItem(int selectedCartId) {
    _selectedItemList.value.add(selectedCartId);
    update();
  }

  deleteSelectedItem(int selectedCartId) {
    _selectedItemList.value.remove(selectedCartId);
    update();
  }

  setIsSelectedAllItem() {
    _isSelectedAll.value = !_isSelectedAll.value;
  }

  clearAllSelectedItem() {
    _selectedItemList.value.clear();
    update();
  }

  setTotal(double overallTotal) {
    _total.value = overallTotal;
  }
}

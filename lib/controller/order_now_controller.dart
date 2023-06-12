import 'package:get/get.dart';

class OrderNowController extends GetxController {
  final RxString _deliverySystem = "FedEx".obs;
  final RxString _paymentSystem = "Apple Pay".obs;

  String get deliverySys => _deliverySystem.value;
  String get paymentSys => _paymentSystem.value;

  setDeliverySystem(String newDeliverySystem) {
    _deliverySystem.value = newDeliverySystem;
  }

  setPaymentSystem(String newPaymentSystem) {
    _paymentSystem.value = newPaymentSystem;
  }
}

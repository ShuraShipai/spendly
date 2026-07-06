enum PaymentMethod {
  cash('Cash'),
  upi('UPI'),
  card('Card');

  const PaymentMethod(this.label);

  final String label;

  static PaymentMethod fromId(String? id) {
    for (final method in values) {
      if (method.name == id) {
        return method;
      }
    }
    return cash;
  }
}

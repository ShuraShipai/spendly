enum PaymentMethod {
  cash('Cash'),
  upi('UPI'),
  card('Card');

  const PaymentMethod(this.label);

  final String label;
}

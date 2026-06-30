enum PaymentMethod {
  upi('UPI'),
  cash('Cash');

  const PaymentMethod(this.label);

  final String label;
}

import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/expenses/providers/add_expense_flow_controller.dart';

void main() {
  group('AddExpenseFlowController amount input', () {
    test('opens on the expense details step', () {
      final controller = AddExpenseFlowController();

      expect(controller.step, AddExpenseStep.details);
    });

    test('starts at zero and appends digits normally', () {
      final controller = AddExpenseFlowController();

      expect(controller.amount, '0');

      controller.appendAmount('1');
      controller.appendAmount('2');
      controller.appendAmount('3');

      expect(controller.amount, '123');
    });

    test('backspace removes one digit at a time', () {
      final controller = AddExpenseFlowController();

      controller.appendAmount('1');
      controller.appendAmount('2');
      controller.appendAmount('3');
      controller.backspaceAmount();
      controller.backspaceAmount();
      controller.backspaceAmount();
      controller.backspaceAmount();

      expect(controller.amount, '0');
    });

    test('preset chips add exact values to current amount', () {
      final controller = AddExpenseFlowController();

      controller.addPresetAmount(500);
      controller.addPresetAmount(500);

      expect(controller.amount, '1000');
    });

    test('keypad entry after preset continues editing the visible amount', () {
      final controller = AddExpenseFlowController();

      controller.addPresetAmount(100);
      controller.addPresetAmount(100);
      controller.addPresetAmount(100);
      controller.appendAmount('5');

      expect(controller.amount, '3005');
    });

    test('decimal input is limited to two places and preset-safe', () {
      final controller = AddExpenseFlowController();

      controller.appendAmount('1');
      controller.appendAmount('.');
      controller.appendAmount('2');
      controller.appendAmount('3');
      controller.appendAmount('4');

      expect(controller.amount, '1.23');

      controller.addPresetAmount(50);

      expect(controller.amount, '51.23');
    });
  });
}

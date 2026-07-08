class BudgetEditorRequest {
  const BudgetEditorRequest.overall() : categoryId = null;
  const BudgetEditorRequest.category(this.categoryId);

  final String? categoryId;

  bool get isOverall => categoryId == null;
}

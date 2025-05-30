class DisplayListItem {
  final DateTime date;
  final double amount;
  final String title;
  final String iconName;
  final int iconBackgroundColorValue;
  final bool isExpense;

  DisplayListItem({
    required this.date,
    required this.amount,
    required this.title,
    required this.iconName,
    required this.iconBackgroundColorValue,
    required this.isExpense,
  });
}
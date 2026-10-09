import 'package:flutter/material.dart';

import '../domain/models/expense_category.dart';

IconData categoryIcon(ExpenseCategory c) => switch (c) {
  ExpenseCategory.food => Icons.restaurant_rounded,
  ExpenseCategory.groceries => Icons.shopping_basket_rounded,
  ExpenseCategory.drinks => Icons.local_bar_rounded,
  ExpenseCategory.transport => Icons.directions_car_rounded,
  ExpenseCategory.housing => Icons.home_rounded,
  ExpenseCategory.utilities => Icons.bolt_rounded,
  ExpenseCategory.entertainment => Icons.theaters_rounded,
  ExpenseCategory.travel => Icons.flight_rounded,
  ExpenseCategory.shopping => Icons.shopping_bag_rounded,
  ExpenseCategory.health => Icons.favorite_rounded,
  ExpenseCategory.gifts => Icons.card_giftcard_rounded,
  ExpenseCategory.other => Icons.category_rounded,
};

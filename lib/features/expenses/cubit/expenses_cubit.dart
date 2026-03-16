import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  final AppDatabase database;

  ExpensesCubit(this.database) : super(ExpensesInitial());

  Future<void> loadExpenses({String? query}) async {
    emit(ExpensesLoading());
    try {
      var expenses = await database.getExpenses();
      if (query != null && query.isNotEmpty) {
        expenses = expenses
            .where(
              (e) =>
                  e.title.toLowerCase().contains(query.toLowerCase()) ||
                  (e.category?.toLowerCase().contains(query.toLowerCase()) ??
                      false),
            )
            .toList();
      }
      emit(ExpensesLoaded(expenses: expenses));
    } catch (e) {
      emit(ExpensesError('Failed to load expenses: $e'));
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await database.addExpense(expense);
      loadExpenses();
    } catch (e) {
      emit(ExpensesError('Failed to add expense: $e'));
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await database.updateExpense(expense);
      loadExpenses();
    } catch (e) {
      emit(ExpensesError('Failed to update expense: $e'));
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await database.deleteExpense(id);
      loadExpenses();
    } catch (e) {
      emit(ExpensesError('Failed to delete expense: $e'));
    }
  }
}

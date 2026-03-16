import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final AppDatabase _db;

  ReportsCubit(this._db) : super(ReportsInitial());

  Future<void> loadReports({
    required DateTime start,
    required DateTime end,
  }) async {
    emit(ReportsLoading());
    try {
      final totals = await _db.getTotalsForPeriod(start, end);
      final productSales = await _db.getSalesByProduct(start, end);

      emit(ReportsLoaded(totals: totals, productSales: productSales));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  void loadDailyReport(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    loadReports(start: start, end: end);
  }

  void loadMonthlyReport(DateTime date) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    loadReports(start: start, end: end);
  }

  void loadYearlyReport(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    final end = DateTime(date.year, 12, 31, 23, 59, 59);
    loadReports(start: start, end: end);
  }

  void loadCustomReport(DateTime start, DateTime end) {
    final reportEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
    loadReports(start: start, end: reportEnd);
  }
}

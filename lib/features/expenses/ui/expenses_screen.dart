import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import '../../../core/widgets/app_paginated_data_table.dart';
import '../cubit/expenses_cubit.dart';
import '../cubit/expenses_state.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ExpensesCubit(RepositoryProvider.of<AppDatabase>(context))
            ..loadExpenses(),
      child: const ExpensesView(),
    );
  }
}

class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  final _expensTypeController = TextEditingController();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _titleController.clear();
    _amountController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpensesCubit, ExpensesState>(
      builder: (context, state) {
        return Container(
          color: const Color(0xFFF0F2F5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(24.0.r),
                child: Text(
                  'إدارة المصروفات',
                  style: GoogleFonts.cairo(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          child: _buildAddExpenseCard(context),
                        ),
                      ),
                      SizedBox(width: 24.w),
                      Expanded(
                        flex: 6,
                        child: _buildExpensesTable(context, state),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddExpenseCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: const Color(0xFF0D6EFD),
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  'إضافة مصروف جديد',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D6EFD),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildFieldLabel('نوع المصروف *'),
            _buildTextField(_expensTypeController, "كهرباء مصروفات "),
            SizedBox(height: 16.h),
            _buildFieldLabel('المبلغ *'),
            _buildTextField(
              _amountController,
              '0.0',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),
            _buildFieldLabel('ملاحظات'),
            _buildTextField(_notesController, '...', maxLines: 4),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_expensTypeController.text.isNotEmpty &&
                      _amountController.text.isNotEmpty) {
                    final expense = Expense(
                      title: _expensTypeController.text.trim(),
                      amount: double.tryParse(_amountController.text) ?? 0.0,
                      date: DateTime.now(),
                      category: _expensTypeController.text.trim(),
                      description: _notesController.text,
                    );
                    context.read<ExpensesCubit>().addExpense(expense);
                    _clearForm();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('الرجاء ملء الحقول المطلوبة'),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.add_box_rounded, size: 24.r),
                label: Text(
                  'إضافة المصروف',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesTable(BuildContext context, ExpensesState state) {
    if (state is ExpensesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ExpensesLoaded) {
      return AppPaginatedDataTable(
        minWidth: 800,
        columnSpacing: 20.w,
        onSearch: (v) => context.read<ExpensesCubit>().loadExpenses(query: v),
        header: Row(
          children: [
            Icon(
              Icons.list_alt_rounded,
              color: const Color(0xFF0D6EFD),
              size: 20.r,
            ),
            SizedBox(width: 8.w),
            Text(
              'سجل المصروفات',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D6EFD),
              ),
            ),
          ],
        ),
        columns: [
          DataColumn(label: _buildTableHeader('التاريخ')),
          DataColumn(label: _buildTableHeader('النوع')),
          DataColumn(label: _buildTableHeader('المبلغ')),
          DataColumn(label: _buildTableHeader('المسؤول')),
          DataColumn(label: _buildTableHeader('ملاحظات')),
          DataColumn(label: _buildTableHeader('إجراءات')),
        ],
        source: ExpensesTableSource(
          expenses: state.expenses,
          onDelete: (expense) => _confirmDelete(context, expense),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.cairo(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(
          fontSize: 14.sp,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: EdgeInsets.all(16.r),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String label) {
    return Text(
      label,
      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp),
    );
  }

  void _confirmDelete(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'حذف المصروف',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا المصروف؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          TextButton(
            onPressed: () {
              if (expense.id != null) {
                context.read<ExpensesCubit>().deleteExpense(expense.id!);
              }
              Navigator.pop(ctx);
            },
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ExpensesTableSource extends DataTableSource {
  final List<Expense> expenses;
  final Function(Expense) onDelete;

  ExpensesTableSource({required this.expenses, required this.onDelete});

  @override
  DataRow? getRow(int index) {
    if (index >= expenses.length) return null;
    final expense = expenses[index];

    return DataRow(
      cells: [
        DataCell(
          Text(
            DateFormat('yyyy-MM-dd').format(expense.date),
            style: GoogleFonts.cairo(fontSize: 13.sp),
          ),
        ),
        DataCell(
          Text(expense.title, style: GoogleFonts.cairo(fontSize: 13.sp)),
        ),
        DataCell(
          Text(
            'SDG ${NumberFormat('#,##0.00').format(expense.amount)}',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: const Color(0xFFDC3545),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Text('المدير العام', style: GoogleFonts.cairo(fontSize: 13.sp)),
        ),
        DataCell(
          Text(
            expense.description ?? '---',
            style: GoogleFonts.cairo(fontSize: 13.sp),
          ),
        ),
        DataCell(
          Center(
            child: InkWell(
              onTap: () => onDelete(expense),
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC3545),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(Icons.delete, color: Colors.white, size: 16.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => expenses.length;

  @override
  int get selectedRowCount => 0;
}

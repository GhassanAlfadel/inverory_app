import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/layout/cubit/navigation_cubit.dart';
import '../../../core/widgets/app_paginated_data_table.dart';
import '../cubit/purchases_cubit.dart';
import '../cubit/purchases_state.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PurchasesCubit(RepositoryProvider.of<AppDatabase>(context))
            ..loadData(),
      child: const PurchasesView(),
    );
  }
}

class PurchasesView extends StatefulWidget {
  const PurchasesView({super.key});

  @override
  State<PurchasesView> createState() => _PurchasesViewState();
}

class _PurchasesViewState extends State<PurchasesView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchasesCubit, PurchasesState>(
      builder: (context, state) {
        return Container(
          color: const Color(0xFFF0F2F5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(24.0.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إدارة المشتريات',
                          style: GoogleFonts.cairo(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        Text(
                          'سجل أوامر الشراء',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<NavigationCubit>()
                          .setScreen(NavigationScreen.addPurchase),
                      icon: Icon(Icons.add_circle, size: 20.r),
                      label: Text(
                        'إضافة أمر شراء جديد',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                  child: _buildPurchasesTable(state),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPurchasesTable(PurchasesState state) {
    if (state is PurchasesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PurchasesLoaded) {
      final filteredHistory = state.purchaseHistory.where((p) {
        final query = _searchQuery.toLowerCase();
        return (p['id'].toString().contains(query)) ||
            (p['supplier_name']?.toLowerCase().contains(query) ?? false) ||
            (p['total_amount'].toString().contains(query));
      }).toList();

      return AppPaginatedDataTable(
        minWidth: 900,
        columnSpacing: 24.w,
        onSearch: (v) => setState(() => _searchQuery = v),
        header: Row(
          children: [
            Icon(
              Icons.list_alt_rounded,
              color: const Color(0xFF0D6EFD),
              size: 20.r,
            ),
            SizedBox(width: 8.w),
            Text(
              'سجل المشتريات',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D6EFD),
              ),
            ),
          ],
        ),
        columns: [
          DataColumn(label: _buildTableHeader('رقم الأمر')),
          DataColumn(label: _buildTableHeader('المورد')),
          DataColumn(label: _buildTableHeader('التاريخ')),
          DataColumn(label: _buildTableHeader('الحالة')),
          DataColumn(label: _buildTableHeader('المبلغ الإجمالي')),
          DataColumn(label: _buildTableHeader('المسؤول')),
          DataColumn(label: _buildTableHeader('إجراءات')),
        ],
        source: PurchasesTableSource(
          purchaseHistory: filteredHistory,
          onView: (id) => context.read<NavigationCubit>().setScreen(
            NavigationScreen.viewPurchase,
            data: id,
          ),
        ),
      );
    }

    return Center(
      child: Text(
        'حدث خطأ في تحميل البيانات',
        style: TextStyle(fontSize: 14.sp),
      ),
    );
  }

  Widget _buildTableHeader(String label) {
    return Text(
      label,
      style: GoogleFonts.cairo(
        fontWeight: FontWeight.bold,
        fontSize: 13.sp,
        color: const Color(0xFF475569),
      ),
    );
  }
}

class PurchasesTableSource extends DataTableSource {
  final List<Map<String, dynamic>> purchaseHistory;
  final Function(int) onView;

  PurchasesTableSource({required this.purchaseHistory, required this.onView});

  @override
  DataRow? getRow(int index) {
    if (index >= purchaseHistory.length) return null;
    final purchase = purchaseHistory[index];

    return DataRow(
      cells: [
        DataCell(
          Text(
            '#${purchase['id']}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1e293b),
              fontSize: 13.sp,
            ),
          ),
        ),
        DataCell(
          Text(
            purchase['supplier_name'] ?? 'غير محدد',
            style: GoogleFonts.cairo(fontSize: 13.sp),
          ),
        ),
        DataCell(
          Text(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(purchase['date'])),
            style: GoogleFonts.cairo(fontSize: 13.sp),
          ),
        ),
        DataCell(_buildStatusBadge('مكتمل')),
        DataCell(
          Text(
            '${NumberFormat('#,##0.00').format(purchase['total_amount'])} SDG',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D6EFD),
              fontSize: 13.sp,
            ),
          ),
        ),
        DataCell(
          Text('المدير العام', style: GoogleFonts.cairo(fontSize: 13.sp)),
        ),
        DataCell(
          Row(
            children: [
              _buildActionIcon(
                Icons.visibility_outlined,
                Colors.cyan,
                () => onView(purchase['id']),
              ),
              SizedBox(width: 8.w),
              _buildActionIcon(Icons.print_outlined, Colors.grey, () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF198754).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        status,
        style: GoogleFonts.cairo(
          color: const Color(0xFF198754),
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(icon, color: color, size: 18.r),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => purchaseHistory.length;

  @override
  int get selectedRowCount => 0;
}

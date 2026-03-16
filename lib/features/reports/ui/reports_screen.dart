import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/app_paginated_data_table.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ReportsCubit(RepositoryProvider.of<AppDatabase>(context))
            ..loadDailyReport(DateTime.now()),
      child: const ReportsView(),
    );
  }
}

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  String _activeTab = 'day'; // 'day', 'month', 'year', 'custom'
  DateTime _selectedDate = DateTime.now();
  DateTime? _customStart;
  DateTime? _customEnd;
  String _searchQuery = '';

  void _onTabChanged(String tab) {
    setState(() {
      _activeTab = tab;
      if (tab != 'custom') {
        _customStart = null;
        _customEnd = null;
      }
    });

    final cubit = context.read<ReportsCubit>();
    switch (tab) {
      case 'day':
        cubit.loadDailyReport(_selectedDate);
        break;
      case 'month':
        cubit.loadMonthlyReport(_selectedDate);
        break;
      case 'year':
        cubit.loadYearlyReport(_selectedDate);
        break;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'AE'),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _onTabChanged(_activeTab);
    }
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customStart ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _customEnd ?? DateTime.now(),
      locale: const Locale('ar', 'AE'),
    );
    if (picked != null) {
      setState(() => _customStart = picked);
      if (_customEnd != null) {
        context.read<ReportsCubit>().loadCustomReport(picked, _customEnd!);
      }
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customEnd ?? DateTime.now(),
      firstDate: _customStart ?? DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'AE'),
    );
    if (picked != null) {
      setState(() => _customEnd = picked);
      if (_customStart != null) {
        context.read<ReportsCubit>().loadCustomReport(_customStart!, picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقارير المالية',
                style: GoogleFonts.cairo(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF334155),
                ),
              ),
              _buildPeriodSwitcher(),
            ],
          ),
          SizedBox(height: 16.h),
          _buildSelectionBar(),
          SizedBox(height: 24.h),
          Expanded(
            child: BlocBuilder<ReportsCubit, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ReportsLoaded) {
                  final filteredProducts = state.productSales.where((p) {
                    final query = _searchQuery.toLowerCase();
                    return p['name'].toLowerCase().contains(query);
                  }).toList();

                  return Column(
                    children: [
                      _buildSummaryGrid(state.totals),
                      SizedBox(height: 24.h),
                      Expanded(
                        child: AppPaginatedDataTable(
                          onSearch: (v) => setState(() => _searchQuery = v),
                          searchPlaceholder: 'بحث عن منتج...',
                          header: Row(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                color: const Color(0xFF0D6EFD),
                                size: 20.r,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'أداء المنتجات',
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0D6EFD),
                                ),
                              ),
                            ],
                          ),
                          columns: [
                            DataColumn(label: _buildTableHeader('اسم المنتج')),
                            DataColumn(
                              label: _buildTableHeader('الكمية المباعة'),
                            ),
                            DataColumn(
                              label: _buildTableHeader('إجمالي المبيعات'),
                            ),
                          ],
                          source: ReportsTableSource(
                            products: filteredProducts,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                if (state is ReportsError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: GoogleFonts.cairo(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (_activeTab != 'custom') ...[
            Icon(
              Icons.calendar_month,
              color: const Color(0xFF0D6EFD),
              size: 20.r,
            ),
            SizedBox(width: 8.w),
            Text(
              _activeTab == 'day'
                  ? 'اختر اليوم:'
                  : _activeTab == 'month'
                  ? 'اختر الشهر:'
                  : 'اختر السنة:',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 12.w),
            _buildPickerButton(
              _activeTab == 'day'
                  ? DateFormat('yyyy-MM-dd').format(_selectedDate)
                  : _activeTab == 'month'
                  ? DateFormat('MMMM yyyy', 'ar').format(_selectedDate)
                  : DateFormat('yyyy').format(_selectedDate),
              _pickDate,
            ),
          ] else ...[
            Icon(Icons.date_range, color: const Color(0xFF0D6EFD), size: 20.r),
            SizedBox(width: 8.w),
            Text(
              'من:',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 8.w),
            _buildPickerButton(
              _customStart != null
                  ? DateFormat('yyyy-MM-dd').format(_customStart!)
                  : 'اختر تاريخ',
              _pickFromDate,
            ),
            SizedBox(width: 24.w),
            Text(
              'إلى:',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 8.w),
            _buildPickerButton(
              _customEnd != null
                  ? DateFormat('yyyy-MM-dd').format(_customEnd!)
                  : 'اختر تاريخ',
              _pickToDate,
            ),
          ],
          const Spacer(),
          _buildCurrentPeriodChip(),
        ],
      ),
    );
  }

  Widget _buildPickerButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPeriodChip() {
    String text = '';
    if (_activeTab == 'day') {
      text = 'تقرير يومي';
    } else if (_activeTab == 'month') {
      text = 'تقرير شهري';
    } else if (_activeTab == 'year') {
      text = 'تقرير سنوي';
    } else {
      text = 'فترة مخصصة';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0D6EFD).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 12.sp,
          color: const Color(0xFF0D6EFD),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPeriodSwitcher() {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton('يومي', 'day'),
          _buildTabButton('شهري', 'month'),
          _buildTabButton('سنوي', 'year'),
          _buildTabButton('فترة مخصصة', 'custom'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String id) {
    final isActive = _activeTab == id;
    return InkWell(
      onTap: () {
        if (id == 'custom') {
          setState(() {
            _activeTab = 'custom';
            _customStart ??= DateTime.now();
            _customEnd ??= DateTime.now();
          });
          context.read<ReportsCubit>().loadCustomReport(
            _customStart!,
            _customEnd!,
          );
        } else {
          _onTabChanged(id);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0D6EFD) : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(Map<String, double> totals) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.8,
      children: [
        _buildSummaryCard(
          'إجمالي المبيعات',
          totals['sales'] ?? 0,
          Icons.attach_money,
          const Color(0xFF17a2b8),
        ),
        _buildSummaryCard(
          'إجمالي المشتريات',
          totals['purchases'] ?? 0,
          Icons.shopping_cart,
          const Color(0xFF20c997),
        ),
        _buildSummaryCard(
          'إجمالي المصروفات',
          totals['expenses'] ?? 0,
          Icons.money_off,
          const Color(0xFFdc3545),
        ),
        _buildSummaryCard(
          'صافي الربح',
          totals['net'] ?? 0,
          Icons.trending_up,
          const Color(0xFF007bff),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(height: 4.h, color: color),
            ),
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFF212529), size: 38.r),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          color: const Color(0xFF17a2b8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        NumberFormat('#,##0.##').format(amount),
                        style: GoogleFonts.cairo(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF212529),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
}

class ReportsTableSource extends DataTableSource {
  final List<Map<String, dynamic>> products;

  ReportsTableSource({required this.products});

  @override
  DataRow? getRow(int index) {
    if (index >= products.length) return null;
    final p = products[index];

    return DataRow(
      cells: [
        DataCell(
          Text(
            p['name'],
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
        ),
        DataCell(
          Text('${p['total_quantity']}', style: TextStyle(fontSize: 13.sp)),
        ),
        DataCell(
          Text(
            '${NumberFormat('#,##0.00').format(p['total_amount'])} SDG',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => products.length;

  @override
  int get selectedRowCount => 0;
}

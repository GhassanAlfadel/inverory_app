import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/layout/cubit/navigation_cubit.dart';
import '../cubit/invoices_cubit.dart';
import '../cubit/invoices_state.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InvoicesCubit(RepositoryProvider.of<AppDatabase>(context))
            ..loadInvoices(),
      child: const InvoicesView(),
    );
  }
}

class InvoicesView extends StatelessWidget {
  const InvoicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إدارة الفواتير',
                style: GoogleFonts.cairo(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.read<NavigationCubit>().setScreen(
                  NavigationScreen.pos,
                ),
                icon: const Icon(Icons.add),
                label: const Text('فاتورة جديدة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: BlocBuilder<InvoicesCubit, InvoicesState>(
              builder: (context, state) {
                if (state is InvoicesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is InvoicesLoaded) {
                  if (state.invoices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64.r,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'لا توجد فواتير مسجلة بعد',
                            style: GoogleFonts.cairo(
                              color: Colors.grey.shade600,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildInvoicesTable(context, state.invoices);
                } else if (state is InvoicesError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesTable(
    BuildContext context,
    List<Map<String, dynamic>> invoices,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF8FAFC),
              ),
              columns: [
                DataColumn(label: Text('رقم الفاتورة', style: _headerStyle())),
                DataColumn(
                  label: Text('التاريخ والوقت', style: _headerStyle()),
                ),
                DataColumn(label: Text('البائع', style: _headerStyle())),
                DataColumn(label: Text('طريقة الدفع', style: _headerStyle())),
                DataColumn(
                  label: Text('المبلغ الإجمالي', style: _headerStyle()),
                ),
                DataColumn(label: Text('إجراءات', style: _headerStyle())),
              ],
              rows: invoices.map((inv) {
                final date = DateTime.parse(inv['date']);
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        '#${inv['id']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(date))),
                    DataCell(Text(inv['seller_name'] ?? 'غير معروف')),
                    DataCell(Text(_getPaymentMethod(inv['payment_method']))),
                    DataCell(
                      Text(
                        '${NumberFormat('#,##0.00').format(inv['total_amount'])} SDG',
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () =>
                            context.read<NavigationCubit>().setScreen(
                              NavigationScreen.invoiceDetails,
                              data: inv['id'],
                            ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _headerStyle() => GoogleFonts.cairo(
    fontWeight: FontWeight.bold,
    fontSize: 14.sp,
    color: const Color(0xFF64748B),
  );

  String _getPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'نقداً';
      case 'card':
        return 'بطاقة';
      default:
        return method;
    }
  }
}

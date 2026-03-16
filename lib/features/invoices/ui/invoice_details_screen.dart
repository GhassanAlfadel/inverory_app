import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/layout/cubit/navigation_cubit.dart';
import '../cubit/invoices_cubit.dart';
import '../cubit/invoices_state.dart';
import '../../../core/utils/invoice_helper.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final int saleId;
  const InvoiceDetailsScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InvoicesCubit(RepositoryProvider.of<AppDatabase>(context))
            ..loadInvoiceDetails(saleId),
      child: const InvoiceDetailsView(),
    );
  }
}

class InvoiceDetailsView extends StatelessWidget {
  const InvoiceDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoicesCubit, InvoicesState>(
      listener: (context, state) {
        if (state is InvoicesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is InvoicesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InvoiceDetailsLoaded) {
          return _buildDetailsBody(context, state.invoice, state.items);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildDetailsBody(
    BuildContext context,
    Map<String, dynamic> invoice,
    List<Map<String, dynamic>> items,
  ) {
    return Container(
      color: const Color(0xFFF1F5F9),
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => context.read<NavigationCubit>().setScreen(
                  NavigationScreen.invoices,
                ),
              ),
              Text(
                'تفاصيل الفاتورة #${invoice['id']}',
                style: GoogleFonts.cairo(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => InvoiceHelper.printInvoice(
                  invoiceId: invoice['id'],
                  date: DateTime.parse(invoice['date']),
                  customerName: 'زبون نقدي', // Default or fetch if available
                  items: items,
                  totalAmount: (invoice['total_amount'] as num).toDouble(),
                  discount: (invoice['discount'] as num).toDouble(),
                ),
                icon: const Icon(Icons.print),
                label: const Text('طباعة الفاتورة'),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildItemsList(context, invoice, items),
              ),
              SizedBox(width: 24.w),
              Expanded(flex: 1, child: _buildSummaryCard(invoice)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    Map<String, dynamic> invoice,
    List<Map<String, dynamic>> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Text(
              'المنتجات المبيعة',
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF334155),
              ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 8.h,
                ),
                title: Text(
                  item['product_name'],
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'سعر الوحدة: ${item['price']} SDG | الكمية: ${item['quantity']}',
                  style: GoogleFonts.cairo(fontSize: 13.sp),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${NumberFormat('#,##0.00').format(item['subtotal'])} SDG',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    _buildReturnButton(context, invoice, item),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReturnButton(
    BuildContext context,
    Map<String, dynamic> invoice,
    Map<String, dynamic> item,
  ) {
    return IconButton(
      icon: const Icon(Icons.keyboard_return, color: Colors.orange),
      tooltip: 'إرجاع المنتج',
      onPressed: () => _showReturnDialog(context, invoice, item),
    );
  }

  void _showReturnDialog(
    BuildContext context,
    Map<String, dynamic> invoice,
    Map<String, dynamic> item,
  ) {
    final controller = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'إرجاع ${item['product_name']}',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الكمية الحالية: ${item['quantity']}',
              style: GoogleFonts.cairo(),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الكمية المراد إرجاعها',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(controller.text) ?? 0;
              if (qty > 0 && qty <= item['quantity']) {
                context.read<InvoicesCubit>().returnItem(
                  invoice['id'],
                  item['id'],
                  qty,
                );
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('كمية غير صالحة')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('إرجاع', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> invoice) {
    final date = DateTime.parse(invoice['date']);
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الفاتورة',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          _summaryRow('رقم الفاتورة', '#${invoice['id']}'),
          _summaryRow('التاريخ', DateFormat('yyyy-MM-dd HH:mm').format(date)),
          _summaryRow('البائع', invoice['seller_name'] ?? '-'),
          _summaryRow(
            'طريقة الدفع',
            _getPaymentMethod(invoice['payment_method']),
          ),
          const Divider(height: 32),
          _summaryRow('الخصم', '${invoice['discount'] ?? 0} SDG'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                '${NumberFormat('#,##0.00').format(invoice['total_amount'])} SDG',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(color: Colors.grey.shade600)),
          Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

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

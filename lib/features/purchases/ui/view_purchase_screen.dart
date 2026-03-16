import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/layout/cubit/navigation_cubit.dart';
import '../cubit/purchase_details_cubit.dart';
import '../cubit/purchase_details_state.dart';

class ViewPurchaseScreen extends StatelessWidget {
  final int purchaseId;

  const ViewPurchaseScreen({super.key, required this.purchaseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PurchaseDetailsCubit(RepositoryProvider.of<AppDatabase>(context))
            ..loadPurchaseDetails(purchaseId),
      child: const ViewPurchaseView(),
    );
  }
}

class ViewPurchaseView extends StatelessWidget {
  const ViewPurchaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseDetailsCubit, PurchaseDetailsState>(
      builder: (context, state) {
        if (state is PurchaseDetailsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PurchaseDetailsLoaded) {
          final purchase = state.purchase;
          final items = state.items;

          return Container(
            color: const Color(0xFFF0F2F5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, purchase['id']),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                    child: Column(
                      children: [
                        _buildInfoSection(purchase),
                        SizedBox(height: 24.h),
                        _buildItemsTable(items, purchase['total_amount']),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is PurchaseDetailsError) {
          return Center(
            child: Text(
              state.message,
              style: GoogleFonts.cairo(color: Colors.red, fontSize: 14.sp),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader(BuildContext context, int orderId) {
    return Padding(
      padding: EdgeInsets.all(24.0.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_forward_ios_rounded, size: 20.r),
                onPressed: () => context.read<NavigationCubit>().setScreen(
                  NavigationScreen.purchases,
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عرض تفاصيل أمر الشراء',
                    style: GoogleFonts.cairo(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  Text(
                    'تفاصيل أمر الشراء رقم: $orderId',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderButton(
                Icons.print_outlined,
                'طباعة',
                Colors.grey.shade700,
                () {},
              ),
              SizedBox(width: 12.w),
              _buildHeaderButton(
                Icons.check_circle_outline,
                'تأكيد الاستلام',
                const Color(0xFF198754),
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18.r, color: color),
      label: Text(
        label,
        style: GoogleFonts.cairo(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> purchase) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInfoGroup('معلومات الفاتورة', [
                _buildInfoItem(
                  'تاريخ الطلب',
                  DateFormat(
                    'yyyy-MM-dd',
                  ).format(DateTime.parse(purchase['date'])),
                ),
                _buildInfoItem('الحالة', 'قيد الانتظار', isStatus: true),
                _buildInfoItem('فرع الاستلام', 'الفرع الرئيسي'),
              ]),
            ),
            VerticalDivider(width: 40.w),
            Expanded(
              child: _buildInfoGroup('معلومات المورد', [
                _buildInfoItem(
                  'اسم المورد',
                  purchase['supplier_name'] ?? 'غير محدد',
                ),
                _buildInfoItem(
                  'رقم الهاتف',
                  purchase['supplier_phone'] ?? '---',
                ),
                _buildInfoItem(
                  'العنوان',
                  purchase['supplier_address'] ?? '---',
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0D6EFD),
          ),
        ),
        SizedBox(height: 16.h),
        ...items,
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.cairo(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
          if (isStatus)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                value,
                style: GoogleFonts.cairo(
                  color: Colors.orange,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Text(
              value,
              style: GoogleFonts.cairo(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(List<Map<String, dynamic>> items, double total) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(24.0.r),
            child: Text(
              'الأصناف المطلوبة',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1e293b),
              ),
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              horizontalMargin: 24.w,
              columnSpacing: 24.w,
              columns: [
                DataColumn(label: _buildTableHeader('#')),
                DataColumn(label: _buildTableHeader('الدواء')),
                DataColumn(label: _buildTableHeader('الكمية')),
                DataColumn(label: _buildTableHeader('سعر الوحدة')),
                DataColumn(label: _buildTableHeader('الإجمالي')),
              ],
              rows: items.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final item = entry.value;
                return DataRow(
                  cells: [
                    DataCell(
                      Text(index.toString(), style: TextStyle(fontSize: 13.sp)),
                    ),
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['product_name'] ?? '',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                          if (item['product_scientific_name'] != null)
                            Text(
                              item['product_scientific_name'],
                              style: GoogleFonts.cairo(
                                fontSize: 10.sp,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        '${item['quantity']} علبة',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${NumberFormat('#,##0.00').format(item['purchase_price'])} SDG',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${NumberFormat('#,##0.00').format(item['quantity'] * item['purchase_price'])} SDG',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(24.0.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'إجمالي الفاتورة: ',
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${NumberFormat('#,##0.00').format(total)} SDG',
                  style: GoogleFonts.cairo(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0D6EFD),
                  ),
                ),
              ],
            ),
          ),
        ],
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

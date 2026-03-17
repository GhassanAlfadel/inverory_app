import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import '../cubit/pos_cubit.dart';
import '../cubit/pos_state.dart';

class POSScreen extends StatelessWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const userId =
        1; // Temporary: Default to admin ID since auth system is simplified

    return BlocProvider(
      create: (context) => POSCubit(RepositoryProvider.of<AppDatabase>(context))
        ..checkShift(userId),
      child: const POSView(),
    );
  }
}

class POSView extends StatefulWidget {
  const POSView({super.key});

  @override
  State<POSView> createState() => _POSViewState();
}

class _POSViewState extends State<POSView> {
  final _searchController = TextEditingController();
  final _discountController = TextEditingController();
  final _startBalanceController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _searchFieldKey = GlobalKey();

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _startBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<POSCubit, POSState>(
      listener: (context, state) {
        if (state is POSActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is POSError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is POSLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is POSNoActiveShift) {
          return _buildStartShiftView(context);
        } else if (state is POSActive) {
          return _buildPOSView(context, state);
        }
        return const Center(child: Text('جاري التحميل...'));
      },
    );
  }

  Widget _buildStartShiftView(BuildContext context) {
    return Center(
      child: Container(
        width: 400.w,
        padding: EdgeInsets.all(32.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.timer_outlined, size: 48.r, color: Colors.blue),
            ),
            SizedBox(height: 24.h),
            Text(
              'بدء وردية جديدة',
              style: GoogleFonts.cairo(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'يرجى إدخال الرصيد الافتتاحي للصندوق لبدء عملية البيع',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14.sp),
            ),
            SizedBox(height: 32.h),
            TextField(
              controller: _startBalanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الرصيد الافتتاحي',
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  final balance =
                      double.tryParse(_startBalanceController.text) ?? 0.0;
                  const userId = 1; // Temporary: Default to admin ID
                  context.read<POSCubit>().startNewShift(userId, balance);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'بدء الوردية الآن',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPOSView(BuildContext context, POSActive state) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            color: const Color(0xFFF1F5F9),
            padding: EdgeInsets.all(24.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildSearchHeader(context, state),
                      SizedBox(height: 24.h),
                      _buildCartTable(context, state),
                    ],
                  ),
                ),
                SizedBox(width: 24.w),
                Expanded(flex: 1, child: _buildSummarySidebar(context, state)),
              ],
            ),
          ),
        ),
        if (state.searchStatus != SearchStatus.initial)
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: _buildSearchResults(context, state),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchHeader(BuildContext context, POSActive state) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.blue,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'اختر دواء لإضافته للفاتورة',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: TextField(
                    controller: _searchController,
                    key: _searchFieldKey,
                    onChanged: (v) =>
                        context.read<POSCubit>().searchProducts(v),
                    onSubmitted: (v) {
                      context.read<POSCubit>().handleBarcodeScan(v);
                      _searchController.clear();
                    },
                    style: GoogleFonts.cairo(fontSize: 15.sp),
                    decoration: InputDecoration(
                      hintText:
                          'ابحث عن الدواء (الاسم، التركيبة، أو الباركود)...',
                      prefixIcon: Icon(
                        Icons.qr_code_scanner,
                        color: Colors.blue.shade300,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<POSCubit>().searchProducts('');
                              },
                            )
                          : const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 1,
                child: Container(
                  height: 56.h, // Match TextField height loosely
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: state.selectedCategoryId,
                      hint: Text(
                        'كل التصنيفات',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      icon: Icon(
                        Icons.filter_list,
                        size: 20.r,
                        color: Colors.blue,
                      ),
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12.r),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'كل التصنيفات',
                            style: GoogleFonts.cairo(fontSize: 14.sp),
                          ),
                        ),
                        ...state.categories.map(
                          (c) => DropdownMenuItem<int?>(
                            value: c.id,
                            child: Text(
                              c.name,
                              style: GoogleFonts.cairo(fontSize: 14.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        context.read<POSCubit>().setCategory(v);
                        // Refresh search with current query
                        context.read<POSCubit>().searchProducts(
                              _searchController.text,
                            );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, POSActive state) {
    Widget content;

    if (state.searchStatus == SearchStatus.searching) {
      content = _buildSearchStatusMessage(
        Icons.sync,
        'جاري البحث عن الأدوية...',
        Colors.blue,
      );
    } else if (state.searchStatus == SearchStatus.noResults) {
      content = _buildSearchStatusMessage(
        Icons.search_off_rounded,
        'لا توجد نتائج مطابقة لبحثك',
        Colors.orange,
      );
    } else {
      content = ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: state.searchResults.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final p = state.searchResults[index];
          return _buildProductSearchResultItem(context, p);
        },
      );
    }

    double? width;
    if (_searchFieldKey.currentContext != null) {
      final RenderBox box =
          _searchFieldKey.currentContext!.findRenderObject() as RenderBox;
      width = box.size.width;
    }

    return Container(
      width: width,
      constraints: BoxConstraints(maxHeight: 400.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Material(child: content),
      ),
    );
  }

  Widget _buildSearchStatusMessage(IconData icon, String message, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48.r, color: color.withOpacity(0.5)),
          SizedBox(height: 16.h),
          Text(
            message,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSearchResultItem(BuildContext context, Product p) {
    final bool isLowStock = p.stock <= 5;
    final bool isOutOfStock = p.stock <= 0;

    final statusColor =
        isOutOfStock ? Colors.red : (isLowStock ? Colors.orange : Colors.green);
    final statusText =
        isOutOfStock ? 'غير متوفر' : (isLowStock ? 'كمية محدودة' : 'متوفر');

    return InkWell(
      onTap: isOutOfStock
          ? null
          : () {
              context.read<POSCubit>().addToCart(p);
              _searchController.clear();
              context.read<POSCubit>().searchProducts('');
            },
      child: Container(
        color: isOutOfStock ? Colors.grey.shade50 : null,
        padding: EdgeInsets.all(16.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.medication_rounded,
                color: statusColor,
                size: 28.r,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.name,
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${p.price.toStringAsFixed(2)} SDG',
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (p.scientificName != null || p.manufacturer != null)
                    Text(
                      '${p.scientificName ?? ''}${p.scientificName != null && p.manufacturer != null ? ' | ' : ''}${p.manufacturer ?? ''}',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (p.processor != null ||
                      p.ram != null ||
                      p.model != null ||
                      p.storage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          if (p.model != null)
                            _buildSpecTag(Icons.computer, p.model!),
                          if (p.processor != null)
                            _buildSpecTag(Icons.memory, p.processor!),
                          if (p.ram != null) _buildSpecTag(Icons.speed, p.ram!),
                          if (p.storage != null)
                            _buildSpecTag(Icons.storage, p.storage!),
                          if (p.color != null)
                            _buildSpecTag(Icons.palette, p.color!),
                        ],
                      ),
                    ),
                  if (p.barcode != null)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        'باركود: ${p.barcode}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _buildStatusBadge(statusText, statusColor),
                      SizedBox(width: 12.w),
                      Text(
                        'المخزون: ${p.stock} علبة',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      if (p.expiryDate != null)
                        Text(
                          'الصلاحية: ${intl.DateFormat('yyyy-MM-dd').format(p.expiryDate!)}',
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            color: const Color(0xFF94A3B8),
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

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCartTable(BuildContext context, POSActive state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.blue,
                  size: 24.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  'فاتورة البيع الحالية',
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'بند: ${state.cart.length}',
                  style: GoogleFonts.cairo(color: Colors.grey),
                ),
              ],
            ),
          ),
          DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            columns: [
              DataColumn(
                label: Text(
                  'الدواء',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'الكمية',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'السعر',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'الإجمالي',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
              const DataColumn(label: Text('')),
            ],
            rows: state.cart.map((item) {
              return DataRow(
                cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.product.name,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            if (item.product.manufacturer != null)
                              Text(
                                '${item.product.manufacturer} | ',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (item.product.barcode != null)
                              Text(
                                item.product.barcode!,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        if (item.product.model != null ||
                            item.product.ram != null)
                          Text(
                            '${item.product.model ?? ''} ${item.product.ram ?? ''} ${item.product.storage ?? ''}',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.blue.shade400,
                            ),
                          ),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQtyBtn(Icons.remove, () {
                          context.read<POSCubit>().updateQuantity(
                                item.product.id!,
                                item.quantity - 1,
                              );
                        }),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            item.quantity.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _buildQtyBtn(Icons.add, () {
                          context.read<POSCubit>().updateQuantity(
                                item.product.id!,
                                item.quantity + 1,
                              );
                        }),
                      ],
                    ),
                  ),
                  DataCell(Text(item.price.toStringAsFixed(2))),
                  DataCell(
                    Text(
                      item.subtotal.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => context.read<POSCubit>().removeFromCart(
                            item.product.id!,
                          ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          if (state.cart.isEmpty)
            Padding(
              padding: EdgeInsets.all(64.r),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64.r,
                    color: Colors.grey.shade200,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'السلة فارغة، ابدأ بإضافة الأدوية',
                    style: GoogleFonts.cairo(color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(icon, size: 14.r, color: Colors.blue),
      ),
    );
  }

  Widget _buildSummarySidebar(BuildContext context, POSActive state) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          _buildSummaryItem('الإجمالي الفرعي:', state.subtotal),
          SizedBox(height: 16.h),
          Text(
            'الخصم',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _discountController,
            onChanged: (v) => context.read<POSCubit>().updateDiscount(
                  double.tryParse(v) ?? 0.0,
                ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixText: 'SDG',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          const Divider(),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المبلغ المطلوب:',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${state.total.toStringAsFixed(2)} SDG',
                style: GoogleFonts.cairo(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Text(
            'طريقة الدفع',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          _buildPaymentOption(context, state, 'كاش', 'cash', Icons.money),
          _buildPaymentOption(
            context,
            state,
            'بنكك - MBOK',
            'bankak',
            Icons.account_balance,
          ),
          _buildPaymentOption(context, state, 'فوري', 'fawry', Icons.flash_on),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 60.h,
            child: ElevatedButton(
              onPressed: state.isProcessing
                  ? null
                  : () => context.read<POSCubit>().finalizeSale(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: state.isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'إتمام العملية (F10)',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16.sp),
        ),
        Text(
          '${value.toStringAsFixed(2)} SDG',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    POSActive state,
    String label,
    String value,
    IconData icon,
  ) {
    final isSelected = state.paymentMethod == value;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: () => context.read<POSCubit>().setPaymentMethod(value),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.blue : const Color(0xFFE2E8F0),
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18.r,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              SizedBox(width: 12.w),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.blue, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecTag(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.r, color: const Color(0xFF1D4ED8)),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }
}

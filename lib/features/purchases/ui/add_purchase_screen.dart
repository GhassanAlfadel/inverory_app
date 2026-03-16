import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import '../cubit/purchases_cubit.dart';
import '../cubit/purchases_state.dart';

class AddPurchaseScreen extends StatelessWidget {
  const AddPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PurchasesCubit(RepositoryProvider.of<AppDatabase>(context))
            ..loadData(),
      child: const AddPurchaseView(),
    );
  }
}

class AddPurchaseView extends StatefulWidget {
  const AddPurchaseView({super.key});

  @override
  State<AddPurchaseView> createState() => _AddPurchaseViewState();
}

class _AddPurchaseViewState extends State<AddPurchaseView> {
  final _notesController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  int? _selectedSupplierId;
  Product? _selectedProduct;
  final _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  @override
  void dispose() {
    _notesController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _resetItemEntry() {
    setState(() {
      _selectedProduct = null;
      _quantityController.clear();
      _priceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchasesCubit, PurchasesState>(
      listener: (context, state) {
        if (state is PurchaseSavedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ أمر الشراء بنجاح')),
          );
          _notesController.clear();
          setState(() => _selectedSupplierId = null);
        } else if (state is PurchasesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is PurchasesLoading && state is! PurchasesLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PurchasesLoaded) {
          return Container(
            color: const Color(0xFFF0F2F5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(24.0.r),
                  child: Text(
                    'إدارة المشتريات',
                    style: GoogleFonts.cairo(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                    child: Column(
                      children: [
                        _buildHeaderCard(state.suppliers),
                        SizedBox(height: 24.h),
                        _buildItemEntryCard(state.products),
                        SizedBox(height: 24.h),
                        _buildPurchasedItemsCard(
                          state.tempItems,
                          state.products,
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Text('حدث خطأ ما', style: TextStyle(fontSize: 14.sp)),
        );
      },
    );
  }

  Widget _buildHeaderCard(List<Supplier> suppliers) {
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
                  Icons.info_outline,
                  color: const Color(0xFF0D6EFD),
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  'تفاصيل أمر الشراء',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D6EFD),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('المورد *'),
                      _buildSupplierDropdown(suppliers),
                    ],
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('تاريخ الطلب *'),
                      _buildTextField(
                        _dateController,
                        'YYYY-MM-DD',
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('ملاحظات'),
                      _buildTextField(
                        _notesController,
                        'أضف ملاحظاتك هنا...',
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemEntryCard(List<Product> products) {
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
                  Icons.add_shopping_cart,
                  color: const Color(0xFF0D6EFD),
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  'إضافة أصناف للأمر',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D6EFD),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('اختر دواء *'),
                      _buildProductDropdown(products),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('الكمية (علب) *'),
                      _buildTextField(
                        _quantityController,
                        '0',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('سعر الشراء للعلبة *'),
                      _buildTextField(
                        _priceController,
                        '0.00',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 24.w),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_selectedProduct != null &&
                        _quantityController.text.isNotEmpty &&
                        _priceController.text.isNotEmpty) {
                      final item = PurchaseItem(
                        purchaseId: 0, // Placeholder
                        productId: _selectedProduct!.id!,
                        quantity: int.tryParse(_quantityController.text) ?? 0,
                        purchasePrice:
                            double.tryParse(_priceController.text) ?? 0.0,
                      );
                      context.read<PurchasesCubit>().addItemToTemp(item);
                      _resetItemEntry();
                    }
                  },
                  icon: Icon(Icons.add, size: 20.r),
                  label: Text(
                    'إضافة',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF198754),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 18.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasedItemsCard(
    List<PurchaseItem> items,
    List<Product> products,
  ) {
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * item.purchasePrice),
    );

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
            child: Row(
              children: [
                Icon(
                  Icons.list_alt_rounded,
                  color: const Color(0xFF0D6EFD),
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  'الأصناف المضافة',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D6EFD),
                  ),
                ),
              ],
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
                DataColumn(label: _buildTableHeader('اسم الدواء')),
                DataColumn(label: _buildTableHeader('الكمية')),
                DataColumn(label: _buildTableHeader('سعر الشراء')),
                DataColumn(label: _buildTableHeader('الإجمالي')),
                DataColumn(label: _buildTableHeader('إجراءات')),
              ],
              rows: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final product = products.firstWhere(
                  (p) => p.id == item.productId,
                );
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        product.name,
                        style: GoogleFonts.cairo(fontSize: 14.sp),
                      ),
                    ),
                    DataCell(
                      Text(
                        item.quantity.toString(),
                        style: GoogleFonts.cairo(fontSize: 14.sp),
                      ),
                    ),
                    DataCell(
                      Text(
                        NumberFormat('#,##0.00').format(item.purchasePrice),
                        style: GoogleFonts.cairo(fontSize: 14.sp),
                      ),
                    ),
                    DataCell(
                      Text(
                        NumberFormat(
                          '#,##0.00',
                        ).format(item.quantity * item.purchasePrice),
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20.r,
                        ),
                        onPressed: () => context
                            .read<PurchasesCubit>()
                            .removeItemFromTemp(index),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.all(32.0.r),
              child: Center(
                child: Text(
                  'لا توجد أصناف مضافة بعد',
                  style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14.sp),
                ),
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(24.0.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'إجمالي الفاتورة: ',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,##0.00').format(subtotal)} SDG',
                      style: GoogleFonts.cairo(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0D6EFD),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // Clear temp items and reset
                        context.read<PurchasesCubit>().loadData();
                        _notesController.clear();
                        setState(() => _selectedSupplierId = null);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'إلغاء الأمر',
                        style: GoogleFonts.cairo(
                          color: Colors.grey.shade700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    ElevatedButton(
                      onPressed: items.isEmpty || _selectedSupplierId == null
                          ? null
                          : () {
                              context.read<PurchasesCubit>().savePurchase(
                                supplierId: _selectedSupplierId!,
                                notes: _notesController.text,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.w,
                          vertical: 16.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'حفظ أمر الشراء',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
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
    bool readOnly = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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

  Widget _buildSupplierDropdown(List<Supplier> suppliers) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedSupplierId,
          hint: Text('اختر المورد', style: GoogleFonts.cairo(fontSize: 14.sp)),
          isExpanded: true,
          items: suppliers
              .map(
                (s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(
                    s.name,
                    style: GoogleFonts.cairo(fontSize: 14.sp),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedSupplierId = v),
        ),
      ),
    );
  }

  Widget _buildProductDropdown(List<Product> products) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Product>(
          value: _selectedProduct,
          hint: Text(
            'ابحث عن دواء...',
            style: GoogleFonts.cairo(fontSize: 14.sp),
          ),
          isExpanded: true,
          items: products
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(
                    p.name,
                    style: GoogleFonts.cairo(fontSize: 14.sp),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            setState(() {
              _selectedProduct = v;
              if (v?.purchasePrice != null) {
                _priceController.text = v!.purchasePrice!.toString();
              }
            });
          },
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

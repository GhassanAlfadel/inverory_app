import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/database/models.dart';
import '../../../core/layout/cubit/navigation_cubit.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _priceController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _stockController;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name);
    _barcodeController = TextEditingController(text: p?.barcode);
    _priceController = TextEditingController(text: p?.price.toString());
    _purchasePriceController = TextEditingController(
      text: p?.purchasePrice?.toString(),
    );
    _stockController = TextEditingController(text: p?.stock.toString());
    _selectedCategoryId = p?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _purchasePriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار التصنيف')));
        return;
      }

      final product = Product(
        id: widget.product?.id,
        name: _nameController.text,
        barcode: _barcodeController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        purchasePrice: double.tryParse(_purchasePriceController.text),
        stock: int.tryParse(_stockController.text) ?? 0,
        categoryId: _selectedCategoryId!,
      );

      if (widget.product == null) {
        context.read<ProductsCubit>().addProduct(product);
      } else {
        context.read<ProductsCubit>().updateProduct(product);
      }
      context.read<NavigationCubit>().setScreen(NavigationScreen.medicines);
    }
  }

  void _autoSelectCategory(List<Category> allCategories) {
    if (widget.product != null || _selectedCategoryId != null) return;

    final generalCats = allCategories.where((c) {
      final name = c.name.toLowerCase();
      return ![
        'هاتف',
        'هواتف',
        'phone',
        'لاب',
        'laptop',
        'ملحق',
        'accessory',
      ].any((s) => name.contains(s));
    }).toList();

    if (generalCats.isNotEmpty) {
      final exactMatch = generalCats.firstWhere(
        (c) => c.name == 'عام',
        orElse: () => generalCats.first,
      );
      setState(() {
        _selectedCategoryId = exactMatch.id;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<ProductsCubit>().state;
    if (state is ProductsLoaded) {
      _autoSelectCategory(state.categories);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductsLoaded) {
          _autoSelectCategory(state.categories);
        }
      },
      child: Column(
        children: [
          // Header Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              children: [
                Text(
                  widget.product == null ? 'إضافة منتج عام جديد' : 'تعديل منتج',
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1a233a),
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => context.read<NavigationCubit>().setScreen(
                    NavigationScreen.medicines,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 24.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.cairo(
                      color: Colors.grey.shade700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 32.w,
                    ),
                    backgroundColor: const Color(0xFF0d6efd),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.product == null
                        ? 'حفظ المنتج العام'
                        : 'حفظ التعديلات',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0.r),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('المعلومات الأساسية'),
                        _buildTextField(
                          _nameController,
                          'اسم المنتج',
                          isRequired: true,
                        ),
                        _buildTextField(
                          _barcodeController,
                          'الباركود (اختياري)',
                          keyboardType: TextInputType.text,
                        ),
                        Row(
                          children: [
                            Expanded(child: _buildCategoryDropdown()),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildTextField(
                                _stockController,
                                'الكمية المتوفرة',
                                keyboardType: TextInputType.number,
                                isRequired: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildSectionTitle('الأسعار'),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _priceController,
                                'سعر البيع',
                                keyboardType: TextInputType.number,
                                isRequired: true,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildTextField(
                                _purchasePriceController,
                                'سعر التكلفة',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1a233a),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        List<Category> categories = [];
        if (state is ProductsLoaded) {
          categories = state.categories.where((c) {
            if (c.id == _selectedCategoryId) return true;
            final name = c.name.toLowerCase();
            return ![
              'هاتف',
              'هواتف',
              'phone',
              'لاب',
              'laptop',
              'ملحق',
              'accessory',
            ].any((s) => name.contains(s));
          }).toList();
        }
        return Padding(
          padding: EdgeInsets.only(bottom: 20.0.h),
          child: DropdownButtonFormField<int>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: 'التصنيف',
              labelStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            items: categories
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name, style: TextStyle(fontSize: 14.sp)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedCategoryId = v),
            validator: (v) => v == null ? 'مطلوب' : null,
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.0.h),
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
          alignLabelWithHint: maxLines > 1,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(
              color: const Color(0xFF0d6efd),
              width: 1.5.w,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        },
      ),
    );
  }
}

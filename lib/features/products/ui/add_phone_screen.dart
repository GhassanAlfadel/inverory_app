import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/database/models.dart';
import '../../../core/layout/cubit/navigation_cubit.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';

class AddPhoneScreen extends StatefulWidget {
  final Product? product;

  const AddPhoneScreen({super.key, this.product});

  @override
  State<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends State<AddPhoneScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _manufacturerController;
  late TextEditingController _modelController;
  late TextEditingController _ramController;
  late TextEditingController _storageController;
  late TextEditingController _colorController;
  late TextEditingController _barcodeController;
  late TextEditingController _priceController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name);
    _manufacturerController = TextEditingController(text: p?.manufacturer);
    _modelController = TextEditingController(text: p?.model);
    _ramController = TextEditingController(text: p?.ram);
    _storageController = TextEditingController(text: p?.storage);
    _colorController = TextEditingController(text: p?.color);
    _priceController = TextEditingController(text: p?.price.toString());
    _barcodeController = TextEditingController(text: p?.barcode);
    _purchasePriceController = TextEditingController(
      text: p?.purchasePrice?.toString(),
    );
    _stockController = TextEditingController(text: p?.stock.toString());
    _descController = TextEditingController(text: p?.description);
    _selectedCategoryId = p?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _colorController.dispose();
    _priceController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _stockController.dispose();
    _descController.dispose();
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
        manufacturer: _manufacturerController.text,
        model: _modelController.text,
        ram: _ramController.text,
        storage: _storageController.text,
        color: _colorController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        purchasePrice: double.tryParse(_purchasePriceController.text),
        stock: int.tryParse(_stockController.text) ?? 0,
        categoryId: _selectedCategoryId!,
        description: _descController.text,
      );

      if (widget.product == null) {
        context.read<ProductsCubit>().addProduct(product);
      } else {
        context.read<ProductsCubit>().updateProduct(product);
      }
      context.read<NavigationCubit>().setScreen(NavigationScreen.medicines);
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
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              children: [
                Text(
                  widget.product == null ? 'إضافة هاتف جديد' : 'تعديل هاتف',
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1a233a),
                  ),
                ),
                const Spacer(),
                _buildActions(),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('المعلومات الأساسية'),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildTextField(
                                _nameController,
                                'اسم الهاتف',
                                isRequired: true,
                              ),
                              _buildTextField(
                                _barcodeController,
                                'الباركود (اختياري)',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            _manufacturerController,
                            'الشركة (Company)',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildCategoryDropdown()),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Row(
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
                        ),
                      ],
                    ),
                    _buildTextField(
                      _stockController,
                      'الكمية المتوفرة',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                    ),

                    SizedBox(height: 16.h),
                    _buildSectionTitle('المواصفات'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _modelController,
                            'الموديل (Model)',
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            _colorController,
                            'اللون (Color)',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_ramController, 'الرام (RAM)'),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            _storageController,
                            'مساحة التخزين (Storage)',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),
                    _buildSectionTitle('تفاصيل إضافية'),
                    _buildTextField(_descController, 'الوصف', maxLines: 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _autoSelectCategory(List<Category> allCategories) {
    if (widget.product != null || _selectedCategoryId != null) return;

    final phoneCategories = allCategories.where((c) {
      final name = c.name.toLowerCase();
      return name.contains('هاتف') ||
          name.contains('هواتف') ||
          name.contains('phone') ||
          name.contains('mobile');
    }).toList();

    if (phoneCategories.isNotEmpty) {
      setState(() {
        _selectedCategoryId = phoneCategories.first.id;
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

  Widget _buildActions() {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => context.read<NavigationCubit>().setScreen(
            NavigationScreen.medicines,
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
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
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 32.w),
            backgroundColor: const Color(0xFF0d6efd),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            elevation: 0,
          ),
          child: Text(
            widget.product == null ? 'حفظ الهاتف' : 'حفظ التعديلات',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
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
          color: const Color(0xFF0d6efd),
        ),
      ),
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
      padding: EdgeInsets.only(bottom: 20.h),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.cairo(fontSize: 14.sp),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(
            color: Colors.grey.shade600,
            fontSize: 14.sp,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (v) =>
            isRequired && (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
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
            return name.contains('هاتف') ||
                name.contains('هواتف') ||
                name.contains('phone') ||
                name.contains('mobile');
          }).toList();
        }
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: DropdownButtonFormField<int>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: 'التصنيف',
              labelStyle: GoogleFonts.cairo(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: categories
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategoryId = v),
            validator: (v) => v == null ? 'مطلوب' : null,
          ),
        );
      },
    );
  }
}

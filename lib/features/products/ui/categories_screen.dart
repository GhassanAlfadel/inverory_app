import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import '../../../core/widgets/app_paginated_data_table.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProductsCubit(RepositoryProvider.of<AppDatabase>(context))
            ..loadProducts(),
      child: const CategoriesView(),
    );
  }
}

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Category? _editingCategory;
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final category = Category(
        id: _editingCategory?.id,
        name: _nameController.text,
        description: _descriptionController.text,
      );

      if (_editingCategory == null) {
        context.read<ProductsCubit>().addCategory(category);
      } else {
        context.read<ProductsCubit>().updateCategory(category);
      }

      setState(() {
        _editingCategory = null;
        _nameController.clear();
        _descriptionController.clear();
      });
    }
  }

  void _onEdit(Category category) {
    setState(() {
      _editingCategory = category;
      _nameController.text = category.name;
      _descriptionController.text = category.description ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductsLoaded) {
          final filteredCategories = state.categories.where((cat) {
            final query = _searchQuery.toLowerCase();
            return cat.name.toLowerCase().contains(query) ||
                (cat.description?.toLowerCase().contains(query) ?? false);
          }).toList();

          return Container(
            color: const Color(0xFFF0F2F5),
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة التصنيفات',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Right: Add/Edit Form
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(20.0.r),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _editingCategory == null
                                              ? Icons.add_circle_outline
                                              : Icons.edit_note,
                                          color: Colors.blue,
                                          size: 24.r,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          _editingCategory == null
                                              ? 'إضافة تصنيف جديد'
                                              : 'تعديل التصنيف',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    TextFormField(
                                      controller: _nameController,
                                      style: TextStyle(fontSize: 14.sp),
                                      decoration: InputDecoration(
                                        labelText: 'اسم التصنيف',
                                        labelStyle: TextStyle(fontSize: 14.sp),
                                        border: const OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 16.h,
                                        ),
                                      ),
                                      validator: (v) =>
                                          v!.isEmpty ? 'مطلوب' : null,
                                    ),
                                    SizedBox(height: 16.h),
                                    TextFormField(
                                      controller: _descriptionController,
                                      style: TextStyle(fontSize: 14.sp),
                                      decoration: InputDecoration(
                                        labelText: 'الوصف',
                                        labelStyle: TextStyle(fontSize: 14.sp),
                                        border: const OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 16.h,
                                        ),
                                      ),
                                      maxLines: 3,
                                    ),
                                    SizedBox(height: 20.h),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 45.h,
                                      child: ElevatedButton.icon(
                                        onPressed: _onSave,
                                        icon: Icon(
                                          _editingCategory == null
                                              ? Icons.add
                                              : Icons.save,
                                          size: 18.r,
                                        ),
                                        label: Text(
                                          _editingCategory == null
                                              ? 'إضافة تصنيف'
                                              : 'حفظ التعديلات',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_editingCategory != null) ...[
                                      SizedBox(height: 8.h),
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton(
                                          onPressed: () => setState(() {
                                            _editingCategory = null;
                                            _nameController.clear();
                                            _descriptionController.clear();
                                          }),
                                          child: Text(
                                            'إلغاء التعديل',
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 24.w),

                      Expanded(
                        flex: 2,
                        child: AppPaginatedDataTable(
                          minWidth: 600,
                          onSearch: (q) => setState(() => _searchQuery = q),
                          header: Row(
                            children: [
                              Icon(Icons.list, color: Colors.blue, size: 24.r),
                              SizedBox(width: 8.w),
                              const Text('قائمة التصنيفات'),
                            ],
                          ),
                          columns: const [
                            DataColumn(label: Text('الرقم')),
                            DataColumn(label: Text('الاسم')),
                            DataColumn(label: Text('الوصف')),
                            DataColumn(label: Text('إجراءات')),
                          ],
                          source: CategoriesTableSource(
                            categories: filteredCategories,
                            onEdit: _onEdit,
                            onDelete: (category) =>
                                _confirmDelete(context, category),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('حدث خطأ ما'));
      },
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'حذف التصنيف',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من حذف ${category.name}؟',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: TextStyle(fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () {
              if (category.id != null) {
                context.read<ProductsCubit>().deleteCategory(category.id!);
              }
              Navigator.pop(ctx);
            },
            child: Text(
              'حذف',
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesTableSource extends DataTableSource {
  final List<Category> categories;
  final Function(Category) onEdit;
  final Function(Category) onDelete;

  CategoriesTableSource({
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= categories.length) return null;
    final category = categories[index];

    return DataRow(
      cells: [
        DataCell(Text(category.id?.toString() ?? '-')),
        DataCell(
          Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(Text(category.description ?? '-')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: Icons.edit,
                color: Colors.cyan,
                onPressed: () => onEdit(category),
              ),
              SizedBox(width: 8.w),
              _buildActionButton(
                icon: Icons.delete,
                color: Colors.red,
                onPressed: () => onDelete(category),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 30.r,
      height: 30.r,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16.r, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => categories.length;

  @override
  int get selectedRowCount => 0;
}

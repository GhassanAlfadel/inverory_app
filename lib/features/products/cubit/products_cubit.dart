import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final AppDatabase database;

  ProductsCubit(this.database) : super(ProductsInitial());

  Future<void> loadProducts() async {
    emit(ProductsLoading());
    try {
      final categories = await database.getCategories();

      // Ensure default categories exist for electronics shop
      final defaultNames = ['هواتف', 'لاب توب', 'ملحقات', 'عام'];
      bool needsReload = false;
      for (var name in defaultNames) {
        if (!categories.any((c) => c.name == name)) {
          await database.addCategory(Category(name: name));
          needsReload = true;
        }
      }

      final finalCategories = needsReload
          ? await database.getCategories()
          : categories;
      final products = await database.getProducts();
      emit(ProductsLoaded(products: products, categories: finalCategories));
    } catch (e) {
      emit(ProductsError('Failed to load products: $e'));
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await database.addProduct(product);
      loadProducts();
    } catch (e) {
      emit(ProductsError('Failed to add product: $e'));
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await database.updateProduct(product);
      loadProducts();
    } catch (e) {
      emit(ProductsError('Failed to update product: $e'));
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await database.deleteProduct(id);
      loadProducts();
    } catch (e) {
      emit(ProductsError('Failed to delete product: $e'));
    }
  }

  // Category Management
  Future<void> addCategory(Category category) async {
    try {
      await database.addCategory(category);
      loadProducts();
    } catch (e) {
      emit(ProductsError('Failed to add category: $e'));
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await database.updateCategory(category);
      loadProducts();
    } catch (e) {
      emit(ProductsError('Failed to update category: $e'));
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await database.deleteCategory(id);
      loadProducts();
    } catch (e) {
      emit(ProductsError('Failed to delete category: $e'));
    }
  }
}

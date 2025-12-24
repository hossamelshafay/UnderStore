import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repos/home_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo homeRepo;

  HomeCubit(this.homeRepo) : super(HomeInitial());

  Future<void> loadProducts() async {
    emit(HomeLoading());
    try {
      final products = await homeRepo.getAllProducts();
      final categories = await homeRepo.getCategories();
      emit(HomeLoaded(products: products, categories: categories));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> loadProductsByCategory(String category) async {
    emit(HomeLoading());
    try {
      final products = category == 'All'
          ? await homeRepo.getAllProducts()
          : await homeRepo.getProductsByCategory(category);
      final categories = await homeRepo.getCategories();
      emit(
        HomeLoaded(
          products: products,
          categories: categories,
          selectedCategory: category,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../manager/cubit/home_cubit.dart';
import '../../data/repos/home_repo_imp.dart';
import '../widgets/delivery_banner.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/section_header_widget.dart';
import '../widgets/categories_list_widget.dart';
import '../widgets/products_grid_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../../../product_details/presentation/views/product_detail_screen.dart';
import '../../../cart/data/repos/cart_repo_imp.dart';
import '../../../cart/presentation/views/cart_screen.dart';
import '../../../search/presentation/views/search_screen.dart';
import '../../../profile/data/repos/profile_repo_imp.dart';
import '../../../profile/presentation/manager/cubit/profile_cubit.dart';
import '../../../profile/presentation/views/profile_screen.dart';
import '../../../orders/presentation/views/orders_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit _homeCubit;
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0;
  int _cartItemCount = 0;
  Set<int> _productsInCart = {};
  String _userLocation = 'Loading location...';

  @override
  void initState() {
    super.initState();
    final homeRepo = HomeRepoImp();
    _homeCubit = HomeCubit(homeRepo);
    _homeCubit.loadProducts();
    _loadCartItemCount();
    _loadProductsInCart();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileRepo = ProfileRepoImp(prefs);
      final user = await profileRepo.getCurrentUser();
      if (mounted && user != null) {
        setState(() {
          _userLocation = user.location ?? 'Set your location';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userLocation = 'Location not set';
        });
      }
    }
  }

  Future<void> _loadCartItemCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartRepo = CartRepoImp(prefs);
      final count = await cartRepo.getCartItemCount();
      if (mounted) {
        setState(() {
          _cartItemCount = count;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadProductsInCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartRepo = CartRepoImp(prefs);
      final cart = await cartRepo.getCart();
      if (mounted) {
        setState(() {
          _productsInCart = cart.items.map((item) => item.product.id).toSet();
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _addToCart(product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartRepo = CartRepoImp(prefs);
      await cartRepo.addToCart(product, 1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.title} added to cart!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        // Refresh cart count and products in cart
        _loadCartItemCount();
        _loadProductsInCart();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item to cart: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      // Navigate to Cart Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      ).then((_) {
        // Refresh cart count and products when returning from cart screen
        _loadCartItemCount();
        _loadProductsInCart();
      });
    } else if (index == 2) {
      // Navigate to Search Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    } else if (index == 3) {
      // Navigate to Orders Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OrdersPage()),
      );
    } else if (index == 4) {
      // Navigate to Profile Screen
      _navigateToProfile();
    } else {
      // For Home tab
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _navigateToProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => ProfileCubit(ProfileRepoImp(prefs)),
              child: const ProfileScreen(),
            ),
          ),
        );

        // Reload location when returning from profile
        if (result == true || mounted) {
          _loadUserLocation();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _homeCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E21),
        appBar: HomeAppBar(userLocation: _userLocation),
        body: Column(
          children: [
            // Delivery Banner
            const DeliveryBanner(),

            // Content
            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5145FC),
                      ),
                    );
                  } else if (state is HomeError) {
                    return ErrorStateWidget(
                      message: state.message,
                      onRetry: () => _homeCubit.loadProducts(),
                    );
                  } else if (state is HomeLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categories Section
                        const SectionHeaderWidget(title: 'Categories'),

                        // Categories List
                        CategoriesListWidget(
                          categories: state.categories,
                          selectedCategory: state.selectedCategory,
                          onCategoryTap: (category) =>
                              _homeCubit.loadProductsByCategory(category),
                        ),

                        // Products Section
                        const SectionHeaderWidget(title: 'Flash Sale'),

                        // Products Grid
                        Expanded(
                          child: ProductsGridWidget(
                            products: state.products,
                            productsInCart: _productsInCart,
                            onProductTap: (product) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    product: product,
                                  ),
                                ),
                              ).then((_) {
                                _loadCartItemCount();
                                _loadProductsInCart();
                              });
                            },
                            onAddToCart: _addToCart,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: HomeBottomNavBar(
          currentIndex: _currentIndex,
          cartItemCount: _cartItemCount,
          onTap: _onBottomNavTapped,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _homeCubit.close();
    _searchController.dispose();
    super.dispose();
  }
}

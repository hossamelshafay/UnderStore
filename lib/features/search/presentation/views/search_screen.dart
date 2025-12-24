import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/search_empty_state.dart';
import '../widgets/search_results_header.dart';
import '../../../home/presentation/widgets/product_card.dart';
import '../../../home/data/models/product_model.dart';
import '../manager/cubit/search_cubit.dart';
import '../../data/repos/search_repo_imp.dart';
import '../../../cart/data/repos/cart_repo_imp.dart';
import '../../../product_details/presentation/views/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  SearchCubit? _searchCubit;
  Set<int> _productsInCart = {};

  @override
  void initState() {
    super.initState();
    _initializeSearch();
    _loadProductsInCart();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  Future<void> _initializeSearch() async {
    final searchRepo = SearchRepoImp();
    setState(() {
      _searchCubit = SearchCubit(searchRepo);
    });
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

  Future<void> _addToCart(ProductModel product) async {
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

  void _performSearch(String query) {
    _searchCubit?.searchProducts(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchCubit?.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    if (_searchCubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider(
      create: (context) => _searchCubit!,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E21),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1F3A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Search Products',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: CustomSearchBar(
                controller: _searchController,
                onFilterTap: () {},
                onChanged: _performSearch,
              ),
            ),

            // Search Results
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SearchError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${state.message}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is SearchLoaded) {
                    if (state.products.isEmpty) {
                      return SearchEmptyState(
                        query: state.query,
                        onClearSearch: _clearSearch,
                      );
                    }
                    return Column(
                      children: [
                        SearchResultsHeader(
                          resultCount: state.products.length,
                          query: state.query,
                        ),
                        Expanded(child: _buildSearchResults(state.products)),
                      ],
                    );
                  }
                  return SearchEmptyState(
                    query: '',
                    onClearSearch: _clearSearch,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isInCart = _productsInCart.contains(product.id);
        return ProductCard(
          product: product,
          isInCart: isInCart,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            ).then((_) {
              // Refresh cart when returning from product details
              _loadProductsInCart();
            });
          },
          onFavoriteToggle: () {},
          onAddToCart: () => _addToCart(product),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchCubit?.close();
    super.dispose();
  }
}

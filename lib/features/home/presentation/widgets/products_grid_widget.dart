import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../widgets/product_card.dart';

class ProductsGridWidget extends StatelessWidget {
  final List<ProductModel> products;
  final Set<int> productsInCart;
  final Function(ProductModel) onProductTap;
  final Function(ProductModel) onAddToCart;

  const ProductsGridWidget({
    super.key,
    required this.products,
    required this.productsInCart,
    required this.onProductTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isInCart = productsInCart.contains(product.id);
        return ProductCard(
          product: product,
          isInCart: isInCart,
          onTap: () => onProductTap(product),
          onFavoriteToggle: () {},
          onAddToCart: () => onAddToCart(product),
        );
      },
    );
  }
}

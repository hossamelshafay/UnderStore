import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home/data/models/product_model.dart';
import '../../data/repos/prod_repo_imp.dart';
import '../manager/cubit/product_details_cubit.dart';
import '../widgets/product_3d_viewer.dart';
import '../widgets/product_info_section.dart';

import '../widgets/add_to_cart_button.dart';
import '../widgets/delivery_info.dart';
import '../../../cart/presentation/widgets/cart_badge.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  OrderCubit? _orderCubit;

  @override
  void initState() {
    super.initState();
    _initializeOrderCubit();
  }

  Future<void> _initializeOrderCubit() async {
    final prefs = await SharedPreferences.getInstance();
    final orderRepo = OrderRepoImp(prefs);
    setState(() {
      _orderCubit = OrderCubit(orderRepo);
    });
    _orderCubit!.loadProductDetail(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    if (_orderCubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider(
      create: (context) => _orderCubit!,
      child: BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
            // Navigate back to home screen after successful add to cart
            Navigator.of(context).pop();
          } else if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0A0E21),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1F3A),
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E1A47),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF5145FC).withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5145FC).withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              const CartBadge(),
              const SizedBox(width: 8),
            ],
          ),
          body: BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              if (state is ProductDetailLoaded) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Product3DViewer(
                              productImage: state.product.image,
                              productTitle: state.product.title,
                            ),

                            const SizedBox(height: 24),

                            ProductInfoSection(product: state.product),

                            const SizedBox(height: 24),

                            // Delivery Info
                            const DeliveryInfo(),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),

                    // Add to Cart Button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F3A),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5145FC).withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: BlocBuilder<OrderCubit, OrderState>(
                          builder: (context, cartState) {
                            final isLoading = cartState is OrderLoading;
                            return AddToCartButton(
                              product: state.product,
                              quantity: state.selectedQuantity,
                              isLoading: isLoading,
                              onQuantityChanged: (quantity) {
                                _orderCubit?.updateQuantity(quantity);
                              },
                              onAddToCart: () {
                                _orderCubit?.addToCart(
                                  state.product,
                                  state.selectedQuantity,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _orderCubit?.close();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repos/cart_repo_imp.dart';
import '../../../orders/presentation/views/checkout_page.dart';
import '../../../orders/presentation/manager/cubit/orders_cubit.dart';
import '../../../orders/data/repos/orders_repo_imp.dart';
import '../manager/cubit/cart_cubit.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_summary.dart';
import '../widgets/empty_cart_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartCubit? _cartCubit;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartRepo = CartRepoImp(prefs);
    setState(() {
      _cartCubit = CartCubit(cartRepo);
    });
    _cartCubit!.loadCart();
  }

  @override
  void dispose() {
    _cartCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cartCubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider(
      create: (context) => _cartCubit!,
      child: BlocListener<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Automatically load the updated cart
            _cartCubit!.loadCart();
          } else if (state is CartError) {
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
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF1A1F3A),
                    const Color(0xFF5145FC).withOpacity(0.1),
                  ],
                ),
              ),
            ),
            title: const Text(
              'My cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: [Shadow(color: Color(0xFF5145FC), blurRadius: 10)],
              ),
            ),
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
                    color: const Color(0xFF5145FC).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
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
                padding: EdgeInsets.zero,
              ),
            ),
            actions: [
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (state is CartLoaded && state.cart.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(
                        right: 12,
                        top: 8,
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          _showClearCartDialog(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CartLoaded) {
                if (state.cart.isEmpty) {
                  return EmptyCartWidget(
                    onShopNow: () {
                      Navigator.pop(context);
                    },
                  );
                }

                return Column(
                  children: [
                    // Cart Items List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: state.cart.items.length,
                        itemBuilder: (context, index) {
                          final item = state.cart.items[index];
                          return CartItemWidget(
                            item: item,
                            onRemove: () {
                              _cartCubit!.removeFromCart(item.id);
                            },
                            onQuantityChanged: (quantity) {
                              _cartCubit!.updateQuantity(item.id, quantity);
                            },
                          );
                        },
                      ),
                    ),

                    // Cart Summary
                    CartSummary(
                      cart: state.cart,
                      onCheckout: () {
                        _handleCheckout(context, state.cart);
                      },
                    ),
                  ],
                );
              } else if (state is CartError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _cartCubit!.loadCart();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return EmptyCartWidget(
                onShopNow: () {
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text(
            'Are you sure you want to remove all items from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cartCubit!.clearCart();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _handleCheckout(BuildContext context, cart) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersRepo = OrdersRepoImp(prefs);

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => OrdersCubit(ordersRepo),
          child: CheckoutPage(cartItems: cart.items, totalAmount: cart.total),
        ),
      ),
    );
  }
}

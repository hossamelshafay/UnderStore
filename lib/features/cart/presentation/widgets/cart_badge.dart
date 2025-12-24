import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repos/cart_repo_imp.dart';
import '../manager/cubit/cart_cubit.dart';
import '../views/cart_screen.dart';

class CartBadge extends StatefulWidget {
  const CartBadge({super.key});

  @override
  State<CartBadge> createState() => _CartBadgeState();
}

class _CartBadgeState extends State<CartBadge> {
  CartCubit? _cartCubit;
  int _itemCount = 0;

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
    _loadItemCount();
  }

  Future<void> _loadItemCount() async {
    if (_cartCubit != null) {
      final count = await _cartCubit!.getCartItemCount();
      setState(() {
        _itemCount = count;
      });
    }
  }

  @override
  void dispose() {
    _cartCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
            _loadItemCount();
          },
        ),
        if (_itemCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                _itemCount > 99 ? '99+' : _itemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

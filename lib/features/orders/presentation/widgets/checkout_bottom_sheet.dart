import 'package:flutter/material.dart';

class CheckoutBottomSheet extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onBuyNow;

  const CheckoutBottomSheet({
    super.key,
    required this.isEnabled,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF5145FC).withOpacity(0.3),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5145FC).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: !isEnabled ? Colors.grey[800] : const Color(0xFF1A1F3A),
            borderRadius: BorderRadius.circular(16),
            border: !isEnabled
                ? null
                : Border.all(color: const Color(0xFF5145FC), width: 2),
            boxShadow: !isEnabled
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF5145FC).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFF5145FC).withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: !isEnabled ? null : onBuyNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Buy Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: !isEnabled ? Colors.grey[600] : Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: !isEnabled ? Colors.grey[600] : Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

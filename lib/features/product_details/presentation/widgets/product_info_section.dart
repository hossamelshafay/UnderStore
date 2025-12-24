import 'package:flutter/material.dart';
import '../../../home/data/models/product_model.dart';

class ProductInfoSection extends StatefulWidget {
  final ProductModel product;

  const ProductInfoSection({super.key, required this.product});

  @override
  State<ProductInfoSection> createState() => _ProductInfoSectionState();
}

class _ProductInfoSectionState extends State<ProductInfoSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Title
        Text(
          widget.product.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 12),

        // Rating and Reviews
        Row(
          children: [
            // Star Rating
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < widget.product.rating.rate.floor()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.product.rating.rate}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.product.rating.count} reviews',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '94%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF5145FC).withOpacity(0.3),
                ),
              ),
              child: Text(
                '${widget.product.rating.count}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Price Section
        Row(
          children: [
            Text(
              '£${widget.product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'from £${(widget.product.price * 0.08).toStringAsFixed(0)} per month',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const Spacer(),
            const Icon(Icons.info_outline, color: Colors.white70, size: 20),
          ],
        ),

        const SizedBox(height: 20),

        // Description
        Text(
          widget.product.description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
            height: 1.5,
          ),
          maxLines: _isExpanded ? null : 2,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Read more/Read less link
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(
            _isExpanded ? 'Read less' : 'Read more',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF5145FC),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

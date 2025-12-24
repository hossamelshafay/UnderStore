import 'package:flutter/material.dart';

class SearchResultsHeader extends StatelessWidget {
  final int resultCount;
  final String query;

  const SearchResultsHeader({
    super.key,
    required this.resultCount,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                children: [
                  TextSpan(
                    text:
                        '$resultCount ${resultCount == 1 ? 'result' : 'results'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (query.isNotEmpty) ...[
                    const TextSpan(text: ' for '),
                    TextSpan(
                      text: '"$query"',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5145FC),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

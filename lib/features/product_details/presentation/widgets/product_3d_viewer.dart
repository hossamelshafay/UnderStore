import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Product3DViewer extends StatefulWidget {
  final String productImage;
  final String productTitle;

  const Product3DViewer({
    super.key,
    required this.productImage,
    required this.productTitle,
  });

  @override
  State<Product3DViewer> createState() => _Product3DViewerState();
}

class _Product3DViewerState extends State<Product3DViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _is3DMode = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle3DMode() {
    setState(() {
      _is3DMode = !_is3DMode;
      if (_is3DMode) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _is3DMode
              ? Container(
                  key: const ValueKey('3d'),
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF5145FC).withOpacity(0.1),
                        const Color(0xFFEC4899).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ModelViewer(
                      backgroundColor: Colors.transparent,
                      src:
                          'https://modelviewer.dev/shared-assets/models/Astronaut.glb', // Replace with any 3D model to me
                      alt: widget.productTitle,
                      ar: true,
                      autoRotate: true,
                      cameraControls: true,
                      shadowIntensity: 0.7,
                      shadowSoftness: 0.5,
                      loading: Loading.eager,
                      interactionPrompt: InteractionPrompt.auto,
                    ),
                  ),
                )
              : Container(
                  key: const ValueKey('2d'),
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A1F3A),
                        const Color(0xFF2E1A47).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF5145FC).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5145FC).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Hero(
                    tag: 'product-${widget.productImage}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.productImage,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF1A1F3A),
                                  const Color(0xFF2E1A47),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Color(0xFF5145FC),
                              size: 80,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
        ),

        // Toggle Button
        Positioned(
          bottom: 20,
          right: 20,
          child: GestureDetector(
            onTap: _toggle3DMode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _is3DMode
                      ? [const Color(0xFFEC4899), const Color(0xFFF97316)]
                      : [const Color(0xFF5145FC), const Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color:
                        (_is3DMode
                                ? const Color(0xFFEC4899)
                                : const Color(0xFF5145FC))
                            .withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotationTransition(
                    turns: _controller,
                    child: Icon(
                      _is3DMode ? Icons.view_in_ar : Icons.threed_rotation,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _is3DMode ? '2D View' : '3D View',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // AR Badge (when in 3D mode)
        if (_is3DMode)
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'AR Ready',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

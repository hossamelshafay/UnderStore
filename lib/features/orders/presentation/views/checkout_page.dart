import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../cart/data/models/cart.dart';
import '../../data/models/order_model.dart';
import '../manager/cubit/orders_cubit.dart';
import '../../../location/presentation/widgets/location_picker_page.dart';
import '../../../location/presentation/manager/cubit/location_bloc.dart';
import '../../../location/data/repos/location_repo_imp.dart';
import '../../../location/data/model/location_model.dart';
import '../widgets/stripe_payment_page.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/section_title_widget.dart';
import '../widgets/info_card_widget.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/card_details_button.dart';
import '../widgets/phone_edit_dialog.dart';
import '../widgets/checkout_bottom_sheet.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;
  String _deliveryAddress = '';
  String _phoneNumber = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _phoneNumber = prefs.getString('user_phone') ?? '';
          _deliveryAddress = prefs.getString('user_address') ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', _phoneNumber);
    await prefs.setString('user_address', _deliveryAddress);
  }

  void _handleEditAddress() async {
    final prefs = await SharedPreferences.getInstance();

    final result = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => LocationBloc(LocationRepoImp(prefs)),
          child: LocationPickerPage(
            initialLocation: _deliveryAddress.isNotEmpty
                ? LocationModel(
                    latitude: 0.0,
                    longitude: 0.0,
                    address: _deliveryAddress,
                  )
                : null,
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _deliveryAddress = result.address;
      });
      _saveUserData();
    }
  }

  void _handleEditPhone() {
    showDialog(
      context: context,
      builder: (context) => PhoneEditDialog(
        initialPhone: _phoneNumber,
        onSave: (phone) {
          setState(() {
            _phoneNumber = phone;
          });
          _saveUserData();
        },
      ),
    );
  }

  void _handleEditCard() async {
    if (_selectedPaymentMethod == PaymentMethod.card) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => StripePaymentPage(
            amount: widget.totalAmount,
            onSuccess: () {
              // Payment successful, proceed with order
              _createOrder();
            },
          ),
        ),
      );

      if (result == true && mounted) {
        // Payment was successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _createOrder() {
    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: widget.cartItems,
      totalAmount: widget.totalAmount,
      deliveryAddress: _deliveryAddress,
      phoneNumber: _phoneNumber,
      paymentMethod: _selectedPaymentMethod,
      cardNumber: _selectedPaymentMethod == PaymentMethod.card
          ? 'Card payment completed'
          : null,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    context.read<OrdersCubit>().createOrder(order);
  }

  void _handleBuyNow() {
    // Validate phone number and address
    if (_phoneNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add your phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_deliveryAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add your delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // If card payment, open payment gateway
    if (_selectedPaymentMethod == PaymentMethod.card) {
      _handleEditCard();
    } else {
      // Cash on delivery - create order directly
      _createOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersCubit, OrdersState>(
      listener: (context, state) async {
        if (state is OrderCreated) {
          // Clear the cart after successful order creation
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('cart');

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Go back to cart
          Navigator.of(context).pop(); // Go back to home
        } else if (state is OrdersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
          title: const Text(
            'Payment Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (_isLoading || state is OrdersLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5145FC)),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Payment Card with Gradient
                        PaymentSummaryCard(
                          totalAmount: widget.totalAmount,
                          itemCount: widget.cartItems.length,
                        ),
                        const SizedBox(height: 28),

                        // Delivery Section
                        SectionTitleWidget(
                          title: 'Delivery to',
                          onEdit: _handleEditAddress,
                        ),
                        const SizedBox(height: 12),
                        InfoCardWidget(
                          icon: Icons.location_on_outlined,
                          title: 'Home Address',
                          subtitle: _deliveryAddress.isEmpty
                              ? 'Add your delivery address'
                              : _deliveryAddress,
                          isEmpty: _deliveryAddress.isEmpty,
                          onTap: _handleEditAddress,
                        ),
                        const SizedBox(height: 20),

                        // Phone Number Section
                        SectionTitleWidget(
                          title: 'Phone number',
                          onEdit: _handleEditPhone,
                        ),
                        const SizedBox(height: 12),
                        InfoCardWidget(
                          icon: Icons.phone_outlined,
                          title: 'Contact',
                          subtitle: _phoneNumber.isEmpty
                              ? 'Add your phone number'
                              : _phoneNumber,
                          isEmpty: _phoneNumber.isEmpty,
                          onTap: _handleEditPhone,
                        ),
                        const SizedBox(height: 20),

                        // Payment Method Section
                        const Text(
                          'Payment method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: PaymentMethodCard(
                                icon: Icons.credit_card,
                                title: 'Card',
                                subtitle:
                                    'Pay securely using your\ncredit or debit card',
                                isSelected:
                                    _selectedPaymentMethod ==
                                    PaymentMethod.card,
                                onTap: () {
                                  setState(() {
                                    _selectedPaymentMethod = PaymentMethod.card;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PaymentMethodCard(
                                icon: Icons.money,
                                title: 'Cash',
                                subtitle: 'Pay with cash upon\ndelivery',
                                isSelected:
                                    _selectedPaymentMethod ==
                                    PaymentMethod.cash,
                                onTap: () {
                                  setState(() {
                                    _selectedPaymentMethod = PaymentMethod.cash;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        // Card Details Section (shown when Card is selected)
                        if (_selectedPaymentMethod == PaymentMethod.card) ...[
                          const SizedBox(height: 20),
                          CardDetailsButton(onTap: _handleEditCard),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottomSheet: CheckoutBottomSheet(
          isEnabled:
              _phoneNumber.trim().isNotEmpty &&
              _deliveryAddress.trim().isNotEmpty,
          onBuyNow: _handleBuyNow,
        ),
      ),
    );
  }
}

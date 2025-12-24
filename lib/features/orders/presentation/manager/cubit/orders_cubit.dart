import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repos/orders_repo.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepo ordersRepo;

  OrdersCubit(this.ordersRepo) : super(OrdersInitial());

  Future<void> createOrder(OrderModel order) async {
    try {
      emit(OrdersLoading());
      await ordersRepo.createOrder(order);
      emit(OrderCreated('Order placed successfully!'));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> loadOrders() async {
    try {
      emit(OrdersLoading());
      final orders = await ordersRepo.getOrders();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      emit(OrdersLoading());
      await ordersRepo.cancelOrder(orderId);
      await loadOrders();
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      emit(OrdersLoading());
      await ordersRepo.deleteOrder(orderId);
      await loadOrders();
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}

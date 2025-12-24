// Example: How to integrate SQLite with your existing code

// 1. In your ProfileCubit, add the sync service:
/*
import '../../../core/services/user_sync_service.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final UserSyncService syncService = UserSyncService();
  
  ProfileCubit(this.profileRepo) : super(ProfileInitial());

  Future<void> loadUserProfile() async {
    try {
      emit(ProfileLoading());
      
      // First try to get from local SQLite (faster)
      final localUser = await syncService.getLocalUser();
      
      if (localUser != null) {
        // Use local data immediately
        emit(ProfileLoaded(User(
          uid: localUser.uid,
          email: localUser.email,
          name: localUser.name,
          phone: localUser.phone,
          location: localUser.location,
        )));
      }
      
      // Then sync with Firebase in background
      await syncService.syncUserToLocal();
      
      // Load again to get updated data
      final updatedUser = await syncService.getLocalUser();
      if (updatedUser != null) {
        emit(ProfileLoaded(User(
          uid: updatedUser.uid,
          email: updatedUser.email,
          name: updatedUser.name,
          phone: updatedUser.phone,
          location: updatedUser.location,
        )));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateLocation(String location) async {
    try {
      emit(ProfileLoading());
      
      // Update via sync service (updates both SQLite and Firebase)
      await syncService.updateLocation(LocationModel(
        latitude: 0.0,
        longitude: 0.0,
        address: location,
      ));
      
      emit(ProfileUpdateSuccess('Location updated successfully'));
      loadUserProfile();
    } catch (e) {
      emit(ProfileUpdateError(e.toString()));
    }
  }

  Future<void> updatePhone(String phone) async {
    try {
      emit(ProfileLoading());
      await syncService.updatePhone(phone);
      emit(ProfileUpdateSuccess('Phone updated successfully'));
      loadUserProfile();
    } catch (e) {
      emit(ProfileUpdateError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    // Optional: clear on logout
    // syncService.clearLocalData();
    return super.close();
  }
}
*/

// 2. In your OrdersCubit, add the order sync service:
/*
import '../../../core/services/order_sync_service.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepo ordersRepo;
  final OrderSyncService syncService = OrderSyncService();
  
  OrdersCubit(this.ordersRepo) : super(OrdersInitial());

  Future<void> loadOrders() async {
    try {
      emit(OrdersLoading());
      
      // Get from local SQLite first (instant load)
      final localOrders = await syncService.getLocalOrders();
      
      if (localOrders.isNotEmpty) {
        emit(OrdersLoaded(localOrders));
      }
      
      // Then load from Firebase and sync
      final result = await ordersRepo.getOrders();
      result.fold(
        (error) => emit(OrdersError(error)),
        (orders) {
          // Save each order to SQLite
          for (var order in orders) {
            syncService.saveOrderToLocal(order);
          }
          emit(OrdersLoaded(orders));
        },
      );
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> createOrder(OrderModel order) async {
    try {
      emit(OrdersLoading());
      
      // Save to Firebase
      final result = await ordersRepo.createOrder(order);
      
      await result.fold(
        (error) async => emit(OrdersError(error)),
        (orderId) async {
          // Save to local SQLite
          await syncService.saveOrderToLocal(order.copyWith(id: orderId));
          emit(OrderCreated('Order created successfully'));
          loadOrders();
        },
      );
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    return await syncService.getUserStatistics();
  }
}
*/

// 3. Initialize database on app start (in main.dart):
/*
import 'core/database/database_helper.dart';
import 'core/services/user_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Database
  final db = await DatabaseHelper.instance.database;
  print('Database initialized');
  
  // Sync user data on app start
  final syncService = UserSyncService();
  await syncService.syncUserToLocal();
  
  runApp(const MyApp());
}
*/

// 4. Clear data on logout:
/*
Future<void> logout() async {
  final syncService = UserSyncService();
  final orderSync = OrderSyncService();
  
  // Clear local data
  await syncService.clearLocalData();
  await orderSync.clearLocalOrders();
  
  // Sign out from Firebase
  await FirebaseAuth.instance.signOut();
  
  // Navigate to login
  Navigator.pushReplacementNamed(context, '/login');
}
*/

void main() {
  print('SQLite integration example');
  print('See comments above for implementation details');
}

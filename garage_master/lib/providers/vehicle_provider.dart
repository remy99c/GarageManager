import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';

class VehicleProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Vehicle> _vehicles = [];
  List<Vehicle> _archivedVehicles = [];
  bool _isLoading = false;
  bool _showArchived = false;

  List<Vehicle> get vehicles => _vehicles;
  List<Vehicle> get archivedVehicles => _archivedVehicles;
  bool get isLoading => _isLoading;
  bool get showArchived => _showArchived;

  VehicleProvider() {
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    _isLoading = true;
    notifyListeners();

    try {
      _vehicles = await _databaseService.getVehicles(includeArchived: false);
      _archivedVehicles = await _databaseService.getArchivedVehicles();
    } catch (e) {
      debugPrint('Error loading vehicles: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleShowArchived() {
    _showArchived = !_showArchived;
    notifyListeners();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      await _databaseService.insertVehicle(vehicle);
      await loadVehicles();
    } catch (e) {
      debugPrint('Error adding vehicle: $e');
      rethrow;
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      await _databaseService.updateVehicle(vehicle);
      await loadVehicles();
    } catch (e) {
      debugPrint('Error updating vehicle: $e');
      rethrow;
    }
  }

  Future<void> archiveVehicle(String vin) async {
    try {
      await _databaseService.archiveVehicle(vin);
      await loadVehicles();
    } catch (e) {
      debugPrint('Error archiving vehicle: $e');
      rethrow;
    }
  }

  Future<void> unarchiveVehicle(String vin) async {
    try {
      await _databaseService.unarchiveVehicle(vin);
      await loadVehicles();
    } catch (e) {
      debugPrint('Error unarchiving vehicle: $e');
      rethrow;
    }
  }

  Future<void> deleteVehicle(String vin) async {
    try {
      await _databaseService.deleteVehicle(vin);
      await loadVehicles();
    } catch (e) {
      debugPrint('Error deleting vehicle: $e');
      rethrow;
    }
  }

  Future<void> updateTodoItem(String vin, int index, bool isDone) async {
    final vehicle = _vehicles.firstWhere(
      (v) => v.vin == vin,
      orElse: () => _archivedVehicles.firstWhere((v) => v.vin == vin),
    );

    final updatedTodoList = List<ChecklistItem>.from(vehicle.todoList);
    updatedTodoList[index] = updatedTodoList[index].copyWith(isDone: isDone);

    final updatedVehicle = vehicle.copyWith(todoList: updatedTodoList);
    await updateVehicle(updatedVehicle);
  }

  Future<void> updateShoppingItem(String vin, int index, bool isDone) async {
    final vehicle = _vehicles.firstWhere(
      (v) => v.vin == vin,
      orElse: () => _archivedVehicles.firstWhere((v) => v.vin == vin),
    );

    final updatedShoppingList = List<ChecklistItem>.from(vehicle.shoppingList);
    updatedShoppingList[index] =
        updatedShoppingList[index].copyWith(isDone: isDone);

    final updatedVehicle = vehicle.copyWith(shoppingList: updatedShoppingList);
    await updateVehicle(updatedVehicle);
  }
}

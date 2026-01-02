import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/vehicle_card.dart';
import 'vehicle_detail_screen.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.garage,
                color: AppTheme.accentOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('GarageMaster'),
          ],
        ),
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentOrange),
            );
          }

          final displayVehicles = provider.showArchived
              ? provider.archivedVehicles
              : provider.vehicles;

          return Column(
            children: [
              Expanded(
                child: displayVehicles.isEmpty
                    ? _buildEmptyState(provider.showArchived)
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 16, bottom: 100),
                        itemCount: displayVehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = displayVehicles[index];
                          return VehicleCard(
                            vehicle: vehicle,
                            onTap: () => _openVehicleDetail(context, vehicle),
                          );
                        },
                      ),
              ),
              // Persistent button at bottom
              _buildBottomSection(context, provider),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          if (provider.showArchived) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: FloatingActionButton.extended(
              onPressed: () => _openAddVehicle(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool showingArchived) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showingArchived
                ? Icons.inventory_2_outlined
                : Icons.directions_car_outlined,
            size: 80,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            showingArchived ? 'No archived vehicles' : 'No vehicles yet',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showingArchived
                ? 'Sold vehicles will appear here'
                : 'Tap the button below to add your first vehicle',
            style: const TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, VehicleProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => provider.toggleShowArchived(),
                icon: Icon(
                  provider.showArchived ? Icons.arrow_back : Icons.attach_money,
                ),
                label: Text(
                  provider.showArchived
                      ? 'Back to Active Vehicles'
                      : 'View vehicles marked sold (${provider.archivedVehicles.length})',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openVehicleDetail(BuildContext context, Vehicle vehicle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleDetailScreen(vehicle: vehicle),
      ),
    );
  }

  void _openAddVehicle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VehicleDetailScreen(vehicle: null),
      ),
    );
  }
}

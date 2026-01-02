import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleCard({super.key, required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Vehicle icon or image thumbnail
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentOrange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: vehicle.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: kIsWeb
                            ? Image.network(
                                vehicle.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.directions_car,
                                    color: AppTheme.accentOrange,
                                    size: 28,
                                  );
                                },
                              )
                            : Image.file(
                                File(vehicle.imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.directions_car,
                                    color: AppTheme.accentOrange,
                                    size: 28,
                                  );
                                },
                              ),
                      )
                    : const Icon(
                        Icons.directions_car,
                        color: AppTheme.accentOrange,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              // Vehicle info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildMiniChip(vehicle.brand, Icons.business),
                        const SizedBox(width: 8),
                        _buildMiniChip(
                          vehicle.year.toString(),
                          Icons.calendar_today,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Trailing - SOLD badge or arrow
              if (vehicle.isArchived)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.errorRed.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'SOLD',
                    style: TextStyle(
                      color: AppTheme.errorRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                const Icon(Icons.chevron_right, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

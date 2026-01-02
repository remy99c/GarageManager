import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/status_indicator.dart';
import '../widgets/todo_list_widget.dart';
import '../widgets/shopping_list_widget.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleDetailScreen({super.key, this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late bool _isEditing;
  late bool _isNewVehicle;
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  // Controllers
  late TextEditingController _vinController;
  late TextEditingController _licensePlateController;
  late TextEditingController _descriptionController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _partNumbersController;
  late TextEditingController _issuesController;
  late TextEditingController _notesController;

  // State
  DateTime? _lastCheckup;
  DateTime? _nextCheckup;
  bool _isInsured = false;
  bool _isTaxed = false;
  bool _hasPassed = false;
  bool _inStorage = false;
  List<ChecklistItem> _todoList = [];
  List<ChecklistItem> _shoppingList = [];
  String? _imagePath;
  String? _fuelType;

  // Fuel type options
  static const List<String> _fuelTypes = [
    '95',
    '98',
    '85',
    'Diesel',
    'Electric',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _isNewVehicle = widget.vehicle == null;
    _isEditing = _isNewVehicle;

    final v = widget.vehicle;
    _vinController = TextEditingController(text: v?.vin ?? '');
    _licensePlateController = TextEditingController(
      text: v?.licensePlate ?? '',
    );
    _descriptionController = TextEditingController(text: v?.description ?? '');
    _brandController = TextEditingController(text: v?.brand ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(
      text: v?.year.toString() ?? DateTime.now().year.toString(),
    );
    _partNumbersController = TextEditingController(text: v?.partNumbers ?? '');
    _issuesController = TextEditingController(text: v?.issues ?? '');
    _notesController = TextEditingController(text: v?.notes ?? '');

    _lastCheckup = v?.lastCheckup;
    _nextCheckup = v?.nextCheckup;
    _isInsured = v?.isInsured ?? false;
    _isTaxed = v?.isTaxed ?? false;
    _hasPassed = v?.hasPassed ?? false;
    _inStorage = v?.inStorage ?? false;
    _todoList = List.from(v?.todoList ?? []);
    _shoppingList = List.from(v?.shoppingList ?? []);
    _imagePath = v?.imagePath;
    _fuelType = v?.fuelType;
  }

  @override
  void dispose() {
    _vinController.dispose();
    _licensePlateController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _partNumbersController.dispose();
    _issuesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewVehicle ? 'Add Vehicle' : _getDisplayTitle()),
        actions: [
          if (!_isNewVehicle && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.white,
              tooltip: 'Edit Vehicle',
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!_isNewVehicle && _isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppTheme.errorRed,
              tooltip: 'Delete Vehicle',
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Section
            _buildImageSection(),
            const SizedBox(height: 16),

            // Mark as Sold Button (only in edit mode for existing vehicles)
            if (_isEditing && !_isNewVehicle) _buildMarkAsSoldButton(),
            const SizedBox(height: 24),

            // Status Indicators (moved to top)
            _buildSectionHeader('Status', Icons.verified),
            const SizedBox(height: 12),
            if (_isEditing)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSwitchTile(
                          'Insured',
                          _isInsured,
                          (value) => setState(() => _isInsured = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSwitchTile(
                          'Taxed',
                          _isTaxed,
                          (value) => setState(() => _isTaxed = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSwitchTile(
                          'Passed',
                          _hasPassed,
                          (value) => setState(() => _hasPassed = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSwitchTile(
                          'Storage',
                          _inStorage,
                          (value) => setState(() => _inStorage = value),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatusIndicator(
                          label: _isInsured ? 'Insured' : 'Not Insured',
                          isActive: _isInsured,
                          icon: Icons.security,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatusIndicator(
                          label: _isTaxed ? 'Taxed' : 'Not Taxed',
                          isActive: _isTaxed,
                          icon: Icons.receipt_long,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatusIndicator(
                          label: _hasPassed ? 'Passed' : 'Not Passed',
                          isActive: _hasPassed,
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatusIndicator(
                          label: _inStorage ? 'In Storage' : 'Not in Storage',
                          isActive: _inStorage,
                          icon: Icons.warehouse_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Basic Info Section
            _buildSectionHeader('Basic Information', Icons.info_outline),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _vinController,
              label: 'VIN (Vehicle Identification Number)',
              enabled: _isEditing && _isNewVehicle,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'VIN is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _licensePlateController,
              label: 'License Plate',
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description (e.g., "Red Chevy pickup")',
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Vehicle Details
            _buildSectionHeader('Vehicle Details', Icons.directions_car),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _brandController,
                    label: 'Brand',
                    enabled: _isEditing,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _modelController,
                    label: 'Model',
                    enabled: _isEditing,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _yearController,
              label: 'Year',
              enabled: _isEditing,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildFuelTypeField(),
            const SizedBox(height: 24),

            // Checkup Dates
            _buildSectionHeader('Checkup dates', Icons.build),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Last Checkup',
                    value: _lastCheckup,
                    enabled: _isEditing,
                    onChanged: (date) => setState(() => _lastCheckup = date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    label: 'Next Checkup',
                    value: _nextCheckup,
                    enabled: _isEditing,
                    onChanged: (date) => setState(() => _nextCheckup = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Part Numbers
            _buildSectionHeader('Part Numbers (RPO Codes)', Icons.qr_code),
            const SizedBox(height: 12),
            _buildPartNumbersBox(),
            const SizedBox(height: 24),

            // Issues
            _buildSectionHeader('Issues', Icons.warning_amber),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _issuesController,
              label: 'Known issues',
              enabled: _isEditing,
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // To-Do List
            TodoListWidget(
              items: _todoList,
              isEditing: _isEditing,
              onItemToggle: (index, isDone) {
                setState(() {
                  _todoList[index] = _todoList[index].copyWith(isDone: isDone);
                });
                if (!_isNewVehicle) {
                  _saveVehicle();
                }
              },
              onItemsChanged: (items) => setState(() => _todoList = items),
            ),
            const SizedBox(height: 16),

            // Shopping List
            ShoppingListWidget(
              items: _shoppingList,
              isEditing: _isEditing,
              onItemToggle: (index, isDone) {
                setState(() {
                  _shoppingList[index] =
                      _shoppingList[index].copyWith(isDone: isDone);
                });
                if (!_isNewVehicle) {
                  _saveVehicle();
                }
              },
              onItemsChanged: (items) => setState(() => _shoppingList = items),
            ),
            const SizedBox(height: 24),

            // Notes
            _buildSectionHeader('Notes', Icons.note),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _notesController,
              label: 'Additional notes',
              enabled: _isEditing,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // Action Buttons (at bottom, requiring scroll)
            _buildActionButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _isEditing ? _buildEditingBottomBar() : null,
    );
  }

  String _getDisplayTitle() {
    if (_licensePlateController.text.isNotEmpty) {
      return _licensePlateController.text;
    }
    return _vinController.text;
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentOrange, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.accentOrange.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _imagePath != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    kIsWeb
                        ? Image.network(
                            _imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                          )
                        : Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                          ),
                    if (_isEditing)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                )
              : _buildImagePlaceholder(),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.cardDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 60,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          if (_isEditing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 18,
                    color: AppTheme.accentOrange,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Add Photo',
                    style: TextStyle(
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
      ),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor:
            enabled ? AppTheme.cardDark : AppTheme.cardDark.withOpacity(0.5),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required bool enabled,
    required Function(DateTime?) onChanged,
  }) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final text = value != null ? dateFormat.format(value) : '';

    return GestureDetector(
      onTap: enabled
          ? () async {
              final date = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppTheme.accentOrange,
                        surface: AppTheme.cardDark,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                onChanged(date);
              }
            }
          : null,
      child: AbsorbPointer(
        child: TextFormField(
          key: ValueKey('${label}_$text'),
          initialValue: text,
          enabled: enabled, // This ensures consistent styling with other fields
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: enabled
                ? AppTheme.cardDark
                : AppTheme.cardDark.withOpacity(0.5),
            suffixIcon: const Icon(Icons.event, color: AppTheme.accentOrange),

            // Ensure the border is integrated if the theme doesn't default to it
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none, // Or match theme
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
            disabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(
            color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppTheme.successGreen.withOpacity(0.5)
              : AppTheme.textMuted,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textPrimary)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.successGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildPartNumbersBox() {
    if (_isEditing) {
      return _buildTextField(
        controller: _partNumbersController,
        label: 'Enter RPO codes/part numbers',
        enabled: true,
        maxLines: 4,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textMuted.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: _partNumbersController.text.isEmpty
          ? const Text(
              'No part numbers recorded',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontStyle: FontStyle.italic,
              ),
            )
          : Text(
              _partNumbersController.text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: AppTheme.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
    );
  }

  Widget _buildFuelTypeField() {
    if (_isEditing) {
      return DropdownButtonFormField<String>(
        value: _fuelType,
        decoration: const InputDecoration(
          labelText: 'Fuel Type',
          filled: true,
          fillColor: AppTheme.cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
        ),
        dropdownColor: AppTheme.cardDark,
        style: const TextStyle(color: AppTheme.textPrimary),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Not specified',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ..._fuelTypes.map((type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              )),
        ],
        onChanged: (value) => setState(() => _fuelType = value),
      );
    }
    return TextFormField(
      initialValue: _fuelType ?? 'Not specified',
      enabled: false,
      decoration: InputDecoration(
        labelText: 'Fuel Type',
        filled: true,
        fillColor: AppTheme.cardDark.withOpacity(0.5),
        prefixIcon: Icon(
          _getFuelTypeIcon(_fuelType),
          color: _fuelType != null ? AppTheme.accentOrange : AppTheme.textMuted,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: AppTheme.textSecondary),
    );
  }

  IconData _getFuelTypeIcon(String? fuelType) {
    switch (fuelType) {
      case 'Electric':
        return Icons.electric_car;
      case 'Diesel':
        return Icons.local_gas_station;
      case '95':
      case '98':
      case '85':
        return Icons.local_gas_station;
      default:
        return Icons.local_gas_station;
    }
  }

  Widget _buildActionButtons() {
    // Delete button is now in AppBar when editing, so no action buttons needed here
    return const SizedBox.shrink();
  }

  Widget _buildMarkAsSoldButton() {
    final isAlreadySold = widget.vehicle?.isArchived ?? false;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed:
            isAlreadySold ? _unarchiveVehicleDirectly : _archiveVehicleDirectly,
        icon: Icon(
          isAlreadySold ? Icons.undo : Icons.sell,
          size: 24,
        ),
        label: Text(
          isAlreadySold ? 'Unmark as Sold' : 'Mark as Sold',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isAlreadySold ? AppTheme.accentOrange : AppTheme.successGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEditingBottomBar() {
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
            if (!_isNewVehicle)
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEditing,
                  child: const Text('Cancel'),
                ),
              ),
            if (!_isNewVehicle) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveVehicle,
                child: Text(
                  _isNewVehicle ? 'Add Vehicle' : 'Save Changes',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Photo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => _getImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageSourceButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _getImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.accentOrange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.accentOrange),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    Navigator.pop(context);

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        String savedPath;

        if (kIsWeb) {
          // For web, use the path directly
          savedPath = pickedFile.path;
        } else {
          // For mobile, copy to app documents
          final directory = await getApplicationDocumentsDirectory();
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${path.basename(pickedFile.path)}';
          final savedImage = await File(
            pickedFile.path,
          ).copy('${directory.path}/$fileName');
          savedPath = savedImage.path;
        }

        setState(() {
          _imagePath = savedPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      // Reset to original values
      final v = widget.vehicle!;
      _licensePlateController.text = v.licensePlate ?? '';
      _descriptionController.text = v.description;
      _brandController.text = v.brand;
      _modelController.text = v.model;
      _yearController.text = v.year.toString();
      _partNumbersController.text = v.partNumbers;
      _issuesController.text = v.issues;
      _notesController.text = v.notes;
      _lastCheckup = v.lastCheckup;
      _nextCheckup = v.nextCheckup;
      _isInsured = v.isInsured;
      _isTaxed = v.isTaxed;
      _hasPassed = v.hasPassed;
      _inStorage = v.inStorage;
      _todoList = List.from(v.todoList);
      _shoppingList = List.from(v.shoppingList);
      _imagePath = v.imagePath;
      _fuelType = v.fuelType;
    });
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = Vehicle(
      vin: _vinController.text,
      licensePlate: _licensePlateController.text.isEmpty
          ? null
          : _licensePlateController.text,
      description: _descriptionController.text,
      brand: _brandController.text,
      model: _modelController.text,
      year: int.tryParse(_yearController.text) ?? DateTime.now().year,
      lastCheckup: _lastCheckup,
      nextCheckup: _nextCheckup,
      isInsured: _isInsured,
      isTaxed: _isTaxed,
      hasPassed: _hasPassed,
      inStorage: _inStorage,
      partNumbers: _partNumbersController.text,
      issues: _issuesController.text,
      todoList: _todoList,
      shoppingList: _shoppingList,
      notes: _notesController.text,
      imagePath: _imagePath,
      isArchived: widget.vehicle?.isArchived ?? false,
      fuelType: _fuelType,
    );

    try {
      final provider = context.read<VehicleProvider>();

      if (_isNewVehicle) {
        await provider.addVehicle(vehicle);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle added successfully')),
          );
        }
      } else {
        await provider.updateVehicle(vehicle);
        if (mounted) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving vehicle: $e')));
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text(
          'Are you sure you want to delete this vehicle? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => _deleteVehicle(),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _archiveVehicleDirectly() async {
    try {
      await context.read<VehicleProvider>().archiveVehicle(widget.vehicle!.vin);
      if (mounted) {
        Navigator.pop(context); // Return to list
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vehicle marked as sold')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
            SnackBar(content: Text('Error marking vehicle as sold: $e')));
      }
    }
  }

  Future<void> _unarchiveVehicleDirectly() async {
    try {
      await context
          .read<VehicleProvider>()
          .unarchiveVehicle(widget.vehicle!.vin);
      if (mounted) {
        Navigator.pop(context); // Return to list
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
            const SnackBar(content: Text('Vehicle unmarked as sold')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating vehicle: $e')));
      }
    }
  }

  Future<void> _deleteVehicle() async {
    Navigator.pop(context); // Close dialog

    try {
      await context.read<VehicleProvider>().deleteVehicle(widget.vehicle!.vin);
      if (mounted) {
        Navigator.pop(context); // Return to list
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vehicle deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting vehicle: $e')));
      }
    }
  }
}

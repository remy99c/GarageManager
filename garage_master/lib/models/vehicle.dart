import 'dart:convert';

class ChecklistItem {
  final String task;
  final bool isDone;

  ChecklistItem({required this.task, this.isDone = false});

  ChecklistItem copyWith({String? task, bool? isDone}) {
    return ChecklistItem(
      task: task ?? this.task,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'task': task,
        'isDone': isDone,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      task: json['task'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}

class Vehicle {
  final String vin;
  final String? licensePlate;
  final String description;
  final String brand;
  final String model;
  final int year;
  final DateTime? lastCheckup;
  final DateTime? nextCheckup;
  final bool isInsured;
  final bool isTaxed;
  final bool hasPassed;
  final bool inStorage;
  final String partNumbers;
  final String issues;
  final List<ChecklistItem> todoList;
  final List<ChecklistItem> shoppingList;
  final String notes;
  final String? imagePath;
  final bool isArchived;
  final String? fuelType;

  Vehicle({
    required this.vin,
    this.licensePlate,
    required this.description,
    required this.brand,
    required this.model,
    required this.year,
    this.lastCheckup,
    this.nextCheckup,
    this.isInsured = false,
    this.isTaxed = false,
    this.hasPassed = false,
    this.inStorage = false,
    this.partNumbers = '',
    this.issues = '',
    this.todoList = const [],
    this.shoppingList = const [],
    this.notes = '',
    this.imagePath,
    this.isArchived = false,
    this.fuelType,
  });

  String get displayTitle =>
      licensePlate?.isNotEmpty == true ? licensePlate! : vin;

  Vehicle copyWith({
    String? vin,
    String? licensePlate,
    String? description,
    String? brand,
    String? model,
    int? year,
    DateTime? lastCheckup,
    DateTime? nextCheckup,
    bool? isInsured,
    bool? isTaxed,
    bool? hasPassed,
    bool? inStorage,
    String? partNumbers,
    String? issues,
    List<ChecklistItem>? todoList,
    List<ChecklistItem>? shoppingList,
    String? notes,
    String? imagePath,
    bool? isArchived,
    String? fuelType,
  }) {
    return Vehicle(
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      lastCheckup: lastCheckup ?? this.lastCheckup,
      nextCheckup: nextCheckup ?? this.nextCheckup,
      isInsured: isInsured ?? this.isInsured,
      isTaxed: isTaxed ?? this.isTaxed,
      hasPassed: hasPassed ?? this.hasPassed,
      inStorage: inStorage ?? this.inStorage,
      partNumbers: partNumbers ?? this.partNumbers,
      issues: issues ?? this.issues,
      todoList: todoList ?? this.todoList,
      shoppingList: shoppingList ?? this.shoppingList,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      isArchived: isArchived ?? this.isArchived,
      fuelType: fuelType ?? this.fuelType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vin': vin,
      'licensePlate': licensePlate,
      'description': description,
      'brand': brand,
      'model': model,
      'year': year,
      'lastCheckup': lastCheckup?.toIso8601String(),
      'nextCheckup': nextCheckup?.toIso8601String(),
      'isInsured': isInsured ? 1 : 0,
      'isTaxed': isTaxed ? 1 : 0,
      'hasPassed': hasPassed ? 1 : 0,
      'inStorage': inStorage ? 1 : 0,
      'partNumbers': partNumbers,
      'issues': issues,
      'todoList': jsonEncode(todoList.map((e) => e.toJson()).toList()),
      'shoppingList': jsonEncode(shoppingList.map((e) => e.toJson()).toList()),
      'notes': notes,
      'imagePath': imagePath,
      'isArchived': isArchived ? 1 : 0,
      'fuelType': fuelType,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    List<ChecklistItem> parseChecklist(String? json) {
      if (json == null || json.isEmpty) return [];
      try {
        final List<dynamic> decoded = jsonDecode(json);
        return decoded
            .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Handle migration from List<String> to List<ChecklistItem>
        try {
          final List<dynamic> decoded = jsonDecode(json);
          if (decoded.isNotEmpty && decoded.first is String) {
            return decoded
                .map((e) => ChecklistItem(task: e as String))
                .toList();
          }
        } catch (__) {}
        return [];
      }
    }

    return Vehicle(
      vin: map['vin'] as String,
      licensePlate: map['licensePlate'] as String?,
      description: map['description'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      model: map['model'] as String? ?? '',
      year: map['year'] as int? ?? 0,
      lastCheckup: map['lastCheckup'] != null
          ? DateTime.tryParse(map['lastCheckup'] as String)
          : null,
      nextCheckup: map['nextCheckup'] != null
          ? DateTime.tryParse(map['nextCheckup'] as String)
          : null,
      isInsured: (map['isInsured'] as int?) == 1,
      isTaxed: (map['isTaxed'] as int?) == 1,
      hasPassed: (map['hasPassed'] as int?) == 1,
      inStorage: (map['inStorage'] as int?) == 1,
      partNumbers: map['partNumbers'] as String? ?? '',
      issues: map['issues'] as String? ?? '',
      todoList: parseChecklist(map['todoList'] as String?),
      shoppingList: parseChecklist(map['shoppingList'] as String?),
      notes: map['notes'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
      isArchived: (map['isArchived'] as int?) == 1,
      fuelType: map['fuelType'] as String?,
    );
  }
}

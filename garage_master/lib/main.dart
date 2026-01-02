import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vehicle_provider.dart';
import 'screens/vehicle_list_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/web_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GarageMasterApp());
}

class GarageMasterApp extends StatelessWidget {
  const GarageMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VehicleProvider(),
      child: MaterialApp(
        title: 'Garage Master',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const VehicleListScreen(),
        builder: (context, child) {
          return WebWrapper(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}

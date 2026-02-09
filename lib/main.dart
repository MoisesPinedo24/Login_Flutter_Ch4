import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_pro/logic/task_bloc/task_event.dart';
import 'logic/task_bloc/task_bloc.dart';
import 'core/auth_service.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/task_screen.dart';

// Variable global para el token
String? userToken;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  userToken = await authService.getToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // El ..add(LoadTasksEvent()) hace que cargue apenas se crea el Bloc
      create: (context) => TaskBloc()..add(LoadTasksEvent()),
      child: MaterialApp(
        title: 'Task Manager Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        // La lógica la hacemos directamente aquí
        home: (userToken == null || userToken!.isEmpty)
            ? LoginScreen()
            : const TaskScreen(),
      ),
    );
  }
}

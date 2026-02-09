import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/network/api_service.dart';
import '../../data/local/database_helper.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final DatabaseHelper db = DatabaseHelper.instance;
  final ApiService api = ApiService();

  TaskBloc() : super(TaskInitial()) {
    // 1. CARGAR TAREAS
    on<LoadTasksEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        final remoteTasks = await api.fetchTasks();
        await db.insertTasks(remoteTasks);
      } catch (e) {
        print("Error de red, cargando datos locales: $e");
      }

      final localTasks = await db.getTasks();
      final prefs = await SharedPreferences.getInstance();
      final isGrid = prefs.getBool('isGridView') ?? false;

      emit(TaskLoaded(tasks: localTasks, isGridView: isGrid));
    });

    // 2. CAMBIAR MODO DE VISTA
    on<ToggleViewModeEvent>((event, emit) async {
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        final prefs = await SharedPreferences.getInstance();
        final newView = !currentState.isGridView;

        await prefs.setBool('isGridView', newView);
        emit(TaskLoaded(tasks: currentState.tasks, isGridView: newView));
      }
    });

    // 3. ACTUALIZAR ESTADO
    on<UpdateTaskStatusEvent>((event, emit) async {
      final dbInstance = await db.database;
      await dbInstance.update(
        'tasks',
        {'status': event.newStatus},
        where: 'id = ?',
        whereArgs: [event.taskId],
      );
      add(LoadTasksEvent());
    });

    // 4. AGREGAR TAREA
    on<AddTaskEvent>((event, emit) async {
      await db.insertSingleTask(event.title);
      add(LoadTasksEvent());
    });

    // 5. ELIMINAR TAREA (¡Ahora dentro del constructor!)
    on<DeleteTaskEvent>((event, emit) async {
      await db.deleteTask(event.taskId);
      add(LoadTasksEvent());
    });
  }
}

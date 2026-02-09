import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/auth_service.dart';
import '../../logic/task_bloc/task_bloc.dart';
import '../../logic/task_bloc/task_event.dart';
import '../../logic/task_bloc/task_state.dart';
import 'login_screen.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  void _updateStatus(BuildContext context, int id, int status) {
    context.read<TaskBloc>().add(UpdateTaskStatusEvent(id, status));
    Navigator.pop(context);
  }

  void _showStatusPicker(BuildContext context, int taskId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Text(
              "Gestionar Tarea",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),
            _statusTile(
              context,
              taskId,
              1,
              "Pendiente",
              Icons.hourglass_empty,
              Colors.red,
            ),
            _statusTile(
              context,
              taskId,
              2,
              "En Proceso",
              Icons.sync,
              Colors.orange,
            ),
            _statusTile(
              context,
              taskId,
              3,
              "Completado",
              Icons.check_circle_outline,
              Colors.green,
            ),
            const Divider(), // Una línea separadora
            // --- BOTÓN DE ELIMINAR ---
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.black54),
              title: const Text(
                "Eliminar Tarea",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                context.read<TaskBloc>().add(DeleteTaskEvent(taskId));
                Navigator.pop(context); // Cierra el menú
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _statusTile(
    BuildContext context,
    int id,
    int val,
    String text,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () => _updateStatus(context, id, val),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Color de fondo suave
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          "Mis Tareas",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.blueAccent),
            onPressed: () =>
                context.read<TaskBloc>().add(ToggleViewModeEvent()),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.blueAccent,
        onRefresh: () async {
          context.read<TaskBloc>().add(LoadTasksEvent());
          await Future.delayed(const Duration(seconds: 1));
        },
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading)
              return const Center(child: CircularProgressIndicator());

            if (state is TaskLoaded) {
              if (state.tasks.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 100,
                            color: Colors.blue,
                          ), // Cambiado por algo más "limpio"
                          SizedBox(height: 20),
                          Text(
                            "¡Todo al día!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            "Agrega una tarea para comenzar",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return state.isGridView
                  ? _buildGrid(state.tasks)
                  : _buildList(state.tasks);
            }
            return const Center(child: Text("Error al cargar"));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nueva Tarea",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildList(List tasks) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final task = tasks[i];
        Color color = task.status == 1
            ? Colors.red
            : task.status == 2
            ? Colors.orange
            : Colors.green;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            title: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              task.status == 3 ? "Finalizada" : "En progreso",
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () => _showStatusPicker(context, task.id),
          ),
        );
      },
    );
  }

  Widget _buildGrid(List tasks) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final task = tasks[i];
        Color color = task.status == 1
            ? Colors.red
            : task.status == 2
            ? Colors.orange
            : Colors.green;
        return InkWell(
          onTap: () => _showStatusPicker(context, task.id),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment, color: color, size: 30),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    task.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("¿Qué sigue?"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Nombre de la tarea",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<TaskBloc>().add(AddTaskEvent(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text("Agregar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

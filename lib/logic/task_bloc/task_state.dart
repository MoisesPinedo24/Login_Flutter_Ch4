import 'package:equatable/equatable.dart';
import '../../data/models/task_model.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final bool isGridView; // Sacado de Shared Preferences

  TaskLoaded({required this.tasks, required this.isGridView});

  @override
  List<Object> get props => [tasks, isGridView];
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}

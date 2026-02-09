// lib/logic/task_bloc/task_event.dart
import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {}

class ToggleViewModeEvent extends TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final String title;
  AddTaskEvent(this.title);
  @override
  List<Object?> get props => [title];
}

class UpdateTaskStatusEvent extends TaskEvent {
  final int taskId;
  final int newStatus;
  UpdateTaskStatusEvent(this.taskId, this.newStatus);
  @override
  List<Object?> get props => [taskId, newStatus];
}

class DeleteTaskEvent extends TaskEvent {
  final int taskId;
  DeleteTaskEvent(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

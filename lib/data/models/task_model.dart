import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class Task extends Equatable {
  final int id;
  final String title;
  final int status; // 1: ToDo, 2: Doing, 3: Done

  Task({required this.id, required this.title, required this.status});

  // Para JSON (API)
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  // Para SQFlite (Mapas)
  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'status': status};

  factory Task.fromMap(Map<String, dynamic> map) =>
      Task(id: map['id'], title: map['title'], status: map['status']);

  @override
  List<Object?> get props => [id, title, status];
}

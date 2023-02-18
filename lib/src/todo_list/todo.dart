import 'package:flutter/material.dart';

class Todo {
  final String name;
  bool isCompleted;
  int id;

  Todo(
      {required this.name,
      this.isCompleted = false,
      this.id = 0});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      name: map['name'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}

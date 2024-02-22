import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/task.dart';

class HomeViewModel {
  final User? user;
  final DatabaseReference databaseReference;

  HomeViewModel({required this.user, required this.databaseReference});

  StreamController<List<Task>> _tasksController = StreamController<List<Task>>();
  Stream<List<Task>> get tasksStream => _tasksController.stream;

  void fetchTasks() {
    if (user != null) {
      databaseReference
          .child('users')
          .child(user!.uid)
          .child('tasks')
          .onValue
          .listen((event) {
        var taskData = event.snapshot.value as Map<dynamic, dynamic>?;
        if (taskData != null) {
          List<Task> tasks = taskData.entries
              .map((entry) => Task(
                    id: entry.key,
                    subject: entry.value['subject'],
                    priority: entry.value['priority'],
                  ))
              .toList();
          _tasksController.add(tasks);
        } else {
          _tasksController.add([]);
        }
      });
    }
  }

  void deleteTask(String taskId) {
    if (user != null) {
      databaseReference
          .child('users')
          .child(user!.uid)
          .child('tasks')
          .child(taskId)
          .remove()
          .then((_) {
        // Handle success
      });
    }
  }

  void dispose() {
    _tasksController.close();
  }
}

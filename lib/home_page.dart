import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firedev/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';
import 'todo_page.dart';

final firebaseApp = Firebase.app();
final rtdb = FirebaseDatabase.instanceFor(
    app: firebaseApp,
    databaseURL: 'https://firedev-64a4e-default-rtdb.firebaseio.com/');

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  DatabaseReference databaseReference = rtdb.ref();
  List<Map<dynamic, dynamic>> tasks = [];
  int _currentIndex = 0; // Added to keep track of the selected tab index

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  _fetchTasks() {
    if (user != null) {
      databaseReference
          .child('users')
          .child(user!.uid)
          .child('tasks')
          .onValue
          .listen((event) {
        var taskData = event.snapshot.value as Map<dynamic, dynamic>?;
        if (taskData != null) {
          tasks = taskData.entries
              .map((entry) => {"id": entry.key, ...entry.value})
              .toList();
        } else {
          tasks = [];
        }
        setState(() {});
      });
    }
  }

  _deleteTask(String taskId) {
    if (user != null) {
      databaseReference
          .child('users')
          .child(user!.uid)
          .child('tasks')
          .child(taskId)
          .remove()
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted!')),
        );
      });
    }
  }

  _deleteAllTasks() {
    if (user != null) {
      databaseReference
          .child('users')
          .child(user!.uid)
          .child('tasks')
          .remove()
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted!')),
        );
      });
    }
  }


  _performLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully!')),
    );
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToAddTaskPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _currentIndex == 0 ? 'Dashboard' : 'Profile',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.blue.shade900,
        actions: [
          if (_currentIndex == 1)
          
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () => _performLogout(context),
            ),
        ],
      ),
      body: _currentIndex == 0
          ? tasks.isEmpty
              ? const Center(
                  child: Text(
                    'No data added yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) => Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        title: Text(
                          tasks[index]['subject'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Priority: ${tasks[index]['priority']}',
                          style: TextStyle(
                            color: tasks[index]['priority'] == 'high'
                                ? Colors.red
                                : tasks[index]['priority'] == 'medium'
                                    ? Colors.orange
                                    : Colors.green,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.deepPurple),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TodoPage(editTask: tasks[index]),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: const Text(
                                          "Are you sure you want to delete this task?"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text("Delete"),
                                          onPressed: () {
                                            _deleteTask(tasks[index]['id']);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content:
                                                      Text('Task deleted!')),
                                            );
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
          : ProfilePage(user: user),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _navigateToAddTaskPage,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

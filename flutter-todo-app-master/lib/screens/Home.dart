import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/todo_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import './trash.dart';
import './LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ToDo> todosList = [];
  List<ToDo> trashList = [];
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();

  void logOut() async {
    await FirebaseFirestore.instance.terminate();
    Navigator.pushNamed(context, '/hero');
  }

  @override
  void initState() {
    super.initState();
    _loadToDoList();
  }

  void _showProfileOverlay() {
    OverlayEntry overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return Positioned(
        top: ui.window.padding.top + kToolbarHeight,
        right: 8,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 250,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shafay Iqbal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text('shafay2iqbal@gmail.com'),
                Text(
                    'Pending tasks: ${todosList.where((t) => !t.isDone).length}'),
              ],
            ),
          ),
        ),
      );
    });

    Overlay.of(context)!.insert(overlayEntry);

    // Close the overlay when tapping anywhere on the screen
    Future.delayed(Duration(milliseconds: 50)).then((value) {
      GestureBinding.instance!.pointerRouter.addGlobalRoute((event) {
        if (event is PointerDownEvent) {
          overlayEntry.remove();
          GestureBinding.instance!.pointerRouter.removeGlobalRoute((event) {});
        }
      });
    });
  }

  // _loadToDoList() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? jsonToDoList = prefs.getString('todoList');
  //   String? jsonTrashList = prefs.getString('trashList'); // Add this line
  //   if (jsonToDoList != null) {
  //     List<dynamic> decodedJson = jsonDecode(jsonToDoList);
  //     todosList.addAll(decodedJson.map((item) => ToDo.fromJson(item)).toList());
  //   }
  //   if (jsonTrashList != null) {
  //     // Add this block
  //     List<dynamic> decodedJson = jsonDecode(jsonTrashList);
  //     trashList.addAll(decodedJson.map((item) => ToDo.fromJson(item)).toList());
  //   }
  //   setState(() {
  //     _foundToDo = todosList;
  //   });
  // }

  _loadToDoList() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    CollectionReference<Map<String, dynamic>> todoCollection = FirebaseFirestore
        .instance
        .collection("users")
        .doc(user.uid)
        .collection("todoList");
    CollectionReference<Map<String, dynamic>> trashCollection =
        FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("trashList");

    try {
      QuerySnapshot<Map<String, dynamic>> todoQuerySnapshot =
          await todoCollection.get();
      todosList = todoQuerySnapshot.docs
          .map((doc) => ToDo.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print("Error retrieving todo list: $e");
    }

    try {
      QuerySnapshot<Map<String, dynamic>> trashQuerySnapshot =
          await trashCollection.get();
      trashList = trashQuerySnapshot.docs
          .map((doc) => ToDo.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print("Error retrieving trash list: $e");
    }

    setState(() {
      _foundToDo = todosList;
    });
  }

  // _saveToDoList() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String jsonToDoList = jsonEncode(todosList);
  //   String jsonTrashList = jsonEncode(trashList); // Add this line
  //   prefs.setString('todoList', jsonToDoList);
  //   prefs.setString('trashList', jsonTrashList); // Add this line
  // }

  // _saveToDoList() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   final userId = user.uid;
  //   final todoListRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('todoList')
  //       .doc('my_todo_list');
  //   final trashListRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('trashList')
  //       .doc('my_trash_list');
  //   String jsonToDoList = jsonEncode(todosList);
  //   String jsonTrashList = jsonEncode(trashList);
  //   await todoListRef.set({'data': jsonToDoList});
  //   await trashListRef.set({'data': jsonTrashList});
  // }
  _saveToDoList() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final todoListRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('todoList')
          .doc('my_todo_list');
      final trashListRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('trashList')
          .doc('my_trash_list');
      String jsonToDoList = jsonEncode(todosList);
      String jsonTrashList = jsonEncode(trashList);
      await todoListRef.set({'data': jsonToDoList});
      await trashListRef.set({'data': jsonTrashList});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                searchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: 50,
                          bottom: 20,
                        ),
                        child: Text(
                          'Goals to Reach',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for (ToDo todoo in _foundToDo.reversed)
                        ToDoItem(
                          todo: todoo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                    left: 20,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                        hintText: 'New goals to reach',
                        border: InputBorder.none),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: 20,
                  right: 20,
                ),
                child: ElevatedButton(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  onPressed: () {
                    _addToDoItem(_todoController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: tdBlue,
                    minimumSize: Size(60, 60),
                    elevation: 10,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF83E1FF),
            ),
            child: Text(
              'TR List\nBy Team Reach',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text(
              'Home',
              style: TextStyle(color: Color(0xFF83E1FF)),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(
              'Settings',
              style: TextStyle(color: Color(0xFF83E1FF)),
            ),
            onTap: () {
              // Add navigation to the Settings screen
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text(
              'Trash',
              style: TextStyle(color: Color(0xFF83E1FF)),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Trash(trashList: trashList)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text(
              'Help',
              style: TextStyle(color: Color(0xFF83E1FF)),
            ),
            onTap: () {
              // Add navigation to the Help screen
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(
              'Logout',
              style: TextStyle(color: Color(0xFF83E1FF)),
            ),
            onTap: () {
              // Navigate to the Login screen and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          )
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
    _saveToDoList();
  }

  void _deleteToDoItem(String id) {
    setState(() {
      ToDo itemToRemove = todosList.firstWhere((item) => item.id == id);
      trashList.add(itemToRemove);
      todosList.removeWhere((item) => item.id == id);
    });
    _saveToDoList();
  }

  void _addToDoItem(String toDo) {
    if (toDo.length == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Oops, looks like you entered an empty note, Try Again!"),
        ),
      );
      return;
    }
    setState(() {
      todosList.add(ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: toDo,
      ));
    });
    _todoController.clear();
    _saveToDoList();
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: searchColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          // contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: '  Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(
              Icons.menu,
              color: tdBlack,
              size: 30,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      actions: [
        GestureDetector(
          onTap: _showProfileOverlay,
          child: Container(
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/avatar2.jpeg'),
            ),
          ),
        ),
        // Add some padding to the right of the avatar
        SizedBox(width: 8),
      ],
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/todo.dart';
import './home.dart';

class Trash extends StatefulWidget {
  final List<ToDo> trashList;
  final User user; // Add this line

  Trash({required this.trashList, required this.user}); // Update this line

  @override
  _TrashState createState() => _TrashState();
}


class _TrashState extends State<Trash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trash'),
      ),
      drawer: _buildDrawer(), // Add the hamburger menu
      body: ListView.builder(
        itemCount: widget.trashList.length,
        itemBuilder: (context, index) {
          final item = widget.trashList[index];
          return ListTile(
            title: Text(item.todoText!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.restore),
                  onPressed: () {
                    // Add functionality to restore the item
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: () {
                    // Add functionality to permanently delete the item
                  },
                ),
              ],
            ),
          );
        },
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(user: widget.user),
                ),
              );
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
        ],
        ),
    );
    }
 AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFF83E1FF),
      elevation: 0,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      title: Text(
        'Trash',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

}

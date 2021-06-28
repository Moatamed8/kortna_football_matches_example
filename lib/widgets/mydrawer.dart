import 'package:flutter/material.dart';
import 'package:soccer/screen/2018.dart';
import 'package:soccer/screen/2019.dart';
import 'package:soccer/screen/2020.dart';
import 'package:soccer/screen/2021.dart';
import 'package:soccer/screen/about_screen.dart';
import 'package:soccer/screen/injuries.dart';


class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          Container(

            width: double.infinity,
            height: 200,
            color: Color(0xFFB7C4C6),
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Image.asset('assets/icons/img.png'),
            ),
            
          ),
          Divider(),
          ListTile(
            title: Text("Live now"),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text("Injuries"),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                Navigator.pushNamed(context, Injuries.routeName);
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text("About Developer"),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                Navigator.pushNamed(context, AboutScreen.routeName);
              },
            ),
          ),
          ExpansionTile(
            title: Text("Permier league Seasons"),
            children: [
              ListTile(
                title: Text("Season 2021"),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.pushNamed(context, W2021.routeName);
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text("Season 2020"),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.pushNamed(context, W2020.routeName);
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text("Season 2019"),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.pushNamed(context, W2019.routeName);
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text("Season 2018"),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.pushNamed(context, W2018.routeName);
                  },
                ),
              ),
            ],
          ),



        ],
      ),
    );
  }
}

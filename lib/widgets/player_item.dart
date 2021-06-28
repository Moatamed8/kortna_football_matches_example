
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soccer/models/injplayers.dart';

Widget playerItem(InjuPlayer injured){
  return  Container(
    width: double.infinity,
    height: 150,
    margin: EdgeInsets.all(10),
    child: Stack(
      children: [
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 10),
          alignment: Alignment.topLeft,
          height: 170,
          width: 100,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                  injured.playerId.photo,
                ),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 50, left: 120),
          child: Column(
            children: [
              Container(
                alignment: FractionalOffset.topLeft,
                margin: EdgeInsets.only(top: 5),
                child: Text(injured.playerId.name,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              Container(
                alignment: FractionalOffset.topLeft,
                margin: EdgeInsets.only(top: 5),
                child: Text("${injured.playerId.type} )",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.amber)),
              ),
              Container(
                alignment: FractionalOffset.topLeft,
                margin: EdgeInsets.only(top: 5),
                child: Text("reason:${injured.playerId.reason}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey)),
              ),
              Container(
                alignment: FractionalOffset.topLeft,
                margin: EdgeInsets.only(top: 5),
                child: Text("Team: ${injured.team.name}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.lightGreen)),
              ),
            ],
          ),
        ),
      ],
    ),
  );

}











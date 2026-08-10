// perbaiki temp boutaFill penggunaan nya, arsitektur baru di ubah

import 'dart:collection';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';

List<List<int?>> defineListBlueprint() {
  List<List<int?>> temp = [];
  for (int i = 0; i < 9; i++) {
    temp.add([]);
    for (var j = 0; j < 9; j++) {
      temp[i].add(i + j);
    }
  }
  return temp;
}

List<List<int?>> startBlueprint = defineListBlueprint();

void main() {
  runApp(MainApp());
}

class Cells {
  String show = "";
  String chosen = "";
  Color color = Colors.white;
  String answer = "";
  List<String> possible = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
}

List<List<Cells>> cells = List.generate(
  9,
  (index) => List.generate(9, (index) => Cells()),
);
String mode = "chosen";

class Coordinate {
  static int? x;
  static int? y;
  static String? value;
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

void colorchange(String coordinate, int value, Color result) {
  late int x;
  late int y;
  if (coordinate == "x") {
    x = value;
  } else {
    y = value;
  }
  for (int i = 0; i < 9; i++) {
    if (coordinate == "x") {
      y = i;
    } else {
      x = i;
    }
    cells[x][y].color = result;
  }
}

void allwhite() {
  for (int i = 0; i < 9; i++) {
    colorchange("x", i, Colors.white);
  }
}

void surrounding(int x, int y) {
  x = (x ~/ 3) * 3;
  y = (y ~/ 3) * 3;
  for (int i = x; i < x + 3; i++) {
    for (int j = y; j < y + 3; j++) {
      cells[i][j].color = Colors.grey.shade400;
    }
  }
}

void show() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (mode == "chosen") {
        cells[i][j].show = cells[i][j].chosen;
      } else if (mode == "possible") {
        cells[i][j].show = "${cells[i][j].possible}";
      } else if (mode == "answer") {
        cells[i][j].show = cells[i][j].answer;
      }
    }
  }
}

class Kosong {
  List<List<int?>> list;
  List<int> avilableX;
  List<List<int>> avilableY;
  int counter = 0;
  List<List<int>> queue = [];
  Kosong(this.list, this.avilableX, this.avilableY, );
}

class _MainAppState extends State<MainApp> {
  SizedBox cell(int x, int y) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Container(
        color: Colors.grey.shade300,
        child: Center(
          child: Container(
            margin: EdgeInsets.all(1),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  allwhite();
                  surrounding(x, y);
                  colorchange("x", x, Colors.grey.shade400);
                  colorchange("y", y, Colors.grey.shade400);
                  cells[x][y].color = Colors.grey.shade500;
                  Coordinate.x = x;
                  Coordinate.y = y;
                  Coordinate.value = cells[x][y].chosen;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cells[x][y].color,
                elevation: 0,
                padding: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text(
                cells[x][y].show,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column box(int y, int x) {
    x = 3 * (x - 1);
    y = 3 * (y - 1);
    return Column(
      children: [
        Row(children: [cell(x, y), cell(x + 1, y), cell(x + 2, y)]),
        Row(children: [cell(x, y + 1), cell(x + 1, y + 1), cell(x + 2, y + 1)]),
        Row(children: [cell(x, y + 2), cell(x + 1, y + 2), cell(x + 2, y + 2)]),
      ],
    );
  }

  List<Widget> rowchildren(int y) {
    return [
      box(y, 1),
      Expanded(child: Container(color: Colors.grey)),
      box(y, 2),
      Expanded(child: Container(color: Colors.grey)),
      box(y, 3),
    ];
  }

  void crosskill(int x, int y, String value) {
    for (int i = 0; i < 9; i++) {
      cells[x][i].possible.remove(value);
      cells[i][y].possible.remove(value);
      if (mode == "possible") {
        cells[x][i].show = "${cells[x][i].possible}";
        cells[i][y].show = "${cells[i][y].possible}";
      }
    }
  }

  void surroundkill(int x, int y, String value) {
    x = (x ~/ 3) * 3;
    y = (y ~/ 3) * 3;
    for (int i = x; i < x + 3; i++) {
      for (int j = y; j < y + 3; j++) {
        cells[i][j].possible.remove(value);
        if (mode == "possible") {
          cells[i][j].show = "${cells[i][j].possible}";
        }
      }
    }
  }

  void fillrandom(int x, int y) {
    int tempIndex = Random().nextInt(cells[x][y].possible.length);
    String value = cells[x][y].possible[tempIndex];
    cells[x][y].answer = value;
    crosskill(x, y, value);
    surroundkill(x, y, value);
    cells[x][y].possible = [value];
    if (mode == "answer") {
      setState(() {
        cells[x][y].show = value;
      });
    } else if (mode == "possible") {
      setState(() {
        cells[x][y].show = "${cells[x][y].possible}";
      });
    }
  }

  void reset() {
    for (var i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        cells[i][j].answer = "";
        cells[i][j].chosen = "";
        cells[i][j].show = "";
        cells[i][j].possible = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
      }
    }
  }

  List<int>? checker() {
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        if (cells[i][j].possible.length <= 1 && cells[i][j].answer == "") {
          print([i,j]);
          return [i,j];
        }
      }
    }
    for (var i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        for (int k = 0; k < 9; k++) {
          // check for every single number in a box relation
        }
      }
    }
    return null;
  }

  List<dynamic>? checker2(int x,int y){
    List<List<int>> queue = [];
    int a = (x ~/ 3)*3;
    int b = (y ~/ 3)*3;
    String number = cells[x][y].answer;
    List<int>? retcoordinate;
    if (true) {
      // possible length for horizontal and vertical line
      for (var i = 0; i < 9; i++) {
        if (cells[x][i].answer=="" && queue.contains([x,i]) == false && cells[x][i].possible.length==1) {
          print('line possible vertical 2');
          queue.add([x,i]);
        }
        if (cells[i][y].answer=="" && queue.contains([i,y]) == false && cells[i][y].possible.length==1) {
          print('line possible horizontal 2');
          queue.add([i,y]);
        }
      }
      // possible length for box
      for (var i = a; i < a+3; i++) {
        for (int j = b; j<b+3; b++){
          print("x = $i");
          print("y = $j");
          if (cells[i][j].answer == "" && queue.contains([i,j]) == false && cells[i][j].possible.length==1) {
            print("box possible 2");
            queue.add([i,j]);
          }
        }
      }
      if (queue.isNotEmpty) {
        return queue;
      }
    }

    if (true) {
      // number possibility for horizontal and vertical line

      // check wich number is not there yet
      // i think i could use like array for that


      for (var i = 0; i < 9; i++) {
        if (cells[x][i].answer=="" && queue.contains([x,i]) == false && cells[x][i].possible.contains(k)) {
          print('number possible vertical 2');
          queue.add([x,i]);
        }
        if (cells[i][y].answer=="" && queue.contains([i,y]) == false && cells[i][y].possible.contains(k)) {
          print('number possible horizontal 2');
          queue.add([i,y]);
        }
      }
      // possible length for box
      for (var i = a; i < a+3; i++) {
        for (int j = b; j<b+3; b++){
          print("x = $i");
          print("y = $j");
          if (cells[i][j].answer == "" && queue.contains([i,j]) == false && cells[i][j].possible.contains(k)) {
            print("number possible box 2");
            queue.add([i,j]);
          }
        }
      }
      if (queue.isNotEmpty) {
        return queue;
      }
    }

    if (true){
      for (int i = 0; i < 9; i=i+3) {
        // print("atas");
        int count=0;
        // print("i = $i");
        // print("a = $a");
        // print("b = $b");
        for (int j = a; j < a+3; j++) {
          if (i==b){
            // print('skip, x = $j, y = $i');
            break;
          }
          for (int k = i; k < i+3; k++) {
            // print("x = $j");
            // print("y = $k");
            if (cells[j][k].answer==""){
              if (cells[j][k].possible.contains(number)) {
                count++;
                retcoordinate=[j,k];
              }
            }
          }
        }
        if(count==1){
          print("box checker2, vertikal");
          cells[retcoordinate![0]][retcoordinate[1]].possible=[number];
          return retcoordinate;
        }
        count=0;
        // print("bawah");
        for (var j = i; j < i + 3; j++) {
          if (i==a){
            // print('skip, x = $i, y = $b');
            break;
          }
          for (var k = b; k < b+3; k++) {
            // print("x = $j");
            // print("y = $k");
            if (cells[j][k].answer==""){
              if (cells[j][k].possible.contains(number)){
                count++;
                retcoordinate=[j,k];
              }
            }
          }
        }
        if (count==1) {
          print("box checker2, horizontal");
          cells[retcoordinate![0]][retcoordinate[1]].possible=[number];
          return retcoordinate;
        }
      }
    }
    // print("");
    // print("");
    // print("");
    return null;
  }

  List<int>? next;

  void createpuzzle() {
    reset();
    Kosong boutaFill = Kosong(
      List.from(startBlueprint),
      List.generate(9, (index) => index),
      List.generate(9, (index1) => List.generate(9, (index2) => index2))
    );
    while (boutaFill.avilableX.isNotEmpty) {
      
    }
  }
  Kosong boutaFill = Kosong(
    List.from(startBlueprint),
    List.generate(9, (index) => index),
    List.generate(9, (index1) => List.generate(9, (index2) => index2))
  );
  void steppuzzle() {
      dynamic tempRandom;
      late int x;
      late int y;
      if (next != null){
        tempRandom=next;
        next=null;
      }else if(boutaFill.queue.isNotEmpty){
        tempRandom = boutaFill.queue[0];
        boutaFill.queue.removeAt(0);
      }else{
        tempRandom = checker();
      }
      // ignore: prefer_conditional_assignment
      if (tempRandom == null) {
        x = boutaFill.avilableX[Random().nextInt(boutaFill.avilableX.length)];
        y = boutaFill.avilableY[x][Random().nextInt(boutaFill.avilableY[x].length)];
      }else{
        x=tempRandom[0];
        y=tempRandom[1];
      }
      // isi answer dengan koordinat yg sudah di dapat
      fillrandom(x, y);
      // set variabel agar tidak di pakai atau terpilih kembali
      try {
        boutaFill.list[x][y] = null;
      } catch (e) {
        print(e);
      }
      boutaFill.avilableY[x].remove(y);
      if (boutaFill.avilableY[x].isEmpty){
        boutaFill.avilableX.remove(x);
      }
      // pengecekan ke dua (mungkin mempercepat pengecekan) dilakukan untuk dapat koordinat next
      dynamic temp = checker2(x, y);
      if (temp.runtimeType==List<int>){
        next = temp;
      } else if(temp.runtimeType==List<List<int>>){
        boutaFill.queue.addAll(temp);
      }else if (temp.runtimeType != Null){
        print(temp.runtimeType);
      }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 80,
                margin: EdgeInsets.only(top: 60),
                color: Colors.red,
                child: Row(
                  children: [
                    Center(
                      child: Container(
                        width: 55,
                        height: 55,
                        color: Colors.brown,
                        child: Container(
                          child: FloatingActionButton(
                            onPressed: () {
                              createpuzzle();
                            },
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 55,
                        height: 55,
                        color: Colors.brown,
                        child: Container(
                          child: FloatingActionButton(
                            onPressed: () {
                              steppuzzle();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 10, left: 10, bottom: 50),
                  child: Column(
                    children: [
                      Container(
                        color: Colors.cyan.shade50,
                        width: 375,
                        height: 424,
                        child: Center(
                          child: Container(
                            color: Colors.black,
                            margin: EdgeInsets.only(top: 50),
                            child: Container(
                              margin: EdgeInsets.all(4),
                              color: Colors.grey,
                              child: Column(
                                children: [
                                  Row(children: rowchildren(1)),
                                  Expanded(child: Container()),
                                  Row(children: rowchildren(2)),
                                  Expanded(child: Container()),
                                  Row(children: rowchildren(3)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 20),
                          color: Colors.green,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 10,
                                    ),
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        if (mode == "chosen") {
                                          mode = "possible";
                                        } else if (mode == "possible") {
                                          mode = "answer";
                                        } else if (mode == "answer") {
                                          mode = "chosen";
                                        }
                                        setState(() {
                                          mode = mode;
                                        });
                                        show();
                                      },
                                      child: Text('mode : $mode'),
                                    ),
                                  ),
                                ],
                              ),
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(9, (index) {
                                    return Container(
                                      height: 70,
                                      width: 36,
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 2.5,
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.all(0),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            cells[Coordinate.x!][Coordinate.y!]
                                                    .chosen =
                                                "${index + 1}";
                                            if (mode == "chosen") {
                                              cells[Coordinate.x!][Coordinate
                                                          .y!]
                                                      .show =
                                                  "${index + 1}";
                                            }
                                          });
                                        },
                                        child: Text(
                                          "${index + 1}",
                                          style: TextStyle(
                                            fontSize: 50,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  // just learn how to do this :v very helpfull
  ///vertical list on x(wich is constant, [4,0], [4,1] etc)
  List<List<String>> avilableYForEach; 
  ///horizontal list on y(wich is constant, [0,4], [1,4] etc)
  List<List<String>> avilableXForEach; 
  List<List<List<String>>> avilableBox;
  int counter = 0;
  List<List<int>> queue = [];
  List<BackTrack> backTrack = [];
  List<BackTrackVersion2> backtrackversion2 = [];
  Kosong(this.list, this.avilableX, this.avilableY, this.avilableXForEach, this.avilableYForEach, this.avilableBox );
}

class BackTrack {
  String name = "unknown";
  List<int> coordinate;
  List<String> possible;
  List<BackTrackChild> list = [];
  BackTrack(this.name, this.coordinate, this.possible);
}

class BackTrackChild {
  String name = "child";
  List<int> coordinate;
  List<String> possible;
  BackTrackChild(this.coordinate, this.possible);
}

class BackTrackVersion2 {
  List<List<Cells>> table = [];
  List<List<int>> queue = [];
  BackTrackVersion2(this.table, this.queue);
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
                  // i dont think coordinate value is used
                  Coordinate.value = cells[x][y].chosen;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cells[x][y].color,
                elevation: 0,
                padding: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: mode != "possible"
              ? Text(
                cells[x][y].show,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 30),
              )
              : Text(
                cells[x][y].show,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 10),
              )
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

  

  List<dynamic>? checker2(int x,int y, Kosong boutaFill){
    List<List<int>> queue = boutaFill.queue;
    int a = (x ~/ 3)*3;
    int b = (y ~/ 3)*3;
    String number = cells[x][y].answer;
    List<int>? retcoordinate;

    // 2 directional box checker for answer number only
    if (true){
      for (int i = 0; i < 9; i=i+3) {
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
        if(count==1 && queue.contains(retcoordinate) == false){
          print("box checker, vertical");
          boutaFill.backTrack.add(BackTrack("box checker, vertical", retcoordinate!, cells[retcoordinate[0]][retcoordinate[1]].possible));
          cells[retcoordinate![0]][retcoordinate[1]].possible=[number];
          queue.add(retcoordinate);
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
        if (count==1 && queue.contains(retcoordinate)== false) {
          print("box checker, horizontal");
          boutaFill.backTrack.add(BackTrack("box checker, horizontal", retcoordinate!, cells[retcoordinate[0]][retcoordinate[1]].possible));
          cells[retcoordinate![0]][retcoordinate[1]].possible=[number];
          queue.add(retcoordinate);
        }
      }
    }

    if (true) {
      // possible length for horizontal and vertical line





      
      // i dont know why but the queue.contains == false is not working like it should work
      // i would just check on it from the steppuzzle (temporalily solution i think)
      for (var i = 0; i < 9; i++) {
        if (cells[x][i].answer=="" && queue.contains([x,i]) == false && cells[x][i].possible.length==1) {
          print('line possible vertical one possibility');
          boutaFill.backTrack.add(BackTrack("line possible vertical one possibility", [x,i], cells[x][i].possible));
          queue.add([x,i]);
        }
        if (cells[i][y].answer=="" && queue.contains([i,y]) == false && cells[i][y].possible.length==1) {
          print('line possible horizontal one possibility');
          boutaFill.backTrack.add(BackTrack("line possible horizontal one possibility", [i,y], cells[i][y].possible));
          queue.add([i,y]);
        }
      }
      // possible length for box
      for (var i = a; i < a+3; i++) {
        for (int j = b; j<b+3; j++){
          if (cells[i][j].answer == "" && queue.contains([i,j]) == false && cells[i][j].possible.length==1) {
            print("box possible one possibility");
            print("x = $i");
            print("y = $j");
            boutaFill.backTrack.add(BackTrack("box possible one possibility", [i,j], cells[i][j].possible));
            queue.add([i,j]);
          }
        }
      }
    }
    
    // need some sirious checking on this one <done all of it>
    if (true) {
      // number possibility for horizontal and vertical line

      // check wich number is not there yet  <done>
      // i think i could use like array for that  <done>


      // make it count on the true if and add some logic  <done>
      int countX = 0;
      int countY = 0;
      int countC = 0;
      List<int> tempco = [];
      for (String k in boutaFill.avilableXForEach[y]) {
        countX=0;
        for (var i = 0; i < 9; i++) {
          if (cells[x][i].answer=="" && cells[x][i].possible.contains(k)) {
            countX++;
            tempco = [x,i];
          }
        }
        if (countX==1 && queue.contains(tempco) == false){
          print("number possibile x on $tempco for $k");
          boutaFill.backTrack.add(BackTrack("number possibile x on $tempco for $k", tempco, cells[tempco[0]][tempco[1]].possible));
          cells[tempco[0]][tempco[1]].possible = [k];
          queue.add(tempco);
        }
      }
      for (String k in boutaFill.avilableYForEach[x]) {
        countY=0;
        for (var i = 0; i < 9; i++) {
          if (cells[i][y].answer=="" && cells[i][y].possible.contains(k)) {
            countY++;
            tempco = [i,y];
          }
        }
        if (countY==1 && queue.contains(tempco) == false){
          print("number possibile y on $tempco for $k");
          boutaFill.backTrack.add(BackTrack("number possibile y on $tempco for $k", tempco, cells[tempco[0]][tempco[1]].possible));
          cells[tempco[0]][tempco[1]].possible = [k];
          queue.add(tempco);
        }
      }
      // number possibility for box
      for (String k in boutaFill.avilableBox[x~/3][y~/3]) {
        for (var i = a; i < a+3; i++) {
          for (int j = b; j<b+3; j++){
            if (cells[i][j].answer == "" && cells[i][j].possible.contains(k)) {
              countC++;
              tempco = [i,j];
            }
          }
        }
        if (countC==1 && queue.contains(tempco) == false) {
          print("number possible Box on $tempco for $k");
          boutaFill.backTrack.add(BackTrack("number possibile Box on $tempco for $k", tempco, cells[tempco[0]][tempco[1]].possible));
          cells[tempco[0]][tempco[1]].possible = [k];
          queue.add(tempco);
        } else if(countC == 3 || countC == 2){
          // check horizontal and vertical, if its on the same line or thingy, then its fixed. idea of using the tempco, but rebuilt a lot, combined with seeing the tempc coordinate to see the horizontal and vertical coordinate
          // another idea, make the if to be one like if countc <=3 and >0 or mybe for in in range 3 for that
          int horiCount = 0;
          int vertiCount = 0;
          int horiCor = ((tempco[0]~/3)*3);
          // for example, x=3, then x=3 or x=4 then x=3
          int vertiCor = ((tempco[1]~/3)*3);
          for (int i = 0; i < 3; i++) {
            if(cells[horiCor+i][tempco[1]].possible.contains(k)){
              horiCount++;
            }
            if(cells[tempco[0]][vertiCor+i].possible.contains(k)){
              vertiCount++;
            }
          }
          /// 2 = nothing fit, no possibility to kill, 0 = vertically, 1 = horizontally
          int run = 2;
          int? boundriesBox;
          BackTrack tempBackTrack = BackTrack("double eliminator", tempco, cells[tempco[0]][tempco[1]].possible);
          if (vertiCount==countC){
            // vertically, like on x = 3, [3,6], [3,8] so need to lock the x position wich is 3
            print("Double eliminator vertical for $k");
            boundriesBox = (tempco[1]~/3)*3;
            run = 0;
          }
          if (horiCount==countC){
            // horizontally, like on y = 3, [6,3], [8,3] so need to lock the y position wich is 3
            // kill possibility after know wich line to kill
            // after finished, call checker2 again or smt because the possibility is choped
            print("Double eliminator horizontal for $k");
            boundriesBox = (tempco[0]~/3)*3;
            run = 1;
          }
          if (run!=2) {
            for (var i = 0; i < 9; i++) {
              if (i>=boundriesBox! && i<=boundriesBox+2){
                // skip when its in the boundries, but i dont know how yet :v
                // on python its continue or smt (it is continue :v)
                continue;
              }
              if (run == 0){
                tempBackTrack.list.add(BackTrackChild([tempco[0],i], cells[tempco[0]][i].possible));
                cells[tempco[0]][i].possible.remove(k);
              }else if (run == 1){
                tempBackTrack.list.add(BackTrackChild([i,tempco[1]], cells[i][tempco[1]].possible));
                cells[i][tempco[1]].possible.remove(k);
              }
            }
          }
          boutaFill.backTrack.add(tempBackTrack);
        }
      }
      if (queue.isNotEmpty) {
        return queue;
      }
    }

    // nothing catched by the checker 2
    return null;
  }

  List<int>? next;

  void createpuzzle() {
    reset();
    Kosong boutaFill = Kosong(
      List.from(startBlueprint),
      List.generate(9, (index) => index),
      List.generate(9, (index1) => List.generate(9, (index2) => index2)),
      List.generate(9, (index1) => List.generate(9, (index2) => "${index2+1}")),
      List.generate(9, (index1) => List.generate(9, (index2) => "${index2+1}")),
      List.generate(3, (index1) => List.generate(3, (index2) => List.generate(9, (index) => "${index+1}")))
    );
    while (boutaFill.avilableX.isNotEmpty) {
      
    }
  }
  Kosong boutaFill = Kosong(
    List.from(startBlueprint),
    List.generate(9, (index) => index),
      List.generate(9, (index1) => List.generate(9, (index2) => index2)),
      List.generate(9, (index1) => List.generate(9, (index2) => "${index2+1}")),
      List.generate(9, (index1) => List.generate(9, (index2) => "${index2+1}")),
      List.generate(3, (index1) => List.generate(3, (index2) => List.generate(9, (index) => "${index+1}")))
  );
  void steppuzzle() {
    dynamic tempRandom;
    late int x;
    late int y;
    String name = "";
    bool notqueue= true;
    // String corMotherLand = "";
    if (next != null){
      tempRandom=next;
      name = "next";
      next=null;
    }else if(boutaFill.queue.isNotEmpty){
      notqueue = false;
      do {
        tempRandom = boutaFill.queue[0];
        boutaFill.queue.removeAt(0);
      } while (cells[tempRandom[0]][tempRandom[1]].answer != "" && boutaFill.queue.isNotEmpty);
      // jika do while tidak menerima queue koordinat yang sesuai, maka lanjut ke checker
      if (cells[tempRandom[0]][tempRandom[1]].answer != ""){
        tempRandom = null;
        name = "checker 1, not checker 2";
        tempRandom = checker();
      }
    }else{
      name = "checker 1, not checker 2";
      tempRandom = checker();
    }
    // ignore: prefer_conditional_assignment
    if (tempRandom == null) {
      name = "random";
      x = boutaFill.avilableX[Random().nextInt(boutaFill.avilableX.length)];
      y = boutaFill.avilableY[x][Random().nextInt(boutaFill.avilableY[x].length)];
    }else{
      x=tempRandom[0];
      y=tempRandom[1];
    }
    if (notqueue){
      boutaFill.backTrack.add(BackTrack(name, [x,y], cells[x][y].possible));
    }

    print("x = $x    y = $y");
    
    if (cells[x][y].answer!=""){
      print("its wrong somewhere");
    }

    // problem, the list form did good job, but only on outer list, the iner list still in the form of a pointer not a copy
    List<List<Cells>> cellsCopy = [];
    List<Cells> insideCopy = [];
    for (var element in cells) {
      insideCopy = [];
      for (var element2 in element) {
        Cells temp = Cells();
        temp.answer=element2.answer;
        temp.chosen=element2.chosen;
        temp.possible=List.from(element2.possible);
        temp.show=element2.show;
        insideCopy.add(temp);
      }
      cellsCopy.add(List.from(insideCopy));
    }
    List<List<int>> queueCopy = [];
    for (var element in boutaFill.queue) {
      queueCopy.add(List.from(element));
    }
    boutaFill.backtrackversion2.add(BackTrackVersion2(List.from(cellsCopy), List.from(queueCopy)));
    // isi answer dengan koordinat yg sudah di dapat
    fillrandom(x, y);
    // set variabel agar tidak di pakai atau terpilih kembali
    try {
      boutaFill.list[x][y] = null;
    } catch (e) {
      print(e);
    }
    String value=cells[x][y].answer;
    boutaFill.avilableY[x].remove(y);
    boutaFill.avilableXForEach[y].remove(value);
    boutaFill.avilableYForEach[x].remove(value);
    boutaFill.avilableBox[x~/3][y~/3].remove(value);
    if (boutaFill.avilableY[x].isEmpty){
      boutaFill.avilableX.remove(x);
    }
    // pengecekan ke dua (mungkin mempercepat pengecekan) dilakukan untuk dapat koordinat next
    dynamic temp = checker2(x, y, boutaFill);
    if (temp.runtimeType==List<int>){
      next = temp;
    } else if(temp.runtimeType==List<List<int>>){
      boutaFill.queue=temp;
    }else if (temp.runtimeType != Null){
      print(temp.runtimeType);
    }
    // print("avilable x");
    // print("${boutaFill.avilableX}");
    // print("avilable y");
    // for (var i in boutaFill.avilableY) {
    //   print("$i");
    // }
    // print("boutaFill.backTrack");
    // for (BackTrack element in boutaFill.backTrack) {
    //   print("name = ${element.name}      coordinate = ${element.coordinate}");
    //   print(element.list);
    //   if (element.list==[]) {
    //   }
    // }
    print(boutaFill.queue);
    print("");
  }

  testing(){
  }

  undo(Kosong boutaFill){
    print("${boutaFill.backTrack.last.name}");
    boutaFill.backTrack.remove(boutaFill.backTrack.last);
    setState(() {
      cells=boutaFill.backtrackversion2.last.table;
    });
    boutaFill.queue=boutaFill.backtrackversion2.last.queue;
    boutaFill.backtrackversion2.removeLast();
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
                            child: Icon(Icons.extension),
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
                            child: Icon(Icons.extension),
                            onPressed: () {
                              steppuzzle();
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
                            child: Icon(Icons.undo),
                            onPressed: () {
                              undo(boutaFill);
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
                            child: Icon(Icons.help),
                            onPressed: () {
                              testing();
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
                                            if (mode == "possible"){
                                              if (cells[Coordinate.x!][Coordinate.y!].possible.contains("${index+1}")){
                                                cells[Coordinate.x!][Coordinate.y!].possible.remove("${index+1}");
                                                cells[Coordinate.x!][Coordinate.y!].show = "${cells[Coordinate.x!][Coordinate.y!].possible}";
                                              }else {
                                                cells[Coordinate.x!][Coordinate.y!].possible.add("${index+1}");
                                                cells[Coordinate.x!][Coordinate.y!].show = "${cells[Coordinate.x!][Coordinate.y!].possible}";
                                              }
                                            }else if(mode == "answer"){
                                              boutaFill.backTrack.add(BackTrack("manually inserted", [Coordinate.x!,Coordinate.y!], cells[Coordinate.x!][Coordinate.y!].possible));
                                              fillrandom(Coordinate.x!, Coordinate.y!);
                                            } else {
                                              cells[Coordinate.x!][Coordinate.y!].chosen = "${index + 1}";
                                              if (mode == "chosen") {
                                                cells[Coordinate.x!][Coordinate.y!].show = "${index + 1}";
                                              }
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

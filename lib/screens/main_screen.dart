import 'package:flutter/material.dart';
import 'package:istudy_courses/component/bottomBar.dart';

class HomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: const Text("Home"),),
      body: ListView.builder(itemCount: 10, itemBuilder: (context, index){
        return ListTile(
          leading: const Icon(Icons.home),
        );
      }),
    );
  }
}

//Schedule Screen
class ScheduleScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title:  Text("Schedule App")),
    );
  }
}
//....

//HANDLE BOTTOM BAR
class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen>{
  int _currentIndex=0;
  final List<Widget> _screens=[
    HomeScreen(),
    ScheduleScreen(),
    
  ];
  void _onItemTapped(int index){
    setState(() {
      _currentIndex=index;
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomBottomNavBar(
      child: _screens[_currentIndex],
      currentIndex:_currentIndex,
      onTap:_onItemTapped
    );
  }
}
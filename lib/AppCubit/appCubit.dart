

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/Models/homeModel/homeModel.dart';
import 'package:dego/Screens/bookmarkScreen/bookmarkScreen.dart';
import 'package:dego/Screens/downloadScreen/downloadScreen.dart';
import 'package:dego/Screens/homeScreen/homeScreen.dart';
import 'package:dego/Screens/notificationScreen/notificationScreen.dart';
import 'package:dego/Screens/trendingScreen/trendingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppCubit extends Cubit<AppCubitStates> {
  static BuildContext? context;

  AppCubit(AppCubitStates InitialAppCubitState) : super(InitialAppCubitState);

  static AppCubit get(context) => BlocProvider.of(context);

  int selectedIndex = 0;

  void onItemTapped(int index) {
      selectedIndex = index;
      emit(navigationState());
  }

  List<Widget> Screens =
  [
     HomeScreen(),
     TrendingScreen(),
     DownloadScreen(),
     BookmarkScreen(),
     NotificationScreen(),
  ] ;


  GetHomeScreen()
  {
    return FirebaseFirestore.instance.collection('Home').orderBy("time",descending: true);
  }

  List<HomeModel>HomeList = [];
  List<String>AppbarList = [];
  List<String>AppbarListIds = [];

  Stream<QuerySnapshot> GetAppbarList()
  {
    return FirebaseFirestore.instance.collection('appbarList').snapshots();
  }

  List<HomeModel>AppbarItemsList = [];
  String AppbarFirebaseId = 'Mlkw4wlq4MSWtSsazU19';

   GetAppbarListItems()
  {
    return FirebaseFirestore.instance.collection('appbarList').doc(AppbarFirebaseId)
        .collection('videoItems').orderBy("time",descending: true);
  }

   function(appbarListId)
   {
     AppbarFirebaseId = appbarListId;
     GetAppbarListItems();
     Future.delayed(Duration(seconds: 5)).then((value)
     {
       emit(getHomeState());
     });
   }

}

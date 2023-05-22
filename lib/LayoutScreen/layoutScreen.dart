
import 'package:dego/AppCubit/appCubit.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/Screens/homeScreen/homeScreen.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

class LayoutScreen extends StatefulWidget {
     LayoutScreen({Key? key}) : super(key: key);
    @override
    State<LayoutScreen> createState() => _LayoutScreenState();
  }
  class _LayoutScreenState extends State<LayoutScreen>  {

    @override
    Widget build(BuildContext context) {
      return BlocConsumer<AppCubit,AppCubitStates>(
        listener: (BuildContext context, state) {
          if(state is getHomeState)
          {
            setState(() {

            });
            print('tapped');
          }
        },
        builder: (BuildContext context, Object? state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading:LoadingWidget[AppCubit.get(context).selectedIndex],
              automaticallyImplyLeading: true,
              leadingWidth: 73.w,
              toolbarHeight: 8.h,elevation: .4,shadowColor:color1,
              actions:
              [
                IconButton(onPressed: (){}, icon:Image(image:  AssetImage('assets/images/search.png'),
                  color: color2,width: 6.5.w,),alignment: Alignment.centerRight,padding: EdgeInsets.only(right:2.sp)),
                IconButton(onPressed: (){}, icon:Image(image:  AssetImage('assets/images/menu.png'),
                  color: color2,width: 8.w,),alignment: Alignment.centerLeft),
                SizedBox(width: 2.w,),
              ],
            ),
            body: AppCubit.get(context).Screens[AppCubit.get(context).selectedIndex],
            bottomNavigationBar:BottomNavigationBar(
              unselectedItemColor:Colors.grey[500],selectedItemColor: color2,
              currentIndex: AppCubit.get(context).selectedIndex,showSelectedLabels: true,showUnselectedLabels: true,
              type:BottomNavigationBarType.fixed,
              onTap: AppCubit.get(context).onItemTapped,
              items:   [
                BottomNavigationBarItem(
                  icon: SizedBox(
                      height: 3.h,
                      width: 5.w,
                      child: Image(image:  AssetImage('assets/images/home.png'),color:AppCubit.get(context).selectedIndex==0?color2:Colors.grey[500],)),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                      height: 3.h,
                      width: 6.w,
                      child: Image(image:  AssetImage('assets/images/trending.png'),
                        color:AppCubit.get(context).selectedIndex==1?color2:Colors.grey[500],)),
                  label: 'Trending',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding:  EdgeInsets.only(top: 1.sp),
                    child: SizedBox(
                        height: 3.h,
                        width: 6.w,
                        child: Image(image:  AssetImage('assets/images/download.png'),color:AppCubit.get(context).selectedIndex==2?color2:Colors.grey[500],)),
                  ),
                  label: 'Download',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding:  EdgeInsets.only(top: 1.5.sp),
                    child: SizedBox(
                        height: 3.h,
                        width: 5.w,
                        child: Image(image:  AssetImage('assets/images/bookmark.png'),color:AppCubit.get(context).selectedIndex==3?color2:Colors.grey[500],)),
                  ),
                  label: 'Bookmark',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding:  EdgeInsets.only(top: 2.sp),
                    child: SizedBox(
                        height: 3.h,
                        width: 5.5.w,
                        child: Image(image:  AssetImage('assets/images/bell.png'),color:AppCubit.get(context).selectedIndex==4?color2:Colors.grey[500],)),
                  ),
                  label: 'Notification',
                ),
              ],
            ),
          );
        },
      );
    }
  }

List<Widget> LoadingWidget =
[
  BlocConsumer<AppCubit,AppCubitStates>(listener: (BuildContext context, state) {  },
  builder: (BuildContext context, Object? state) {
    return AppbarWidget();
  },),
  Center(child: Text('Trending',style: TextStyle(fontSize: 16.sp,color: color2,fontWeight: FontWeight.w700),)),
  Center(child: Text('Download',style: TextStyle(fontSize: 16.sp,color: color2,fontWeight: FontWeight.w700),)),
  Center(child: Text('Bookmark',style: TextStyle(fontSize: 16.sp,color: color2,fontWeight: FontWeight.w700),)),
  Center(child: Text('Notification',style: TextStyle(fontSize: 16.sp,color: color2,fontWeight: FontWeight.w700),)),
];
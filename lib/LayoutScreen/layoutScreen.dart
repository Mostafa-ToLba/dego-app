
import 'dart:io';

import 'package:dego/AppCubit/appCubit.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
class LayoutScreen extends StatefulWidget {
     const LayoutScreen({Key? key}) : super(key: key);
    @override
    State<LayoutScreen> createState() => _LayoutScreenState();
  }
  class _LayoutScreenState extends State<LayoutScreen>  with SingleTickerProviderStateMixin {
@override
  void initState() {
  AppCubit.get(context).tabController = TabController(length: 2, vsync: this);
  AppCubit.get(context).oppenAppLoaded==true?AppCubit.get(context).appOpenAd.show():null;
    super.initState();
  }
    @override
    Widget build(BuildContext context) {
      return BlocConsumer<AppCubit,AppCubitStates>(
        listener: (BuildContext context, state) {},
        builder: (BuildContext context, Object? state) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value:   SystemUiOverlayStyle(
            statusBarIconBrightness: AppCubit.get(context).selectedIndex==0?Brightness.light:Brightness.dark,
              systemNavigationBarIconBrightness: AppCubit.get(context).isDark?null:Brightness.dark,
            ),
            child: DefaultTabController(
              length: AppCubit.get(context).AppbarList.length,
              child: Scaffold(
                backgroundColor: Colors.white,
                  body: AppCubit.get(context).Screens[AppCubit.get(context).selectedIndex],
                bottomNavigationBar:BottomNavigationBar(
                  unselectedItemColor:Colors.grey[500],
                  currentIndex: AppCubit.get(context).selectedIndex,showSelectedLabels: true,showUnselectedLabels: true,
                  selectedItemColor: AppCubit.get(context).isDark?Colors.white:color2,
                  type:BottomNavigationBarType.fixed,
                  onTap: AppCubit.get(context).onItemTapped,
                  items:   [
                    BottomNavigationBarItem(
                      icon: SizedBox(
                          height: 3.h,
                          width: 5.5.w,
                          child: Image(image:const AssetImage('assets/images/home.png',),
                            color:AppCubit.get(context).selectedIndex==0?AppCubit.get(context).isDark?
                            Colors.white:color2:Colors.grey[500],
                          )),
                      label: 'Home'.tr(),
                    ),
                    BottomNavigationBarItem(
                      icon: SizedBox(
                          height: 3.h,
                          width: 6.w,
                          child: Image(image:  const AssetImage('assets/images/trending.png'),
                            color:AppCubit.get(context).selectedIndex==1?AppCubit.get(context).isDark?
                            Colors.white:color2:Colors.grey[500],fit: BoxFit.cover,
                          )),
                      label: 'Trending'.tr(),
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding:  EdgeInsets.only(top: 1.sp),
                        child: SizedBox(
                            height: 3.h,
                            width: 6.w,
                            child: Image(image:  const AssetImage('assets/images/download.png'),
                              color:AppCubit.get(context).selectedIndex==2?AppCubit.get(context).isDark?
                              Colors.white:color2:Colors.grey[500],fit: BoxFit.cover,)),
                      ),
                      label: 'Downloads'.tr(),
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding:  EdgeInsets.only(top: 1.5.sp),
                        child: SizedBox(
                            height: 3.h,
                            width: 5.5.w,
                            child: Image(image:  const AssetImage('assets/images/bookmark.png'),
                                color:AppCubit.get(context).selectedIndex==3?AppCubit.get(context).isDark?
                                Colors.white:color2:Colors.grey[500],)),
                      ),
                      label: 'Bookmark'.tr(),
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding:  EdgeInsets.only(top: 1.5.sp),
                        child: SizedBox(
                            height: 3.h,
                            width: 6.w,
                            child: Image(image:  const AssetImage('assets/images/bell.png',),
                              color:AppCubit.get(context).selectedIndex==4?AppCubit.get(context).isDark?
                            Colors.white:color2:Colors.grey[500],)),
                      ),
                      label: 'Notifications'.tr(),
                    ),
                  ],
                ),
                ),
            ),
          );
        },
      );
    }
  }

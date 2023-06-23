
import 'dart:async';
import 'dart:io';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/LayoutScreen/layoutScreen.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import '../../AppCubit/appCubit.dart';

class SplashScreen extends StatefulWidget {
      const SplashScreen({Key? key}) : super(key: key);
     @override
     State<SplashScreen> createState() => _SplashScreenState();
   }
   class _SplashScreenState extends State<SplashScreen> {

     @override
     void initState() {
       super.initState();
         Timer(const Duration(seconds: 2),()
         {
           Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
             builder:(context) =>  const LayoutScreen(),
           ), (route) => false);
         });

     }
     @override
     Widget build(BuildContext context) {
       return BlocConsumer<AppCubit,AppCubitStates>(
         listener: (BuildContext context, state) {  },
         builder: (BuildContext context, Object? state) {
           return Scaffold(
             body: ClipRRect(
               child: Stack(
                 alignment: Alignment.center,
                 children: [
                   Container(
                     color: AppCubit.get(context).isDark?Colors.black:color1,
                     height: double.infinity,
                     width:double.infinity ,
                   ),
                   Center(
                     child: Padding(
                       padding:  EdgeInsets.only(left: 7.w),
                       child: Image(image: const AssetImage('assets/images/dego-logo.png',),height:20.h,width: 20.h,
                           color:AppCubit.get(context).isDark?Colors.white:color2 ),
                     ),
                   ),
                 ],
               ),
             ),
           );
         },
       );
     }
   }

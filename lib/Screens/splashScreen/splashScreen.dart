
import 'dart:async';

import 'package:dego/LayoutScreen/layoutScreen.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatefulWidget {
     const SplashScreen({Key? key}) : super(key: key);

     @override
     State<SplashScreen> createState() => _SplashScreenState();
   }

   class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
     late AnimationController _controller;
     late Animation<double> _animation;

     @override
     void initState() {
       super.initState();
       _controller = AnimationController(
         vsync: this,
         duration: const Duration(seconds: 1),
       );
       _animation = Tween<double>(begin: 0, end: 1)
           .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
       _controller.forward();
       Timer(const Duration(seconds: 3),()
       {
         Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
           builder:(context) =>  LayoutScreen(),
         ), (route) => false);

       });
     }

     @override
     void dispose() {
       _controller.dispose();
       super.dispose();
     }

     @override
     Widget build(BuildContext context) {
       return AnnotatedRegion<SystemUiOverlayStyle>(
         value: const SystemUiOverlayStyle(
           statusBarColor: Colors.transparent,
           statusBarIconBrightness:  Brightness.dark,
         ),
         child: Scaffold(
           body: ClipRRect(
             child: Stack(
               alignment: Alignment.center,
               children: [
                 Container(
                   color: color1,
                   height: double.infinity,
                   width:double.infinity ,
                 ),
                 Center(
                   child: Opacity(
                     opacity: _animation.value,
                     child: Container(
                       child: Padding(
                         padding:  EdgeInsets.only(left: 7.w),
                         child: Image(image: const AssetImage('assets/images/dego-logo.png',),height:20.h,width: 20.h,),
                       ),
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

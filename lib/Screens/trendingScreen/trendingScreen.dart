

 import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/Models/homeModel/homeModel.dart';
import 'package:dego/Screens/notificationScreen/notificationScreen.dart';
import 'package:dego/Screens/searchScreen/searchScreen.dart';
import 'package:dego/Screens/videoOpen/videoOpen.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sizer/sizer.dart';

import '../../AppCubit/appCubit.dart';

class TrendingScreen extends StatefulWidget {
   const TrendingScreen({Key? key}) : super(key: key);

   @override
   State<TrendingScreen> createState() => _TrendingScreenState();
 }

 class _TrendingScreenState extends State<TrendingScreen> {
   late BannerAd _bottomBannerAd;
   bool _isBottomBannerAdLoaded = false;
   void _createBottomBannerAd() {
     _bottomBannerAd = BannerAd(
       adUnitId: Platform.isAndroid
           ? AppCubit.get(context).bannarAdNumber
           : 'ca-app-pub-9120321344983600/4388505138',
       size: AdSize.banner,
       request: AdRequest(),
       listener: BannerAdListener(
         onAdLoaded: (_) {
           setState(() {
             _isBottomBannerAdLoaded = true;
           });
         },
         onAdFailedToLoad: (ad, error) {
           ad.dispose();
         },
       ),
     );
     _bottomBannerAd.load();
   }
    @override
  void initState() {
      _createBottomBannerAd();
      Timer(const Duration(seconds: 1),()
      {
        AppCubit.get(context).showInterstialAd();
      });
    super.initState();
  }
  @override
  void dispose() {
    _bottomBannerAd.dispose();
    super.dispose();
  }

   @override
   Widget build(BuildContext context) {
     return BlocConsumer<AppCubit,AppCubitStates>(
       listener: (BuildContext context, state) {  },
       builder: (BuildContext context, Object? state) {
         return Scaffold(
           appBar: AppBar(
             elevation: 0,
             title: Text('Trending'.tr(),style: TextStyle(fontSize: translator.activeLanguageCode=='en'?16.sp:17.sp,color: AppCubit.get(context).isDark?
             Colors.white:color2,fontWeight: FontWeight.w700,
             ),),
             actions:
             [
               IconButton(onPressed: ()
               {
                 AppCubit.get(context).soundsFunc();
                 navigateTo(context, const SearchScreen());
               }, icon:Padding(
                 padding:  EdgeInsets.only(left: translator.isDirectionRTL(context)?0:15.sp,right:translator.isDirectionRTL(context)?15.sp:0),
                 child: Image(image:  const AssetImage('assets/images/search.png'),color: AppCubit.get(context).isDark?
                 Colors.white:color3,height: 18.sp),
               ),
            padding: EdgeInsets.zero, ),
               IconButton(onPressed: ()
               {
                 AppCubit.get(context).soundsFunc();
                 AppCubit.get(context).showBottomSheet(context);
               }, icon:Image(image: const AssetImage('assets/images/menu.png'),color: AppCubit.get(context).isDark?
               Colors.white:color3,),
               ),
               SizedBox(width:translator.isDirectionRTL(context)?1.w:0,),
             ],
           ),
           body: PaginateFirestore(
             itemBuilder: (context, documentSnapshots, index)
             {
               AppCubit.get(context).trendingList = [];
               for (var doc in documentSnapshots) {
                 AppCubit.get(context).trendingList.add(HomeModel(photo: doc['Ph'],video: doc['Vi'],text: doc['Tx'],
                   docId: doc.id,views:doc.data()!.toString().contains('views') ? doc['views'] : 0,
                   likes:doc.data()!.toString().contains('likes') ? doc['likes'] : 0, ));
               }
               return ConditionalBuilder(
                   condition: AppCubit.get(context).trendingList.isNotEmpty,
                   builder: (BuildContext context)=> TrendingWidget(AppCubit.get(context).trendingList[index],context,index),
                   fallback: (BuildContext context)=>const Center(child: CircularProgressIndicator(color: Colors.black)));

             }, // orderBy is compulsary to enable pagination
             query: FirebaseFirestore.instance.collection('Videos').orderBy("views", descending: true),
             itemBuilderType: PaginateBuilderType.gridView,
             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: .6,
               crossAxisSpacing: 2,
               mainAxisSpacing: 2,),
             scrollDirection: Axis.vertical,
             includeMetadataChanges: false, itemsPerPage:6,
             onPageChanged: (page) {

             },
             shrinkWrap: false,
             bottomLoader:const Text(''),
             isLive: false,
           ),
           bottomNavigationBar: _isBottomBannerAdLoaded
               ? Container(
             color: AppCubit.get(context).isDark
                 ? Colors.black
                 : Colors.white,
             height: _bottomBannerAd.size.height.toDouble(),
             width: _bottomBannerAd.size.width.toDouble(),
             child: AdWidget(ad: _bottomBannerAd),
           )
               : null,
         );
       },
     );
   }
 }

 Widget TrendingWidget(HomeModel trendingList, BuildContext context, int index,)=> BlocConsumer<AppCubit,AppCubitStates>(
   builder: (BuildContext context, state) {
     return InkWell(
       onTap: ()
       {
         if(AppCubit.get(context).interstialadCountForTrendScreen==3)
         {
           Timer(const Duration(milliseconds: 800),()
           {
             AppCubit.get(context).showInterstialAd();
             AppCubit.get(context).loadInterstialAd();
           });
         }
          if(AppCubit.get(context).interstialadCountForTrendScreen==0) {
           AppCubit.get(context).loadInterstialAd();
         }
         AppCubit.get(context).adCountForTrendScreen();
         AppCubit.get(context).incrementViews(docId:trendingList.docId);
         navigateTo(context, VideoOpen(trendingList.video!,trendingList.docId!,trendingList.likes!,trendingList.text!,trendingList.photo!,index));
       },
       child: Container(
         decoration: BoxDecoration(color: AppCubit.get(context).isDark?Colors.black:Colors.white,image: DecorationImage(image: CachedNetworkImageProvider('${trendingList.photo}',),fit: BoxFit.cover)),
         child: Align(
           alignment: Alignment.bottomRight,
           child: Padding(
             padding:  EdgeInsets.only(bottom: 4.sp,right:8.sp),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.end,
               crossAxisAlignment: CrossAxisAlignment.center,
               textDirection: TextDirection.ltr,
               children: [
                 StreamBuilder<QuerySnapshot>(
                   stream:AppCubit.get(context).getLikes(),
                   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                     int likes = 0;
                     if (!snapshot.hasData || snapshot.data!.size == 0)
                       return Text('0',style: TextStyle(fontSize: 11.sp,color: Colors.white,fontWeight: FontWeight.w600),);
                     else {
                       likes = 0;
                       for (var doc in snapshot.data!.docs) {
                         if (doc.id == trendingList.docId)
                           likes = doc['views'];
                       }
                     }
                     return Padding(
                       padding:  EdgeInsets.only(bottom:translator.isDirectionRTL(context)?2.sp:0),
                       child: Text(AppCubit.get(context).formatViews(likes),style:
                       TextStyle(fontSize:translator.isDirectionRTL(context)?10.5.sp:11.sp,color: Colors.white,fontWeight: FontWeight.w600),),
                     );
                   },
                 ),
                 SizedBox(width: 1.5.sp,),
                 Image.asset(
                   'assets/images/fire.png',
                   width: 11.sp,
                   height: 11.sp,
                 )
               ],
             ),
           ),
         ),
       ),
     );
   }, listener: (BuildContext context, Object? state) {  },
 );

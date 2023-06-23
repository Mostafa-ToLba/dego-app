
 import 'dart:io';

import 'package:dego/AppCubit/appCubit.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/Models/searchModel/searchModel.dart';
import 'package:dego/Screens/BookmarkVideo/BookmarkVideo.dart';
import 'package:dego/Screens/testScreen/testScreen.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:firestore_search/firestore_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sizer/sizer.dart';

class SearchScreen extends StatefulWidget {
   const SearchScreen({Key? key}) : super(key: key);

   @override
   State<SearchScreen> createState() => _SearchScreenState();
 }

 class _SearchScreenState extends State<SearchScreen> {
   late BannerAd _bottomBannerAd;
   bool _isBottomBannerAdLoaded = false;
   void _createBottomBannerAd() {
     _bottomBannerAd = BannerAd(
       adUnitId: Platform.isAndroid
           ? AppCubit.get(context).bannarAdNumber
           : 'ca-app-pub-9120321344983600/4388505138',
       size: AdSize.banner,
       request: const AdRequest(),
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
         return Stack(
           children: [
             FirestoreSearchScaffold(
               firestoreCollectionName: 'Videos',scaffoldBackgroundColor: Colors.white,
               searchBy: 'Tx',
               searchTextColor: Colors.black,
               backButtonColor: Colors.transparent,
               clearSearchButtonColor: Colors.black,
               scaffoldBody:  Padding(
                 padding: EdgeInsets.only(bottom: 8.h),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children:  [
                     const Image(image: AssetImage('assets/unDraw/search3.png',),fit: BoxFit.cover),
                     SlideFadeTransition(
                       curve: Curves.elasticOut,
                       delayStart: const Duration(milliseconds: 200),
                       animationDuration: const Duration(milliseconds: 1200),
                       offset: 2,
                       direction: Direction.vertical,
                       child: FittedBox(child: Text('search'.tr(),style: TextStyle(fontSize:translator.activeLanguageCode=='en'? 14.sp:14.sp,color: color2,fontWeight: FontWeight.w400),)),
                     ),
                   ],
                 ),
               ),
               dataListFromSnapshot: DataModel().dataListFromSnapshot,
               builder: (context, snapshot) {
                 if (snapshot.hasData) {
                   final List<DataModel>? dataList = snapshot.data;
                   if (dataList!.isEmpty) {
                     return  Center(
                       child: Text(translator.isDirectionRTL(context)? 'لا توجد نتائج':'No Results Returned',style:
                       TextStyle(fontFamily:translator.isDirectionRTL(context)?arbFont:engFont,fontSize: 12.sp ),),
                     );
                   }
                   return Padding(
                     padding:  EdgeInsets.all(8.sp),
                     child: ListView.separated(
                         itemBuilder: (context,index)=>SearchWidget(dataList[index],context),
                         separatorBuilder: (context,index)=>SizedBox(height: 2.h),
                         itemCount: dataList.length),
                   );
                 }

                 if (snapshot.connectionState == ConnectionState.done) {
                   if (!snapshot.hasData) {
                     return const Center(
                       child: Text('No Results Returned'),
                     );
                   }
                 }
                 return const Center(
                   child: CircularProgressIndicator(),
                 );
               },
             ),
             Align(
               alignment: Alignment.bottomCenter,
               child: _isBottomBannerAdLoaded? Container(
                 color: AppCubit.get(context).isDark
                     ? Colors.black
                     : Colors.white,
                 height: _bottomBannerAd.size.height.toDouble(),
                 width: _bottomBannerAd.size.width.toDouble(),
                 child: AdWidget(ad: _bottomBannerAd),
               ):Container(),
             ),
           ],
         );
       },
     );
   }
 }

 Widget SearchWidget(DataModel searchedForText,context)=>Stack(
   children: [
     Container(
       height: 24.h,
       width: double.infinity,
       decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(20.sp),
           image:DecorationImage(fit: BoxFit.cover,image: NetworkImage(searchedForText.ph.toString()))),
     ),
     Positioned(
       top: 9.h,left: 41.w,
       child: IconButton(
         iconSize: 10.w,
         icon: Image(
             height: 28.sp,
             image: const AssetImage('assets/images/play.png',),color: Colors.white),
         onPressed: () {
           navigateTo(context, BookmarkVideo(searchedForText.video!,searchedForText.ph!,searchedForText.text!,));
         },),
     ),
     Positioned(
       bottom: 1.5.h,right: 4.w,
       child: SizedBox(
           width: 70.w,
           child: Text(
             textDirection: TextDirection.rtl,textAlign: TextAlign.start,searchedForText.text.toString(),style:
           TextStyle(fontSize: 12.sp,color: Colors.white,fontWeight: FontWeight.w800),)),
     ),
   ],
 );
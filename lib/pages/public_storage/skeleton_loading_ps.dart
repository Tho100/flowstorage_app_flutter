import 'dart:async';

import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SkeletonLoadingPs extends StatefulWidget {

  const SkeletonLoadingPs({super.key});

  @override
  State<SkeletonLoadingPs> createState() => SkeletonLoadingState();
}

class SkeletonLoadingState extends State<SkeletonLoadingPs> {

  final durationGradient = const Duration(milliseconds: 859);

  final gradientColors = [
    [ThemeColor.secondaryWhite, ThemeColor.thirdWhite],
    [ThemeColor.thirdWhite, ThemeColor.secondaryWhite],
  ];

  final currentGradientIndexNotifier = ValueNotifier<int>(0);

  late Timer? gradientTimer;

  Widget buildAnimatedContainer() {
    return ValueListenableBuilder(
      valueListenable: currentGradientIndexNotifier,
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: const Duration(seconds: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors[value],
            ),
          ),
        );
      },
    );
  }

  Widget buildContainer(double width) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(
            width: width - 150,
            height: 30, 
            child: buildAnimatedContainer(),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: width - 180,
            height: 20, 
            child: buildAnimatedContainer(),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: width - 33,
            height: 395, 
            child: buildAnimatedContainer(),
          ),

          const SizedBox(height: 12),
          
          const Divider(color: ThemeColor.lightGrey),

        ],
      ),
    );

  }

  Widget buildRecentContainer() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: SizedBox(
        width: 85,
        height: 75,
        child: buildAnimatedContainer(),
      ),
    );
  }

  Widget buildPublicStorageLoading(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Column( 
      children: [
        Center(
          child: Column(
            children: [

              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0, top: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, color: ThemeColor.justWhite, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Recent",
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          color: ThemeColor.justWhite,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 75,
                width: width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return buildRecentContainer();
                  },
                ),
              ),             

              const SizedBox(height: 8),

              const Divider(color: ThemeColor.lightGrey),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Row(
                  children: [
                    const Icon(Icons.explore_outlined, color: ThemeColor.justWhite, size: 20),
                    const SizedBox(width: 8),
                    Text( 
                      "Discover",
                      style: GoogleFonts.inter(
                        fontSize: 22, 
                        color: ThemeColor.justWhite,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(
                height: height-270,
                width: width - 33,
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return buildContainer(width);
                  } 
                ),
              ),
            ],
          ),
        ),
      ],
    );
    
  }

  void initializeGradient() {
    gradientTimer = Timer.periodic(durationGradient, (timer) {
      if (mounted) {
          currentGradientIndexNotifier.value =  
          (currentGradientIndexNotifier.value + 1) % gradientColors.length;
      } else {
        timer.cancel(); 
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initializeGradient();
  }
  
  @override
  void dispose() {
    gradientTimer?.cancel();
    currentGradientIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context,
        title: "Public Storage"
      ).buildAppBar(),
      body: buildPublicStorageLoading(context),
    );
  }
  
}

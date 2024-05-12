import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/splash_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationButtons extends StatelessWidget {

  final bool isVisible;

  final ValueNotifier<bool> isGridListViewSelected;
  final ValueNotifier<String> sortingText;
  final ValueNotifier<IconData> ascendingDescendingCaret;

  final VoidCallback sortingOnPressed;
  final VoidCallback filterPhotosTypeVisibleOnPressed;

  NavigationButtons({
    required this.isVisible,
    required this.isGridListViewSelected,
    required this.ascendingDescendingCaret, 
    required this.sortingText,
    required this.sortingOnPressed,
    required this.filterPhotosTypeVisibleOnPressed,
    Key? key,
  }) : super(key: key);

  final tempData = GetIt.instance<TempDataProvider>();

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !isVisible,
      child: Column(
        children: [

          tempData.origin == OriginFile.public 
          ? const SizedBox(height: 0)
          : const SizedBox(height: 12),
    
          Row(
            children: [

              Transform.translate(
                offset: const Offset(8, 0),
                child: ElevatedButton(
                  onPressed: sortingOnPressed,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: ThemeColor.darkBlack,
                    shape: const StadiumBorder(),
                  ),
                  child: ValueListenableBuilder<String>(
                    valueListenable: sortingText,
                    builder: (context, value, child) {
                      return Row(
                        children: [

                          Text(
                            value,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: ThemeColor.secondaryWhite
                            ),
                          ),

                          const SizedBox(width: 2),

                          ValueListenableBuilder(
                            valueListenable: ascendingDescendingCaret, 
                            builder: (context, value, child) {
                              return Icon(value, 
                                size: 20, 
                                color: ThemeColor.secondaryWhite
                              );
                            }
                          ),

                        ],
                      );
                    }
                  ),
                ),
              ),

              const Spacer(),

              if(WidgetVisibility.setNotVisible(OriginFile.public))
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: ClipOval(
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: SplashWidget(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          isGridListViewSelected.value = !isGridListViewSelected.value;
                          filterPhotosTypeVisibleOnPressed();
                        },
                        icon: ValueListenableBuilder<bool>(
                          valueListenable: isGridListViewSelected,
                          builder: (context, isSelected, child) {
                            return !isSelected 
                              ? const Icon(CupertinoIcons.square_grid_2x2, size: 20.5, color: ThemeColor.secondaryWhite) 
                              : const Icon(CupertinoIcons.list_bullet, size: 21.5, color: ThemeColor.secondaryWhite);
                          }
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        
            ]
          ),      
        ],
      ),
    );
  }
  
}
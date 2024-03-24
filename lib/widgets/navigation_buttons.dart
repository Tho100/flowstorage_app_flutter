import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NavigationButtons extends StatelessWidget {

  final bool isVisible;

  final ValueNotifier<bool> isGridListViewSelected;
  final ValueNotifier<String> sortingText;
  final ValueNotifier<IconData> ascendingDescendingCaret;

  final VoidCallback sortingOnPressed;
  final VoidCallback filterTypePsOnPressed;
  final VoidCallback filterPhotosTypeVisibleOnPressed;

  NavigationButtons({
    required this.isVisible,
    required this.isGridListViewSelected,
    required this.ascendingDescendingCaret, 
    required this.sortingText,
    required this.sortingOnPressed,
    required this.filterTypePsOnPressed,
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
              ElevatedButton(
                onPressed: sortingOnPressed,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: ThemeColor.darkBlack,
                ),
                child: ValueListenableBuilder<String>(
                  valueListenable: sortingText,
                  builder: (context, value, child) {
                    return Row(
                      children: [
                        Text(
                          '  $value',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
    
              const Spacer(),
    
              if(WidgetVisibility.setNotVisible(OriginFile.public))
              ElevatedButton(
                onPressed: () {
                  isGridListViewSelected.value = !isGridListViewSelected.value;
                  filterPhotosTypeVisibleOnPressed();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: ThemeColor.darkBlack,
                ),
                child: ValueListenableBuilder<bool>(
                  valueListenable: isGridListViewSelected,
                  builder: (context, isSelected, child) {
                    return !isSelected ? const Icon(Icons.grid_view, size: 21) : const Icon(Icons.format_list_bulleted_outlined, size: 22);
                  }
                ),
              ),
            ]
          ),
              
        ],
      ),
    );
  }
}
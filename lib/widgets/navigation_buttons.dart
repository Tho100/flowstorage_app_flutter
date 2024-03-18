import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NavigationButtons extends StatelessWidget {

  final bool isVisible;

  final ValueNotifier<bool> isGridListViewSelected;
  final ValueNotifier<bool> isCreateDirectoryVisible;
  final ValueNotifier<String> sortingText;
  final ValueNotifier<IconData> ascendingDescendingCaret;

  final VoidCallback sharedOnPressed;
  final VoidCallback scannerOnPressed;
  final VoidCallback createDirectoryOnPressed;
  final VoidCallback sortingOnPressed;
  final VoidCallback filterTypePsOnPressed;
  final VoidCallback filterPhotosTypeVisibleOnPressed;

  NavigationButtons({
    required this.isVisible,
    required this.isCreateDirectoryVisible,
    required this.isGridListViewSelected,
    required this.ascendingDescendingCaret, 
    required this.sortingText,
    required this.sharedOnPressed,
    required this.scannerOnPressed,
    required this.createDirectoryOnPressed,
    required this.sortingOnPressed,
    required this.filterTypePsOnPressed,
    required this.filterPhotosTypeVisibleOnPressed,
    Key? key,
  }) : super(key: key);

  final tempData = GetIt.instance<TempDataProvider>();

  final buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: ThemeColor.darkGrey,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    )
  );

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !isVisible,
      child: Column(
        children: [

          tempData.origin == OriginFile.public 
          ? const SizedBox(height: 0)
          : const SizedBox(height: 10),
    
          if(WidgetVisibility.setNotVisible(OriginFile.public)) ... [
            Row(
            
              children: [
                
                const SizedBox(width: 16),
          
                ElevatedButton(
                  onPressed: sharedOnPressed,
                  style: buttonStyle,
                  child: const Row(
                    children: [
                      Icon(Icons.share, color: Colors.white),
                      Text(
                        '  Shared',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
          
                const SizedBox(width: 8),
          
                ElevatedButton(
                  onPressed: scannerOnPressed,
                  style: buttonStyle,
                  child: const Row(
                    children: [
                      Icon(Icons.center_focus_strong_rounded, color: Colors.white),
                      Text(
                        '  Scan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
          
                const SizedBox(width: 8),
          
                ValueListenableBuilder<bool>(
                  valueListenable: isCreateDirectoryVisible,
                  builder: (context, value, child) {
                    return Visibility(
                      visible: value,
                      child: ElevatedButton(
                        onPressed: createDirectoryOnPressed,
                        style: buttonStyle,
                        child: const Row(
                          children: [
                            Icon(Icons.add_box, color: Colors.white),
                            Text(
                              '  Directory',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          
              ],
            ),
          ],
    
          tempData.origin == OriginFile.public
          ? const SizedBox(height: 0)
          : const SizedBox(height: 8),
    
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
                            color: ThemeColor.justWhite
                          ),
                        ),
                        const SizedBox(width: 2),
                        ValueListenableBuilder(
                          valueListenable: ascendingDescendingCaret, 
                          builder: (context, value, child) {
                            return Icon(value, 
                              size: 20, 
                              color: Colors.white
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
    
          const Divider(color: ThemeColor.lightGrey, height: 0),
          
        ],
      ),
    );
  }
}
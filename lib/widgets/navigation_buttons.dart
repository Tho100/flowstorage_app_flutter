import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NavigationButtons extends StatelessWidget {

  final bool isVisible;

  final ValueNotifier<bool> isStaggeredListViewSelected;
  final ValueNotifier<bool> isCreateDirectoryVisible;
  final ValueNotifier<String> sortingText;
  final ValueNotifier<IconData> ascendingDescendingCaret;

  final VoidCallback sharedOnPressed;
  final VoidCallback scannerOnPressed;
  final VoidCallback createDirectoryOnPressed;
  final VoidCallback sortingOnPressed;
  final VoidCallback filterTypePsOnPressed;

  NavigationButtons({
    required this.isVisible,
    required this.isCreateDirectoryVisible,
    required this.isStaggeredListViewSelected,
    required this.ascendingDescendingCaret, 
    required this.sortingText,
    required this.sharedOnPressed,
    required this.scannerOnPressed,
    required this.createDirectoryOnPressed,
    required this.sortingOnPressed,
    required this.filterTypePsOnPressed,
    Key? key,
  }) : super(key: key);

  final tempData = GetIt.instance<TempDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !isVisible,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          tempData.origin == OriginFile.public 
          ? const SizedBox(height: 0)
          : const SizedBox(height: 10),
    
          if(tempData.origin != OriginFile.public) ... [
            Row(
            
              children: [
                
                const SizedBox(width: 16),
          
                ElevatedButton(
                  onPressed: sharedOnPressed,
                  style: GlobalsStyle.btnNavigationBarStyle,
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
                  style: GlobalsStyle.btnNavigationBarStyle,
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
                        style: GlobalsStyle.btnNavigationBarStyle,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: ascendingDescendingCaret, 
                          builder: (context, value, child) {
                            return Icon(value, color: Colors.white);
                          }
                        ),
                      ],
                    );
                  }
                ),
              ),
    
              const Spacer(),
    
              if(tempData.origin == OriginFile.public)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  onPressed: filterTypePsOnPressed,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.only(left: 6, right: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)
                    ),
                  ).copyWith(
                    fixedSize: MaterialStateProperty.all<Size>(const Size(36, 36)),
                  ),
                  child: const Icon(Icons.filter_list_outlined, size: 27),
                ),
              ),
    
              if(tempData.origin != OriginFile.public)
              ElevatedButton(
                onPressed: () {
                  isStaggeredListViewSelected.value = !isStaggeredListViewSelected.value;
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: ThemeColor.darkBlack,
                ),
                child: Row(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: isStaggeredListViewSelected,
                      builder: (context, value, child) {
                        return value == false ? const Icon(Icons.grid_view,size: 23) : const Icon(Icons.format_list_bulleted_outlined,size: 25);
                      }
                    ),
                  ],
                ),
              ),
            ]
          ),
    
          const Divider(color: ThemeColor.thirdWhite, height: 0),
          
        ],
      ),
    );
  }
}
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ResponsiveSearchBar extends StatelessWidget {

  final double? customWidth;
  final double? customHeight;

  final TextEditingController controller;
  final ValueNotifier? visibility;
  final FocusNode? focusNode;
  final String hintText;
  final bool? autoFocus;
  final VoidCallback? cancelSearchOnPressed;
  final Function(String) onChanged;

  ResponsiveSearchBar({
    this.visibility,
    this.customWidth,
    this.customHeight,
    this.focusNode,
    this.autoFocus,
    this.cancelSearchOnPressed,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    Key? key
  }) : super(key: key);

  final tempData = GetIt.instance<TempDataProvider>();

  final borderRadius = 15.0;
  
  final double? defaultWidth = 0.94;
  final double? defaultHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: visibility ?? ValueNotifier(true),
      builder: (context, value, child) {
        return Visibility(
          visible: value,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => focusNode?.unfocus(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              height: customHeight ?? defaultHeight,
              child: FractionallySizedBox(
                widthFactor: customWidth ?? defaultWidth, 
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: autoFocus ?? false,
                        onChanged: onChanged,
                        controller: controller,
                        focusNode: focusNode ?? FocusNode(),
                        style: const TextStyle(
                          color: Color.fromARGB(230, 255, 255, 255),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                            borderSide: const BorderSide(
                              color: ThemeColor.darkGrey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: ThemeColor.darkGrey),
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          hintText: hintText,
                          hintStyle: const TextStyle(
                            color: ThemeColor.secondaryWhite,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 200, 200,200), size: 18),
                        ),
                      ),
                    ),
                    if(WidgetVisibility.setVisibleList([OriginFile.public, OriginFile.publicSearching]))
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: ElevatedButton(
                        onPressed: cancelSearchOnPressed,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.only(left: 6, right: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                          ),
                        ).copyWith(
                          fixedSize: MaterialStateProperty.all<Size>(const Size(36, 36)),
                        ),
                        child: [OriginFile.public, OriginFile.publicSearching].contains(tempData.origin)
                          ? const Icon(Icons.cancel, color: ThemeColor.darkWhite, size: 25)
                          : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

}
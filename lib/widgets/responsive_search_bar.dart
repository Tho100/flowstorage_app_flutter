import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ResponsiveSearchBar extends StatelessWidget {

  final TextEditingController controller;
  final ValueNotifier visibility;
  final FocusNode focusNode;
  final String hintText;
  final VoidCallback filterTypeOnPressed;
  final Function(String) onChanged;

  ResponsiveSearchBar({
    required this.controller,
    required this.visibility,
    required this.focusNode,
    required this.hintText,
    required this.filterTypeOnPressed,
    required this.onChanged,
    Key? key
  }) : super(key: key);

  final tempData = GetIt.instance<TempDataProvider>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: visibility,
      builder: (context, value, child) {
        return Visibility(
          visible: value,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              focusNode.unfocus();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: ThemeColor.mediumGrey,
              ),
              height: 50,
              child: FractionallySizedBox(
                widthFactor: 0.94, 
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: onChanged,
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(
                          color: Color.fromARGB(230, 255, 255, 255)
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: ThemeColor.mediumGrey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: ThemeColor.mediumGrey),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          hintText: hintText,
                          hintStyle: const TextStyle(color: Color.fromARGB(255, 200,200,200), fontSize: 16),
                          prefixIcon: const Icon(Icons.search,color: Color.fromARGB(255, 200, 200,200),size: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: ElevatedButton(
                        onPressed: filterTypeOnPressed,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.only(left: 6, right: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)
                          ),
                        ).copyWith(
                          fixedSize: MaterialStateProperty.all<Size>(const Size(36, 36)),
                        ),
                        child: const Icon(Icons.filter_list_outlined, size: 25),
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
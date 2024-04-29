import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomNavigationBar extends StatefulWidget {

  final VoidCallback openFolderDialog;
  final VoidCallback toggleHome;
  final VoidCallback togglePhotos;
  final VoidCallback togglePublicStorage;

  const CustomNavigationBar({
    super.key, 
    required this.openFolderDialog,
    required this.toggleHome,
    required this.togglePhotos,
    required this.togglePublicStorage,
  });

  @override
  CustomNavigationBarState createState() => CustomNavigationBarState();
}

class CustomNavigationBarState extends State<CustomNavigationBar> {

  final tempData = GetIt.instance<TempDataProvider>();
  
  final bottomNavigationBarIndex = ValueNotifier<int>(0); 
  final isPhotosPressedNotifier = ValueNotifier<bool>(false);

  final bottomPadding = 4.5;

  @override
  void dispose() {
    bottomNavigationBarIndex.dispose();
    super.dispose();
  }

  Widget _buildHome(bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: isSelected 
        ? const Icon(Icons.home) : const Icon(Icons.home_outlined)
    );
  }

  Widget _buildFolders(bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: isSelected 
        ? const Icon(Icons.folder) : const Icon(Icons.folder_outlined)
    );
  }

  Widget _buildPhotos() {
    return ValueListenableBuilder(
      valueListenable: isPhotosPressedNotifier,
      builder: (context, isPressed, child) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: !isPressed
            ? const Icon(Icons.photo_outlined) 
            : const Icon(Icons.photo),
        );
      }
    );
  }

  Widget _buildPublic(bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        width: 26,
        height: 26,
        child: isSelected 
          ? Image.asset('assets/images/public_icon_selected.jpg') 
          : Image.asset('assets/images/public_icon.jpg'),
      ),
    );
  }

  Widget _buildNavigationBar() {
    
    final labelTextStyle = GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: 11.5,
      color: ThemeColor.justWhite,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 0.6,
          color: ThemeColor.lightGrey,
        ),
        Container(
          height: 68,
          color: ThemeColor.lightGrey,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: ThemeColor.darkBlack,
            unselectedItemColor: Colors.grey,
            fixedColor: Colors.grey,
            currentIndex: bottomNavigationBarIndex.value,
            selectedLabelStyle: labelTextStyle,
            unselectedLabelStyle: labelTextStyle,
            iconSize: 25.2,
            items: [
              BottomNavigationBarItem(
                icon: tempData.origin == OriginFile.home 
                ? _buildHome(true)
                : _buildHome(false),
                activeIcon: tempData.origin == OriginFile.home 
                ? _buildHome(true)
                : _buildHome(false),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: _buildPhotos(),
                label: "Photos",
              ),
              BottomNavigationBarItem(
                icon: _buildPublic(false),
                activeIcon: tempData.origin == OriginFile.public
                ? _buildPublic(true)
                : _buildPublic(false),
                label: "Public",
              ),
              BottomNavigationBarItem(
                icon: tempData.origin == OriginFile.folder
                ? _buildFolders(true)
                : _buildFolders(false),
                label: "Folders",
              ),
            ],
            onTap: (indexValue) async {

              if (indexValue == 3) {
                bottomNavigationBarIndex.value = bottomNavigationBarIndex.value;
              } else {
                bottomNavigationBarIndex.value = indexValue;
              }

              switch (indexValue) {
                case 0:
                  isPhotosPressedNotifier.value = false;
                  widget.toggleHome();
                  break;
                case 1:
                  isPhotosPressedNotifier.value = !isPhotosPressedNotifier.value;
                  widget.togglePhotos();
                  break;
                case 2:
                  isPhotosPressedNotifier.value = false;
                  widget.togglePublicStorage();
                  break;
                case 3:
                  widget.openFolderDialog();
                  break;
              }
            },
          ),
        ),
        const SizedBox(height: 3.5),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return _buildNavigationBar();
  }

}

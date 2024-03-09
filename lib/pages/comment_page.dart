import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flutter/material.dart';

import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentPage extends StatefulWidget {

  final String fileName;

  const CommentPage({required this.fileName, Key? key}) : super(key: key);

  @override
  State<CommentPage> createState() => CommentPageState();
}

class CommentPageState extends State<CommentPage> {

  final noCommentController = TextEditingController(text: '(No Comment)');

  final tempData = GetIt.instance<TempDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();

  late ValueNotifier<String> commentNotifier = ValueNotifier('');

  Future<String> _sharedFileComment() async {

    final conn = await SqlConnection.initializeConnection();
    
    final index = storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);

    const query = "SELECT CUST_COMMENT FROM cust_sharing WHERE CUST_FROM = :from AND CUST_FILE_PATH = :filename AND CUST_TO = :shared_to";
    final params = {
      'from': userData.username, 
      'filename': EncryptionClass().encrypt(tempData.selectedFileName),
      'shared_to': tempStorageData.sharedNameList[index]
    };

    final results = await conn.execute(query,params);

    final retrievedComment = results.rows.last.assoc()['CUST_COMMENT'];
    final decryptedComment = EncryptionClass().decrypt(retrievedComment);

    return decryptedComment.isNotEmpty ? decryptedComment : '(No Comment)';

  }

  Future<String> _sharedToMeComment() async {

    final conn = await SqlConnection.initializeConnection();
    
    final index = storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);

    const query = "SELECT CUST_COMMENT FROM cust_sharing WHERE CUST_TO = :share_to AND CUST_FILE_PATH = :filename AND CUST_FROM = :from";
    final params = {
      'share_to': userData.username, 
      'filename': EncryptionClass().encrypt(tempData.selectedFileName),
      'from': tempStorageData.sharedNameList[index]
    };

    final results = await conn.execute(query,params);

    final retrievedComment = results.rows.last.assoc()['CUST_COMMENT'];
    final decryptedComment = EncryptionClass().decrypt(retrievedComment);

    return decryptedComment.isNotEmpty ? decryptedComment : '(No Comment)';
    
  }

  Future<String> _psFileComment() async {

    final conn = await SqlConnection.initializeConnection();
    
    const query = "SELECT CUST_COMMENT FROM ps_info_comment WHERE CUST_FILE_NAME = :filename";
    final params = {
      'filename': EncryptionClass().encrypt(tempData.selectedFileName)
    };

    final results = await conn.execute(query,params);

    final retrievedComment = results.rows.last.assoc()['CUST_COMMENT'];
    final decryptedComment = EncryptionClass().decrypt(retrievedComment);

    return decryptedComment.isNotEmpty ? decryptedComment : '(No Comment)';

  }

  void _initializeFileComment() async {
    
    switch (tempData.origin) {
      case OriginFile.home:
        commentNotifier.value = "(No Comment)";
        break;

      case OriginFile.sharedOther:
        commentNotifier.value = await _sharedFileComment();
        break;

      case OriginFile.sharedMe:
        commentNotifier.value = await _sharedToMeComment();
        break;

      case OriginFile.public:
      case OriginFile.publicSearching:
        commentNotifier.value = await _psFileComment();
        break;

      default:
        break;
    }
    
  }

  Widget _buildHeader() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Comment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            )
          ),
        ),
      ],
    );
  }

  Widget _buildComment({required String commentValue}) {

    final commentController = TextEditingController(text: commentValue);
    final mediaQuery = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: mediaQuery.height * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: ThemeColor.darkBlack,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: commentController,
                      readOnly: true,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: GoogleFonts.roboto(
                        color: const Color.fromARGB(255, 224, 223, 223),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoComment() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7, 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: ThemeColor.darkBlack, 
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  enabled: false,
                  controller: noCommentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: GoogleFonts.roboto(
                    color: const Color.fromARGB(255, 224, 223, 223),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    noCommentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeFileComment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tempData.selectedFileName,
        style: GlobalsStyle.appBarTextStyle
      )
    ),
    body: ValueListenableBuilder<String>(
      valueListenable: commentNotifier,
        builder: (context, value, _) {
          if (value.isNotEmpty) {
            return _buildComment(commentValue: value);
          } else {
            return _buildNoComment();
          }
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/model/document_model.dart';
import 'package:google_docs/model/error_model.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/repository/document_repository.dart';
import 'package:google_docs/repository/socket_repository.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {

  TextEditingController titleController = TextEditingController(text: "Untitled Document");
  QuillEditorController controller = QuillEditorController();
  SocketRepository socketRepo = SocketRepository();
  String? text;

  @override
  void initState() {
    super.initState();
    socketRepo.joinRoom(widget.id);
    fetchDocumentData();
  }
  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    controller.dispose();
  }
  void updateTitle(WidgetRef ref, String title){
    ref.read(documentRepositoryProvider).updateTitle(token: ref.read(userProvider)!.token, id: widget.id, title: title);
  }
  void fetchDocumentData()async{
    ErrorModel errorModel = await ref.read(documentRepositoryProvider).getDocumentById(ref.read(userProvider)!.token, widget.id);
    if(errorModel.data != null){
      titleController.text = (errorModel.data as DocumentModel).title;
      text = (errorModel.data as DocumentModel).content[0];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(preferredSize: Size.fromHeight(1),child: Container(decoration: BoxDecoration(border: Border.all(color: kGrayColor, width: 0.1)),),),
        backgroundColor: kWhiteColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Image.asset("assets/images/docs-logo.png", height: 40,),
              const SizedBox(width: 10,),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kBlueColor,
                      )
                    )
                  ),
                  onSubmitted: (value){
                    updateTitle(ref, value);
                  },
                ),
              )
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
                onPressed: (){
                  socketRepo.autoSave(text!, widget.id);
                },
                icon: const Icon(Icons.save, color: kWhiteColor,),
              label: Text("Save", style: TextStyle(color: kWhiteColor),),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlueColor,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             SizedBox(height: 10,),
              ToolBar(
                alignment: WrapAlignment.center,
                activeIconColor: kBlueColor,
                padding: const EdgeInsets.all(8),
                iconSize: 20,
                controller: controller,
              ),
              Expanded(
                child: SizedBox(
                  width: 750,
                  child: Card(
                    color: kWhiteColor,
                    elevation: 10,
                    child: QuillHtmlEditor(
                        onTextChanged: (value){
                        text = value;
                        },
                      text: text,
                      hintText: 'Hint: text goes here',
                      controller: controller,
                      isEnabled: true,
                      ensureVisible: false,
                      minHeight: 500,
                      autoFocus: false,
                      hintTextAlign: TextAlign.start,
                      padding: const EdgeInsets.all(10),
                      hintTextPadding: const EdgeInsets.only(left: 20),
                      inputAction: InputAction.newline,
                      loadingBuilder: (context) {
                        return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: Colors.red,
                            ));
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

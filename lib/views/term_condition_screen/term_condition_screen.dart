import 'package:flutter/material.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/service/remote/response/term_condition_response.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermConditionScreen extends StatefulWidget {
  const TermConditionScreen({super.key});

  @override
  State<TermConditionScreen> createState() => _TermConditionScreenState();
}

class _TermConditionScreenState extends State<TermConditionScreen> {
  late WebViewController _controller;
  
@override
  void initState() {
    
    _controller = WebViewController();
    _controller.enableZoom(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
        
    return  Scaffold(
      appBar: AppBar(
        title: Text("Term & Condition"),
        centerTitle: true,
                backgroundColor: Colors.transparent,
              ),
      body: FutureBuilder(future: getTermCondition(), builder: (context, snapshot){
        
        if(snapshot.hasData){
          _controller.loadHtmlString(snapshot.data!);
          return WebViewWidget(controller: _controller);
        }
        return Center(child: CircularProgressIndicator(),);
      }),
    );
  }

  Future<String> getTermCondition() async{
    ApiService apiService = ApiService();
    TermConditionResponse response =  await apiService.termCondition();

    if(response.error){
      return "Terjadi Kesalahan";
    }else{
      return response.data!;
    }
  }
}
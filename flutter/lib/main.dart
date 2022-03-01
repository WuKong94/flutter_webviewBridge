import 'package:flutter/material.dart';
import 'dart:js' as js;
import 'dart:html';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: TestJsPage(),
    );
  }
}

class TestJsPage extends StatelessWidget {
  List data = [
    {'title': '调用alert方法', 'key': 'alert'},
    {'title': '调用原生方法', 'key': 'nativeMethod'},
    {'title': '获取原生数据', 'key': 'getNativeData'},
    {'title': '原生调用dart方法', 'key': 'dartMethod'},
    {'title': '获取cookie', 'key': 'getCookie'},
  ];

  TestJsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    js.context["flutterMethod"] = flutterMethod;

    return Scaffold(
        body: Container(
            color: Colors.white,
            child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => clickItemIndex(index, data[index]['key']),
                    title: Text(data[index]['title']),
                  );
                })));
  }

  void flutterMethod() {
    js.context.callMethod("alert", ["dart方法被调用了"]);
  }

  void clickItemIndex(int index, String key) {

    if (key == 'alert') {
      _callAlert("alert弹出");
    } else if (key == 'nativeMethod') {
      js.context.callMethod('webviewBridge', [key, '调用原生方法成功了阿']);
    } else if (key == 'getNativeData') {
      js.context.callMethod('webviewCallBackBridge', [
        key,
        js.allowInterop((result) {
          if (result.isNotEmpty) {
            _callAlert(result);
          }
        }),
        '该返回数据给dart了'
      ]);
    } else if (key == 'dartMethod') {
      js.context.callMethod('webviewBridge', [key, {}]);
    } else if (key == 'getCookie') {
      _callAlert(_readCookie().toString());
    }
  }

  Map _readCookie() {
    String cookies = document.cookie ?? '';
    var cookie = {};
    cookies.split(';').forEach((element) {
      var k = element.indexOf('=');
      if (k > 0) {
        cookie[Uri.decodeComponent(element.substring(0, k)).trim()] =
            Uri.decodeComponent(element.substring(k + 1)).trim();
      }
    });
    return cookie;
  }

  ///
  ///调用js并且传递参数
  ///
  void _callAlert(String content) {
    //等于js调用： alert("我是来自dart的方法");
    js.context.callMethod("alert", [content]);
  }

}




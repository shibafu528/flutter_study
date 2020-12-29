import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

void main() {
  runApp(MyApp());
}

Future<List<Faq>> fetchFaq() async {
  final response = await http.get('https://mikutter.hachune.net/faq.json');
  if (response.statusCode == 200) {
    return jsonDecode(utf8.decode(response.bodyBytes))
        .map<Faq>((json) => Faq.fromJson(json))
        .toList();
  } else {
    throw Exception('Failed to fetch faq');
  }
}

class Faq {
  Faq({this.id, this.question, this.answer});

  final String id;
  final String question;
  final String answer;

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ja', 'JP'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => FaqListPage(),
        '/faq': (BuildContext context) =>
            FaqDetailPage(faq: ModalRoute.of(context).settings.arguments),
      },
    );
  }
}

class FaqListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('mikutter'),
      ),
      body: FaqList(),
    );
  }
}

class FaqList extends StatefulWidget {
  @override
  _FaqListState createState() => _FaqListState();
}

class _FaqListState extends State<FaqList> {
  Future<List<Faq>> _futureFaqList;

  @override
  void initState() {
    super.initState();
    _futureFaqList = fetchFaq();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Faq>>(
        future: _futureFaqList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final divided = ListTile.divideTiles(
              context: context,
              tiles: snapshot.data.map((faq) => FaqListTile(faq: faq)),
            ).toList();

            return ListView(children: divided);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return Center(child: CircularProgressIndicator());
        });
  }
}

class FaqListTile extends StatelessWidget {
  FaqListTile({this.faq});

  final Faq faq;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(faq.question),
      onTap: () {
        Navigator.of(context).pushNamed('/faq', arguments: faq);
      },
    );
  }
}

class FaqDetailPage extends StatelessWidget {
  FaqDetailPage({this.faq});

  final Faq faq;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('mikutter'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            tooltip: '共有',
            onPressed: () {
              Share.share(
                  "Q: ${faq.question}\n\nA: ${faq.answer}\n\nhttps://mikutter.hachune.net/faq",
                  subject: faq.question);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(faq.question, style: TextStyle(fontSize: 22)),
              SizedBox(height: 8),
              Text(faq.answer, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

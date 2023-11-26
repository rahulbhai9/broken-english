// pm v3
import 'dart:async';
import 'dart:convert';
import 'ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
Future<Poeam> fetchPoeam({required String poeamPath}) async {
  final response = await http.get(Uri.parse(Uri.encodeFull('https://poetrydb.org/$poeamPath')));
  if (response.statusCode == 200) {
    return Poeam.fromJson(jsonDecode(response.body)[0]);
  } else {
    throw Exception('Failed to load poeam');
  }
}
Future<List<String>> fetchAuthors() async {
  final response = await http.get(Uri.parse('https://poetrydb.org/author'));
  if (response.statusCode == 200) {
Map<String, dynamic> data = jsonDecode(response.body);
return List<String>.from(data['authors']);
  } else {
    throw Exception('Failed to load authors');
  }
}
Future<List<Poeam>> fetchPoeamsByAuthor({required String authorName}) async {
  final response = await http.get(Uri.parse(Uri.encodeFull('https://poetrydb.org/author/$authorName')));

  if (response.statusCode == 200) {
List<Poeam> poeams = [];
final data = jsonDecode(response.body);
poeams = data.map<Poeam>((m)=>Poeam.fromJson(Map<String, dynamic>.from(m))).toList();

return poeams;
  } else {
    throw Exception('Failed to load poeams');
  }
}
Future<List<Poeam>> searchPoeams({required String searchQuery}) async {
  final response = await http.get(Uri.parse(Uri.encodeFull('https://poetrydb.org/title/$searchQuery')));

  if (response.statusCode == 200) {
List<Poeam> poeams = [];
final data = jsonDecode(response.body);
poeams = data.map<Poeam>((m)=>Poeam.fromJson(Map<String, dynamic>.from(m))).toList();

return poeams;
  } else {
    throw Exception('Poeams not found with $searchQuery');
  }
}
class Poeam {
  final String title;

  final String author;
  final List lines;
  Poeam({
    required this.title,

    required this.author,

    required this.lines,
  });

  factory Poeam.fromJson(Map<String, dynamic> json) {
    return Poeam(
      title: json['title'],
      author: json['author'],
      lines: json['lines'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
debugShowCheckedModeBanner:false,
      title: 'Pohub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Poems'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({Key? key, required this.title}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: widget.title,
      ),
      body: FutureBuilder<void>(
        future: _initGoogleMobileAds(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
ElevatedButton(
          child: Text('Browse all authors'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllAuthorsPage()),
            );
          },
        ),
ElevatedButton(
          child: Text('Random poeam'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PoeamPage(poeamPath:"random")),
            );
          },
        ),
              ],
            ),
          );
              } else if (snapshot.hasError) {
                return LiveText('Error: ${snapshot.error}');

} else{
return LiveText("Please wait.");
}

} else{
return LiveText("Welcome!");
}
        },
      ),
    );
  }

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }
}
class LiveText extends StatelessWidget{
  final String text;
  LiveText(this.text);
  @override
  Widget build(BuildContext context) {
return Semantics(child:Text(text), liveRegion: true,);
  }
}
class MyAppBar extends StatelessWidget with PreferredSizeWidget{
  final String title;
  MyAppBar({Key? key, required this.title}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text(title),
actions: <Widget>[
ElevatedButton.icon(
  onPressed: () {
        showSearch(
          context: context,
          delegate: CustomSearchDelegate(),
        );
},
  icon: Icon(Icons.search,),
label: Text('Search'),
),
],
      );
  }
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
ElevatedButton.icon(
  onPressed: () {
query = '';
},
  icon: Icon(Icons.clear,),
label: Text('Clear query'),
),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return ElevatedButton.icon(
  onPressed: () {
        close(context, null);
},
  icon: Icon(Icons.arrow_back,),
label: Text('Navigate up'),
);
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: LiveText(
              "Search term must be longer than two letters.",
            ),
          )
        ],
      );
    }
return SearchedPoeams(searchQuery:query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes. 
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }
}
class PoeamPage extends StatefulWidget {
final String poeamPath;
   PoeamPage({required this.poeamPath,}) : super();

  @override
  _PoeamPageState createState() => _PoeamPageState();
}

class _PoeamPageState extends State<PoeamPage> {
  late BannerAd _bannerAd;

  bool _isError = false;
String error = "";
  bool _isBannerAdReady = false;
late final Future<Poeam> futurePoeam;
  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
//          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
          setState(() {
_isError = true;
error = 'Failed: ${err.message}';
});
        },
      ),
    );

    _bannerAd.load();
    futurePoeam = fetchPoeam(poeamPath: widget.poeamPath);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: MyAppBar(
          title: 'Poeam',
        ),
        body: Container(
        height: height,
          child: FutureBuilder<Poeam>(
            future: futurePoeam,
            builder: (context, snapshot) {
          List<Widget> children;

    if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
          List<Widget> poeamLines = [];
for(int l=0;l<snapshot.data!.lines.length;l++){
poeamLines.add(Text(snapshot.data!.lines[l]));
}
            children = <Widget>[

LiveText("Title: ${snapshot.data!.title}"),
Text("Author: ${snapshot.data!.author}"),
if(_isError)
LiveText(error),
            if (_isBannerAdReady)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
...poeamLines,
ElevatedButton(
          child: Text('More by ${snapshot.data!.author}'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PoeamsByAuthorPage(authorName:snapshot.data!.author)),
            );
          },
        ),
            ];
              } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LiveText('Error: ${snapshot.error}'),
              )
            ];
              } else {
            children = <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: LiveText('Awaiting poeam...'),
              ),
            ];
          }

} else{
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LiveText('waiting'),
              )
            ];
              }

          return ListView(
              children: children,
);
            },
          ),
        ),
    );
  }
}
class AllAuthorsPage extends StatefulWidget {
   AllAuthorsPage() : super();

  @override
  _AllAuthorsPageState createState() => _AllAuthorsPageState();
}

class _AllAuthorsPageState extends State<AllAuthorsPage> {
late final Future<List<String>> futureAllAuthors;
  @override
  void initState() {
    super.initState();
    futureAllAuthors = fetchAuthors();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: MyAppBar(
          title: 'Authors',
        ),
        body: Container(
        height: height,
          child: FutureBuilder<List<String>>(
            future: futureAllAuthors,
            builder: (context, snapshot) {
          List<Widget> children;

    if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
//add listbulder
return ListView.builder(
  itemCount: snapshot.data!.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(snapshot.data![index]),
onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PoeamsByAuthorPage(authorName: snapshot.data![index])),
            );
},
    );
  },
);
              } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LiveText('Error: ${snapshot.error}'),
              )
            ];
              } else {
            children = <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: LiveText('Awaiting authors...'),
              ),
            ];
          }

} else{
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LiveText('loading...'),
              )
            ];
              }

          return ListView(
              children: children,
);
            },
          ),
        ),
    );
  }
}
class PoeamsByAuthorPage extends StatefulWidget {

final String authorName;
   PoeamsByAuthorPage({required this.authorName}) : super();

  @override
  _PoeamsByAuthorPageState createState() => _PoeamsByAuthorPageState();
}

class _PoeamsByAuthorPageState extends State<PoeamsByAuthorPage> {
late final Future<List<Poeam>> futureAllPoeams;
  @override
  void initState() {
    super.initState();
    futureAllPoeams = fetchPoeamsByAuthor(authorName: widget.authorName); 
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: MyAppBar(
          title: 'Poeams',
        ),
        body: Container(
        height: height,
          child: FutureBuilder<List<Poeam>>(
            future: futureAllPoeams,
            builder: (context, snapshot) {
          List<Widget> children;

    if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
//add listbulder
return ListView.builder(
  itemCount: snapshot.data!.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(snapshot.data![index].title),
onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PoeamPage(poeamPath: "title/${snapshot.data![index].title}")),
            );
},
    );
  },
            );
              } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LiveText('Error: ${snapshot.error}'),
              )
            ];
              } else {
            children = <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: LiveText('Awaiting poeams...'),
              ),
            ];
          }

} else{
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LiveText('loading...'),
              )
            ];
              }

          return ListView(
              children: children,
);
            },
          ),
        ),
    );
  }
}
class SearchedPoeams extends StatefulWidget {

final String searchQuery;
   SearchedPoeams({required this.searchQuery}) : super();

  @override
  _SearchedPoeamsState createState() => _SearchedPoeamsState();
}

class _SearchedPoeamsState extends State<SearchedPoeams> {
late final Future<List<Poeam>> futureAllPoeams;
  @override
  void initState() {
    super.initState();
    futureAllPoeams = searchPoeams(searchQuery: widget.searchQuery); 
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
return Container(
        height: height,
          child: FutureBuilder<List<Poeam>>(
            future: futureAllPoeams,
            builder: (context, snapshot) {
          List<Widget> children;

    if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
//add listbulder
return ListView.builder(
  itemCount: snapshot.data!.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(snapshot.data![index].title),
onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PoeamPage(poeamPath: "title/${snapshot.data![index].title}")),
            );
},
    );
  },
            );
              } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LiveText('not found.'),
              )
            ];
              } else {
            children = <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: LiveText('Awaiting poeams...'),
              ),
            ];
          }

} else{
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LiveText('loading...'),
              )
            ];
              }

          return ListView(
              children: children,
);
            },
          ),
    );
  }
}

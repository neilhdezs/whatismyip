import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';


//'imagen: Flaticon.com'. Esta portada ha sido diseñada usando imágenes de Flaticon.com
void main() {
  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => IpProvider(),
          lazy: false,
        )
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      title: 'My IP',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 105, 105, 105),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 51, 51, 51),
          centerTitle: true
        )
      ),
      home: MyHomePage(title: 'What\'s my IP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  String title;

  MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final ipProvider = Provider.of<IpProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
          future: ipProvider.getMyIp(),
          builder: (BuildContext context, AsyncSnapshot<Ip> snapshot) {
            if (snapshot.data == null && !snapshot.hasData)
              return const _EmptyContainer();

            final ip = snapshot.data!;

            return columnBuilder(ip);
          },
        ),
      ),
    );
  }
}

class Ip {
  Ip({
    required this.ip,
    required this.country,
    required this.cc,
  });

  String ip;
  String country;
  String cc;

  factory Ip.fromJson(String str) => Ip.fromMap(json.decode(str));

  factory Ip.fromMap(Map<String, dynamic> json) => Ip(
        ip: json["ip"],
        country: json["country"],
        cc: json["cc"],
      );
}

class IpProvider extends ChangeNotifier {
  final Ip myIp = Ip(ip: '192.168.0.0', country: 'spain', cc: 'ES');

  Provider() {
    this.getMyIp();
  }

  Future<String> _getJsonData() async {
    const url = "https://api.myip.com/";
    final response = await http.get(Uri.parse(url));
    return response.body;
  }

  Future<Ip> getMyIp() async {
    final jsonData = await _getJsonData();

    var myIp = Ip.fromJson(jsonData);

    myIp == null
        ? Ip(ip: "ERROR NETWORK", country: "ERROR NETWORK", cc: "ERROR NETWORK")
        : Ip.fromJson(jsonData);

    return myIp;
  }
}

Widget columnBuilder(Ip myIp) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      const Text('YOUR IP IS', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold, fontSize: 25),),
      const SizedBox(height: 30,width: 50,),
      const Icon(Icons.expand_more, size: 50),
      Text(myIp.ip, style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold, fontSize: 40)),
    ],
  );
}

class _EmptyContainer extends StatelessWidget {
  const _EmptyContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      child: const Center(
          child: CircularProgressIndicator(color: Color.fromARGB(255, 184, 184, 184))
      )
    );
  }
}

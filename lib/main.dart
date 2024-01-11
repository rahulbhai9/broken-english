import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://byswcebxxbpocfouegte.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5c3djZWJ4eGJwb2Nmb3VlZ3RlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDQ5NDY3ODMsImV4cCI6MjAyMDUyMjc4M30.zdfOVtaVw4BGZxOX5DhgFjeeBvbMAfYH7zpCNfdtcVw',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Upcoming Exams',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _future = Supabase.instance.client
      .from('exams')
      .select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final exams = snapshot.data!;
          return DataTable(
            columns: [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('StartDate')),
              DataColumn(label: Text('EndDate')),
              DataColumn(label: Text('TotalPosts')),
              DataColumn(label: Text('Info')),
              DataColumn(label: Text('Link')),
            ],
            rows: exams
                .map(
                  (exam) => DataRow(cells: [
                    DataCell(Text(exam['name'] ?? '')),
                    DataCell(Text(exam['startdate'] ?? '')),
                    DataCell(Text(exam['enddate'] ?? '')),
                    DataCell(Text(exam['totalposts'] ?? '')),
                    DataCell(Text(exam['info'] ?? '')),
                    DataCell(Text(exam['link'] ?? '')),
                  ]),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cyrpto.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CryptoListScreen(),
    );
  }
}

class CryptoListScreen extends StatefulWidget {
  @override
  _CryptoListScreenState createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  late Future<List<Crypto>> _cryptoList;

  @override
  void initState() {
    super.initState();
    _cryptoList = fetchCrypto();
  }

  Future<List<Crypto>> fetchCrypto() async {
    final response = await http.get(Uri.parse('https://api.coinlore.net/api/tickers/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Crypto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load crypto data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Prices'),
      ),
      body: FutureBuilder<List<Crypto>>(
        future: _cryptoList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final crypto = snapshot.data![index];
                return ListTile(
                  title: Text(crypto.name),
                  subtitle: Text('USD ${crypto.price.toStringAsFixed(2)}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

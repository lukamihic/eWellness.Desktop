import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart' as config show apiUri;
import 'package:intl/intl.dart';

class DiscountScreen extends StatefulWidget {
  @override
  _DiscountScreenState createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  List<SpecialOffer> specialOffers = [];
  String token = '';

  @override
  void initState() {
    super.initState();
    fetchSpecialOffers();
  }

  fetchSpecialOffers() async {
    final Uri fullApiUrl = Uri.parse(config.apiUri + '/users/login');

    final Map<String, String> body = {
      'email': 'desktop',
      'password': 'test',
    };

    final responseLogin = await http.post(
      fullApiUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(body),
    );

    if (responseLogin.statusCode == 200) {
      token = responseLogin.body.toString();
    } else {
      throw Exception('Failed to fetch user.');
    }

    final response = await http.get(
      Uri.parse('${config.apiUri}/specialOffers'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token},
    );

    if (response.statusCode == 200) {
      setState(() {
        specialOffers = (json.decode(response.body) as List)
            .map((data) => SpecialOffer.fromJson(data))
            .toList();
      });
    } else {
      throw Exception('Failed to load special offers');
    }
  }

  void _addSpecialOffer() async {
    await showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String description = '';
        String expirationDate = '';

        return AlertDialog(
          title: Text('Add Special Offer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Expiration Date (yyyy-MM-dd)'),
                onChanged: (value) {
                  expirationDate = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newOffer = SpecialOffer(
                  id: 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  isDeleted: false,
                  name: name,
                  description: description,
                  isActive: true,
                  offerExpirationDate: DateTime.parse(expirationDate),
                );

                final response = await http.post(
                  Uri.parse('${config.apiUri}/specialOffers'),
                  headers: {
                    HttpHeaders.authorizationHeader: 'Bearer ' + token,
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(newOffer.toJson()),
                );

                if (response.statusCode == 200) {
                  fetchSpecialOffers();
                  Navigator.pop(context);
                } else {
                  throw Exception('Failed to add special offer');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editSpecialOffer(SpecialOffer offer) async {
    await showDialog(
      context: context,
      builder: (context) {
        String name = offer.name;
        String description = offer.description ?? '';
        String expirationDate =
            DateFormat('yyyy-MM-dd').format(offer.offerExpirationDate);

        return AlertDialog(
          title: Text('Edit Special Offer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                controller: TextEditingController(text: name),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                controller: TextEditingController(text: description),
                onChanged: (value) {
                  description = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Expiration Date (yyyy-MM-dd)'),
                controller: TextEditingController(text: expirationDate),
                onChanged: (value) {
                  expirationDate = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedOffer = SpecialOffer(
                  id: offer.id,
                  createdAt: offer.createdAt,
                  updatedAt: DateTime.now(),
                  isDeleted: offer.isDeleted,
                  name: name,
                  description: description,
                  isActive: offer.isActive,
                  offerExpirationDate: DateTime.parse(expirationDate),
                );

                final response = await http.put(
                  Uri.parse('${config.apiUri}/specialOffers/${offer.id}'),
                  headers: {
                    HttpHeaders.authorizationHeader: 'Bearer ' + token,
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(updatedOffer.toJson()),
                );

                if (response.statusCode == 200) {
                  fetchSpecialOffers();
                  Navigator.pop(context);
                } else {
                  throw Exception('Failed to update special offer');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  void _deleteSpecialOffer(int offerId) async {
    final response = await http.delete(
      Uri.parse('${config.apiUri}/specialOffers/$offerId'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token},
    );
    if (response.statusCode == 200) {
      fetchSpecialOffers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Special offer deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      throw Exception('Failed to delete special offer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: specialOffers.isEmpty
          ? Center(
              child: Text(
                'No special offers available',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 4 / 5,
              ),
              itemCount: specialOffers.length,
              itemBuilder: (context, index) {
                final offer = specialOffers[index];
                return Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10.0)),
                          child: Image.network(
                            'https://static.vecteezy.com/system/resources/thumbnails/025/491/970/small_2x/relaxing-spa-treatment-women-enjoy-pampering-massage-therapy-indoors-generated-by-ai-free-photo.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.name,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              'Expires on: ${DateFormat('yyyy-MM-dd').format(offer.offerExpirationDate)}',
                              style: TextStyle(fontSize: 14.0, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editSpecialOffer(offer),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteSpecialOffer(offer.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSpecialOffer,
        child: Icon(Icons.add, color: Colors.teal),
      ),
    );
  }
}

class SpecialOffer {
  int id;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;
  String name;
  String? description;
  bool isActive;
  DateTime offerExpirationDate;

  SpecialOffer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.name,
    this.description,
    required this.isActive,
    required this.offerExpirationDate,
  });

  factory SpecialOffer.fromJson(Map<String, dynamic> json) {
    return SpecialOffer(
      id: json['id'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isDeleted: json['isDeleted'] ?? false,
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? false,
      offerExpirationDate: DateTime.parse(json['offerExpirationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'name': name,
      'description': description,
      'isActive': isActive,
      'offerExpirationDate': offerExpirationDate.toIso8601String(),
    };
  }
}

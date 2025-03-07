import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import '../config.dart' as config show apiUri;
import 'dart:convert';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> clients = [];
  late ClientDataSource clientDataSource;
  String token = '';
  String apiUrl = String.fromEnvironment('API_URI', defaultValue: config.apiUri);

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  fetchClients() async {

    final Uri fullApiUrl = Uri.parse('$apiUrl/users/login');

    final Map<String, String> body = {
      'email': 'desktop',
      'password': 'test',
    };

    final responseLogin = await http.post(
      fullApiUrl,
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (responseLogin.statusCode == 200) {
      token = responseLogin.body.toString();
    } else {
      throw Exception('Failed to fetch user.');
    }

    final response = await http.get(Uri.parse('$apiUrl/clients'), headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      setState(() {
        clients = (json.decode(response.body) as List).map((data) => Client.fromJson(data)).toList();
        clientDataSource = ClientDataSource(clients: clients, onEdit: _editClient, onDelete: _deleteClient);
      });
    } else {
      throw Exception('Failed to load clients');
    }
  }

  void _addClient() async {
    await showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String email = '';
        String phone = '';
        String address = '';
        String emergencyName = '';
        String emergencyPhone = '';
        bool isMember = true;
        String gender = 'M';
        DateTime dateOfBirth = DateTime.now();
        TextEditingController dateController = TextEditingController(
          text: DateFormat('yyyy-MM-dd').format(dateOfBirth),
        );

        Future<void> selectDate(BuildContext context) async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: dateOfBirth,
            firstDate: DateTime(1920),
            lastDate: DateTime.now(),
          );
          if (picked != null && picked != dateOfBirth) {
            dateOfBirth = picked;
            dateController.text = DateFormat('yyyy-MM-dd').format(dateOfBirth);
          }
        }

        return AlertDialog(
          title: const Text('Add Client'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) => email = value,
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Birth Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => selectDate(context),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Phone number'),
                onChanged: (value) => phone = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Address'),
                onChanged: (value) => address = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Emergency contact name'),
                onChanged: (value) => emergencyName = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Emergency contact phone'),
                onChanged: (value) => emergencyPhone = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final client = Client(
                  id: 0,
                  name: name,
                  email: email,
                  isMember: isMember,
                  address: address,
                  dateOfBirth: dateOfBirth,
                  emergencyContactName: emergencyName,
                  emergencyContactPhone: emergencyPhone,
                  gender: gender,
                  phone: phone               
                );

                final response = await http.post(
                  Uri.parse('${config.apiUri}/clients'),
                  headers: {
                    HttpHeaders.authorizationHeader: 'Bearer $token',
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(client.toJson()),
                );

                if (response.statusCode == 200) {
                  fetchClients();
                  Navigator.pop(context);
                } else {
                  throw Exception('Failed to add client');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editClient(Client client) async {
    await showDialog(
      context: context,
      builder: (context) {
        String name = client.name ?? '';
        String email = client.email ?? '';
        String phone = client.phone ?? '';
        String address = client.address ?? '';
        String emergencyName = client.emergencyContactName ?? '';
        String emergencyPhone = client.emergencyContactPhone ?? '';
        bool isMember = client.isMember ?? false;
        String gender = client.gender ?? 'M';
        DateTime dateOfBirth = client.dateOfBirth ?? DateTime(2025);
        TextEditingController dateController = TextEditingController(
          text: DateFormat('yyyy-MM-dd').format(dateOfBirth),
        );

        Future<void> selectDate(BuildContext context) async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: dateOfBirth,
            firstDate: DateTime(1920),
            lastDate: DateTime.now(),
          );
          if (picked != null && picked != dateOfBirth) {
            dateOfBirth = picked;
            dateController.text = DateFormat('yyyy-MM-dd').format(dateOfBirth);
          }
        }

        return AlertDialog(
          title: const Text('Edit Special Offer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                controller: TextEditingController(text: name),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) => email = value,
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Birth Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => selectDate(context),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Phone number'),
                onChanged: (value) => phone = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Address'),
                onChanged: (value) => address = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Emergency contact name'),
                onChanged: (value) => emergencyName = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Emergency contact phone'),
                onChanged: (value) => emergencyPhone = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedClient = Client(
                  id: client.id,
                  name: name,
                  email: email,
                  isMember: isMember,
                  address: address,
                  dateOfBirth: dateOfBirth,
                  emergencyContactName: emergencyName,
                  emergencyContactPhone: emergencyPhone,
                  gender: gender,
                  phone: phone               
                );

                final response = await http.put(
                  Uri.parse('${config.apiUri}/clients/${client.id}'),
                  headers: {
                    HttpHeaders.authorizationHeader: 'Bearer $token',
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(updatedClient.toJson()),
                );

                if (response.statusCode == 200) {
                  fetchClients();
                  Navigator.pop(context);
                } else {
                  throw Exception('Failed to update client');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteClient(int offerId) async {
    final response = await http.delete(
      Uri.parse('${config.apiUri}/clients/$offerId'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      fetchClients();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      throw Exception('Failed to delete client');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: clients.isEmpty
          ? const Center(
              child: Text(
                'No clients yet',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            )
          : SfDataGrid(
              source: clientDataSource,
              columns: [
                GridColumn(
                    columnName: 'name',
                    label: const Text('Name', textAlign: TextAlign.center),
                    minimumWidth: (0.35 * MediaQuery.sizeOf(context).width)),
                GridColumn(
                    columnName: 'email',
                    label: const Text('e-mail', textAlign: TextAlign.center),
                    minimumWidth: (0.25 * MediaQuery.sizeOf(context).width)),
                GridColumn(
                    columnName: 'isMember',
                    label: const Text('Member', textAlign: TextAlign.center),
                    minimumWidth: (0.15 * MediaQuery.sizeOf(context).width)),
                GridColumn(
                    columnName: 'actions',
                    label: const Text('Actions', textAlign: TextAlign.left),
                    minimumWidth: (0.25 * MediaQuery.sizeOf(context).width)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClient,
        child: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 76, 175, 142),
        ),
      ),
    );
  }
}

class Client {
  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.isMember,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  final int id;
  final String name;
  final String email;
  final bool isMember;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['user']?['name'] ?? 'Unknown',
      email: json['user']?['email'] ?? 'Unknown',
      isMember: json['isMember'],
      phone: json['user']?['phone'],
      address: json['user']?['address'],
      dateOfBirth: json['user']?['dateOfBirth'] != null
          ? DateTime.parse(json['user']['dateOfBirth'])
          : null,
      gender: json['user']?['gender'],
      emergencyContactName: json['user']?['emergencyContactName'],
      emergencyContactPhone: json['user']?['emergencyContactPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isMember': isMember,
      'user': {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'passwordInput': 'test', // Default password
      }
    };
  }
}

class ClientDataSource extends DataGridSource {
  ClientDataSource({
    required List<Client> clients,
    required this.onEdit,
    required this.onDelete,
  }) {
    dataGridRows = clients
        .map<DataGridRow>((client) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'name', value: client.name),
              DataGridCell<String>(columnName: 'email', value: client.email),
              DataGridCell<bool>(columnName: 'isMember', value: client.isMember),
              DataGridCell<Widget>(columnName: 'actions', value: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => onEdit(client),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDelete(client.id),
                  ),
                ],
              )),
            ]))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];
  final Function(Client) onEdit;
  final Function(int) onDelete;

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[0].value),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[1].value),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: (row.getCells()[2].value as bool)
            ? const Icon(Icons.check, color: Colors.green)
            : const Icon(Icons.close, color: Colors.red),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: row.getCells()[3].value,
      ),
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import '../config.dart' as config show apiUri;
import 'dart:convert';

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> clients = [];
  late ClientDataSource clientDataSource;

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  fetchClients() async {
    const apiUrl =
        String.fromEnvironment('API_URI', defaultValue: config.apiUri);
    final response = await http.get(Uri.parse('${apiUrl}/clients'));
    if (response.statusCode == 200) {
      setState(() {
        clients = (json.decode(response.body) as List)
            .map((data) => Client.fromJson(data))
            .toList();
        clientDataSource = ClientDataSource(clients: clients);
      });
    } else {
      throw Exception('Failed to load clients');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: clients.isEmpty
          ? Center(
              child: Text(
                'No clients yet',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            )
          : SfDataGrid(
              source: clientDataSource,
              columns: [
                // GridColumn(
                //     columnName: 'id',
                //     label: Text('ID', textAlign: TextAlign.center),
                //     minimumWidth: (0.2 * MediaQuery.sizeOf(context).width)),
                GridColumn(
                    columnName: 'name',
                    label: Text('Name', textAlign: TextAlign.center),
                    minimumWidth: (0.45 * MediaQuery.sizeOf(context).width)),
                GridColumn(
                    columnName: 'email',
                    label: Text('e-mail', textAlign: TextAlign.center),
                    minimumWidth: (0.35 * MediaQuery.sizeOf(context).width)),
                GridColumn(
                    columnName: 'isMember',
                    label: Text('Member', textAlign: TextAlign.center),
                    minimumWidth: (0.2 * MediaQuery.sizeOf(context).width)),
              ],
            ),
    );
  }
}

class Client {
  Client(this.id, this.name, this.email, this.isMember);

  final int id;
  final String name;
  final String email;
  final bool? isMember;

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      json['id'],
      json['user']?['name'] ?? 'Unknown',
      json['user']?['email'] ?? 'Unknown',
      json['isMember'],
    );
  }
}

class ClientDataSource extends DataGridSource {
  ClientDataSource({required List<Client> clients}) {
    dataGridRows = clients
        .map<DataGridRow>((client) => DataGridRow(cells: [
              // DataGridCell<int>(columnName: 'id', value: client.id),
              DataGridCell<String>(columnName: 'name', value: client.name),
              DataGridCell<String>(columnName: 'email', value: client.email),
              DataGridCell<bool>(
                  columnName: 'isMember', value: client.isMember ?? false),
            ]))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[0].value),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[1].value),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: (row.getCells()[2].value as bool)
            ? Icon(Icons.check, color: Colors.green)
            : Icon(Icons.close, color: Colors.red),
      ),
    ]);
  }
}

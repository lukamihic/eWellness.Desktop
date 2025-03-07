import 'dart:io';

import 'package:ewellness_desktop_app/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart' as config show apiUri;

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<Payment> payments = [];
  late PaymentDataSource paymentDataSource;
  String token = '';

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  fetchPayments() async {
    const apiUrl =
        String.fromEnvironment('API_URI', defaultValue: config.apiUri);
    final Uri fullApiUrl = Uri.parse('$apiUrl/users/login');

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
    final response = await http.get(Uri.parse('$apiUrl/payments'), headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      setState(() {
        payments = (json.decode(response.body) as List)
            .map((data) => Payment.fromJson(data))
            .toList();
        paymentDataSource = PaymentDataSource(payments: payments, deletePayment: _deletePayment);
      });
    } else {
      throw Exception('Failed to load payments');
    }
  }

  void _deletePayment(int paymentId) async {
    final response = await http.delete(
      Uri.parse('${config.apiUri}/payments/$paymentId'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      fetchPayments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment deleted successfully!'),
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
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      body: payments.isEmpty
          ? const Center(
              child: Text(
                'No payments yet',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SfDataGrid(
                    source: paymentDataSource,
                    columns: [
                      GridColumn(
                          columnName: 'amount',
                          label: const Text('Amount', textAlign: TextAlign.center),
                          minimumWidth: (0.2 * MediaQuery.sizeOf(context).width)),
                      GridColumn(
                          columnName: 'paymentMethod',
                          label: const Text('Payment Method', textAlign: TextAlign.center),
                          minimumWidth: (0.25 * MediaQuery.sizeOf(context).width)),
                      GridColumn(
                          columnName: 'date',
                          label: const Text('Transaction date', textAlign: TextAlign.center),
                          minimumWidth: (0.35 * MediaQuery.sizeOf(context).width)),
                      GridColumn(
                          columnName: 'actions',
                          label: const Text('Actions', textAlign: TextAlign.center),
                          minimumWidth: (0.2 * MediaQuery.sizeOf(context).width)), // Add a column for actions
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                  width: 820,
                  padding: const EdgeInsets.all(16),
                  child: const StatsScreen(),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.bar_chart),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class Payment {
  Payment(this.id, this.amount, this.paymentMethod, this.date);

  final int id;
  final String amount;
  final String paymentMethod;
  final String date;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      json['id'],
      json['amount'].toString(),
      json['paymentMethod']?['name'] ?? 'Unknown',
      json['createdAt'],
    );
  }
}

class PaymentDataSource extends DataGridSource {
  final List<Payment> payments;
  final Function(int) deletePayment;

  PaymentDataSource({required this.payments, required this.deletePayment}) {
    dataGridRows = payments
        .map<DataGridRow>((payment) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'amount', value: 'BAM ${payment.amount}'),
              DataGridCell<String>(columnName: 'paymentMethod', value: payment.paymentMethod),
              DataGridCell<String>(columnName: 'date', value: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(payment.date))),
              DataGridCell<Widget>(columnName: 'actions', value: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  deletePayment(payment.id);
                },
              )),
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
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[0].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[1].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[2].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: row.getCells()[3].value, // Action column (delete icon)
      ),
    ]);
  }
}

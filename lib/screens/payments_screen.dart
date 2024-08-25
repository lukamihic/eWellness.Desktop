import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentsScreen extends StatefulWidget {
  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<Payment> payments = [];
  late PaymentDataSource paymentDataSource;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  fetchPayments() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/api/payments'));
    if (response.statusCode == 200) {
      setState(() {
        payments = (json.decode(response.body) as List)
            .map((data) => Payment.fromJson(data))
            .toList();
        paymentDataSource = PaymentDataSource(payments: payments);
      });
    } else {
      throw Exception('Failed to load payments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: payments.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SfDataGrid(
              source: paymentDataSource,
              columns: [
                GridColumn(
                    columnName: 'id',
                    label: Text('ID', textAlign: TextAlign.center),
                    minimumWidth: (0.2 * MediaQuery.sizeOf(context).width)),
                GridColumn(
                    columnName: 'amount',
                    label: Text('Amount', textAlign: TextAlign.center),
                    minimumWidth: (0.2 * MediaQuery.sizeOf(context).width)),
                GridColumn(
                    columnName: 'paymentMethod',
                    label: Text('Payment Method', textAlign: TextAlign.center),
                    minimumWidth: (0.4 * MediaQuery.sizeOf(context).width)),
                GridColumn(
                    columnName: 'date',
                    label: Text('date', textAlign: TextAlign.center),
                    minimumWidth: (0.2 * MediaQuery.sizeOf(context).width)),
              ],
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
    return Payment(json['id'], json['amount'].toString(),
        json['paymentMethod']?['name'] ?? 'Unknown', json['createdAt']);
  }
}

class PaymentDataSource extends DataGridSource {
  PaymentDataSource({required List<Payment> payments}) {
    dataGridRows = payments
        .map<DataGridRow>((payment) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: payment.id),
              DataGridCell<String>(
                  columnName: 'amount', value: 'BAM ' + payment.amount),
              DataGridCell<String>(
                  columnName: 'paymentMethod', value: payment.paymentMethod),
              DataGridCell<String>(columnName: 'date', value: payment.date),
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
        child: Text(row.getCells()[0].value.toString()),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[1].value.toString()),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[2].value.toString()),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[3].value.toString()),
      ),
    ]);
  }
}

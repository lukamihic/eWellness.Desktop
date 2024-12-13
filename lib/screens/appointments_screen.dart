import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart' as config show apiUri;

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  List<Appointment> appointments = [];
  late AppointmentDataSource appointmentDataSource;
  String token = '';

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  fetchAppointments() async {
    final Uri fullApiUrl = Uri.parse(config.apiUri + '/users/login');

    final Map<String, String> body = {
      'email': 'desktop',
      'password': 'test',
    };

    final responseLogin = await http.post(
      fullApiUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + token
      },
      body: jsonEncode(body),
    );

    if (responseLogin.statusCode == 200) {
      token = responseLogin.body.toString();
    } else {
      throw Exception('Failed to fetch user.');
    }

    final response = await http.get(Uri.parse('${config.apiUri}/appointments'), headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token});
    if (response.statusCode == 200) {
      setState(() {
        appointments = (json.decode(response.body) as List)
            .map((data) => Appointment.fromJson(data))
            .toList();
        appointmentDataSource = AppointmentDataSource(
          appointments: appointments,
          onEdit: _editAppointment,
          onDelete: _deleteAppointment,
        );
      });
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  void _addAppointment() async {
    final newAppointment = await showDialog<Appointment>(
      context: context,
      builder: (BuildContext context) {
        return AppointmentDialog(
          appointment: Appointment(
            id: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isDeleted: false,
            clientId: 0,
            clientName: '',
            employeeId: 0,
            serviceId: 0,
            serviceName: '',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(Duration(hours: 1)),
            notes: '',
            status: '',
            totalPrice: 0.0,
            name: '',
          ),
          isEdit: false,
        );
      },
    );

    if (newAppointment != null) {
      final response = await http.post(
        Uri.parse('${config.apiUri}/appointments'),
        headers: {'Content-Type': 'application/json', HttpHeaders.authorizationHeader: 'Bearer ' + token},
        body: json.encode(newAppointment.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        fetchAppointments();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to add appointment');
      }
    }
  }

  void _editAppointment(Appointment appointment) async {
    final updatedAppointment = await showDialog<Appointment>(
      context: context,
      builder: (BuildContext context) {
        return AppointmentDialog(
          appointment: appointment,
          isEdit: true,
        );
      },
    );

    if (updatedAppointment != null) {
      updatedAppointment.employeeId = 1;
      final response = await http.put(
        Uri.parse('${config.apiUri}/appointments/${updatedAppointment.id}'),
        headers: {'Content-Type': 'application/json', HttpHeaders.authorizationHeader: 'Bearer ' + token},
        body: json.encode(updatedAppointment.toPutJson()),
      );

      if (response.statusCode == 200) {
        fetchAppointments();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to update appointment');
      }
    }
  }

  void _deleteAppointment(int appointmentId) async {
    final response = await http.delete(
      Uri.parse('${config.apiUri}/appointments/$appointmentId'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token}
    );
    if (response.statusCode == 200) {
      fetchAppointments();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      throw Exception('Failed to delete appointment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: appointments.isEmpty
          ? Center(
              child: Text(
                'No appointments available',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SfDataGrid(
                    source: appointmentDataSource,
                    columns: [
                      GridColumn(
                        columnName: 'service',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child:
                              Text('Service', textAlign: TextAlign.center),
                        ),
                        minimumWidth:
                            (0.35 * MediaQuery.of(context).size.width),
                      ),
                      GridColumn(
                        columnName: 'status',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child:
                              Text('Status', textAlign: TextAlign.center),
                        ),
                        minimumWidth:
                            (0.15 * MediaQuery.of(context).size.width),
                      ),
                      GridColumn(
                        columnName: 'totalPrice',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: Text('Total Price',
                              textAlign: TextAlign.center),
                        ),
                        minimumWidth:
                            (0.15 * MediaQuery.of(context).size.width),
                      ),
                      GridColumn(
                        columnName: 'client',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child:
                              Text('Client', textAlign: TextAlign.center),
                        ),
                        minimumWidth:
                            (0.2 * MediaQuery.of(context).size.width),
                      ),
                      GridColumn(
                        columnName: 'actions',
                        label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child:
                              Text('Actions', textAlign: TextAlign.center),
                        ),
                        minimumWidth:
                            (0.15 * MediaQuery.of(context).size.width),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAppointment,
        child: Icon(
          Icons.add,
          color: Colors.teal,
        ),
      ),
    );
  }
}

class Appointment {
  int id;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;
  int clientId;
  String clientName;
  int employeeId;
  int serviceId;
  String serviceName;
  DateTime startTime;
  DateTime endTime;
  String notes;
  String status;
  double totalPrice;
  String name;

  Appointment({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.clientId,
    required this.clientName,
    required this.employeeId,
    required this.serviceId,
    required this.serviceName,
    required this.startTime,
    required this.endTime,
    required this.notes,
    required this.status,
    required this.totalPrice,
    required this.name,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isDeleted: json['isDeleted'] ?? false,
      clientId: json['clientId'] ?? 0,
      clientName: json['client']['user']['name'] ?? '',
      employeeId: json['employeeId'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      serviceName: json['service']['name'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      notes: json['notes'] ?? '',
      status: json['status'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'clientId': clientId,
      'employeeId': employeeId,
      'serviceId': serviceId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'notes': notes,
      'status': status,
      'totalPrice': totalPrice,
      'name': name,
    };
  }

  Map<String, dynamic> toPutJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'clientId': clientId,
      'employeeId': employeeId,
      'serviceId': serviceId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'notes': notes,
      'status': status,
      'totalPrice': totalPrice
    };
  }
}

class AppointmentDataSource extends DataGridSource {
  AppointmentDataSource({
    required List<Appointment> appointments,
    required this.onEdit,
    required this.onDelete,
  }) {
    dataGridRows = appointments.map<DataGridRow>((appointment) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'service', value: appointment.serviceName),
        DataGridCell<String>(columnName: 'status', value: appointment.status),
        DataGridCell<double>(
            columnName: 'totalPrice', value: appointment.totalPrice),
        DataGridCell<String>(
            columnName: 'client', value: appointment.clientName),
        DataGridCell<Widget>(
          columnName: 'actions',
          value: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => onEdit(appointment),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => onDelete(appointment.id),
              ),
            ],
          ),
        ),
      ]);
    }).toList();
  }

  List<DataGridRow> dataGridRows = [];
  final Function(Appointment) onEdit;
  final Function(int) onDelete;

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
        child: Text(row.getCells()[2].value.toString()),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[3].value),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: row.getCells()[4].value,
      ),
    ]);
  }
}

class AppointmentDialog extends StatefulWidget {
  final Appointment appointment;
  final bool isEdit;

  AppointmentDialog({required this.appointment, required this.isEdit});

  @override
  _AppointmentDialogState createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serviceNameController;
  late TextEditingController _statusController;
  late TextEditingController _clientNameController;
  late TextEditingController _totalPriceController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _serviceNameController =
        TextEditingController(text: widget.appointment.serviceName);
    _statusController = TextEditingController(text: widget.appointment.status);
    _clientNameController =
        TextEditingController(text: widget.appointment.clientName);
    _totalPriceController =
        TextEditingController(text: widget.appointment.totalPrice.toString());
    _notesController = TextEditingController(text: widget.appointment.notes);
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _statusController.dispose();
    _clientNameController.dispose();
    _totalPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<DateTime?> showDateTimePicker(
      BuildContext context, DateTime initialDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: initialDate.hour, minute: initialDate.minute),
      );
      if (time != null) {
        return DateTime(
            date.year, date.month, date.day, time.hour, time.minute);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit Appointment' : 'Add Appointment'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _serviceNameController,
                decoration: InputDecoration(labelText: 'Service Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a service name' : null,
              ),
              TextFormField(
                controller: _statusController,
                decoration: InputDecoration(labelText: 'Status'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the status' : null,
              ),
              TextFormField(
                controller: _clientNameController,
                decoration: InputDecoration(labelText: 'Client Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the client name' : null,
              ),
              TextFormField(
                controller: _totalPriceController,
                decoration: InputDecoration(labelText: 'Total Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the total price' : null,
              ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Notes'),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Start Time:'),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final selectedDate = await showDateTimePicker(
                          context, widget.appointment.startTime);
                      if (selectedDate != null) {
                        setState(() {
                          widget.appointment.startTime = selectedDate;
                        });
                      }
                    },
                    child: Text(
                        '${widget.appointment.startTime.toLocal()}'.split('.')[0]),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('End Time:'),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final selectedDate = await showDateTimePicker(
                          context, widget.appointment.endTime);
                      if (selectedDate != null) {
                        setState(() {
                          widget.appointment.endTime = selectedDate;
                        });
                      }
                    },
                    child: Text(
                        '${widget.appointment.endTime.toLocal()}'.split('.')[0]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.appointment.serviceName = _serviceNameController.text;
              widget.appointment.status = _statusController.text;
              widget.appointment.clientName = _clientNameController.text;
              widget.appointment.totalPrice =
                  double.tryParse(_totalPriceController.text) ?? 0.0;
              widget.appointment.notes = _notesController.text;

              Navigator.of(context).pop(widget.appointment);
            }
          },
          child: Text(widget.isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}

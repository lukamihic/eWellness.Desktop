import 'package:flutter/material.dart';

class AppointmentData {
  final String day;
  final int total;
  final int completed;

  AppointmentData(this.day, this.total, this.completed);
}

class ProfitData {
  final String week;
  final double profit;

  ProfitData(this.week, this.profit);
}

class StatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Charts section
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text('Appointments by Day',
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            Expanded(child: AppointmentChart())
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text('Profit by Week',
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            Expanded(child: ProfitChart())
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Data Grid Section
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Appointments Summary',
                          style: Theme.of(context).textTheme.headlineMedium),
                      Expanded(child: AppointmentDataTable()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [
      AppointmentData('Monday', 10, 8),
      AppointmentData('Tuesday', 12, 9),
      AppointmentData('Wednesday', 8, 7),
      AppointmentData('Thursday', 14, 10),
      AppointmentData('Friday', 10, 6),
    ];

    return CustomPaint(
      size: Size(double.infinity, 200), // Width & height for chart space
      painter: BarChartPainter(data),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<AppointmentData> data;

  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paintTotal = Paint()
      ..color = Colors.blue
      ..strokeWidth = 20;

    final paintCompleted = Paint()
      ..color = Colors.green
      ..strokeWidth = 20;

    double barWidth = size.width / (data.length * 2);
    double spaceBetweenBars = barWidth / 2;

    for (int i = 0; i < data.length; i++) {
      double left = i * 2 * (barWidth + spaceBetweenBars);
      double heightFactor = size.height / 20;

      canvas.drawLine(
        Offset(left, size.height),
        Offset(left, size.height - data[i].total * heightFactor),
        paintTotal,
      );

      canvas.drawLine(
        Offset(left + barWidth + spaceBetweenBars, size.height),
        Offset(left + barWidth + spaceBetweenBars,
            size.height - data[i].completed * heightFactor),
        paintCompleted,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ProfitChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [
      ProfitData('Week 1', 5000),
      ProfitData('Week 2', 7000),
      ProfitData('Week 3', 6500),
      ProfitData('Week 4', 8000),
    ];

    return CustomPaint(
      size: Size(double.infinity, 200), // Width & height for chart space
      painter: LineChartPainter(data),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<ProfitData> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintPoints = Paint()
      ..color = Colors.red
      ..strokeWidth = 8
      ..style = PaintingStyle.fill;

    double widthStep = size.width / (data.length - 1);
    double heightFactor = size.height / 10000;

    Path path = Path();

    for (int i = 0; i < data.length; i++) {
      double x = i * widthStep;
      double y = size.height - data[i].profit * heightFactor;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, paintPoints);
    }

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AppointmentDataTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [
      AppointmentData('Monday', 10, 8),
      AppointmentData('Tuesday', 12, 9),
      AppointmentData('Wednesday', 8, 7),
      AppointmentData('Thursday', 14, 10),
      AppointmentData('Friday', 10, 6),
    ];

    return ListView(
      children: [
        DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('Day')),
            DataColumn(label: Text('Total Appointments')),
            DataColumn(label: Text('Completed Appointments')),
          ],
          rows: data.map((appointment) {
            return DataRow(cells: [
              DataCell(Text(appointment.day)),
              DataCell(Text(appointment.total.toString())),
              DataCell(Text(appointment.completed.toString())),
            ]);
          }).toList(),
        ),
      ],
    );
  }
}

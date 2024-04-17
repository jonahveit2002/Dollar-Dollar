import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphsPage extends StatefulWidget {
  @override
  _GraphsPageState createState() => _GraphsPageState();
}


class _GraphsPageState extends State<GraphsPage> {
  Map<String, double> dataMap = {};
  Map<String, double> incomeMap = {};
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    print('uid: $uid');
    fetchData();
  }

 
    fetchData() async {
      QuerySnapshot expenseResult = await FirebaseFirestore.instance.collection('users').doc(uid).collection('expense').get();
      final List<DocumentSnapshot> expenseDocuments = expenseResult.docs;
      expenseDocuments.forEach((data) {
        print('Document data: ${data.data()}');
        String category = data['category'];
        double amount = data['amount'];
        dataMap[category] = (dataMap[category] ?? 0) + amount;
      });
    
      QuerySnapshot incomeResult = await FirebaseFirestore.instance.collection('users').doc(uid).collection('income').get();
      final List<DocumentSnapshot> incomeDocuments = incomeResult.docs;
      incomeDocuments.forEach((data) {
        String category = data['category'];
        print(data['category']);
        double amount = data['amount'];
        print('catagory: ${category}');
        incomeMap[category] = (incomeMap[category] ?? 0) + amount;
      });
    
      setState(() {});
    }

   

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [
      _buildCard('Income by Category (Pie Chart)', _buildIncomeGraph, 0),
      _buildCard('Expense by Category (Pie Chart)', _buildExpenseGraph, 1),
      _buildCard('Income by Category (Bar Chart)', () => _buildBarChart(incomeMap), 2),
      _buildCard('Expense by Category (Bar Chart)', () => _buildBarChart(dataMap), 3),
      // Add more cards here
    ];
  
    return Scaffold(
      appBar: AppBar(
        title: Text('Graphs'),
      ),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return cards[index];
        },
      ),
    );
  }
  
    Widget _buildCard(String title, Widget Function() buildGraph, int index) {
      Color? color = Color.lerp(Colors.red, Colors.yellow, index / 4.0); // 4 is the total number of cards
      return Card(
        color: color,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          title: Text(title),
          onTap: () => showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  Container(
                    height: 400, // adjust as needed
                    child: buildGraph(),
                  ),
                  Positioned(
                    top: 2,
                    left: 2,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildExpenseGraph() {
      return dataMap.length > 0
          ? _buildPieChart(dataMap)
          : Center(
              child: Text(
                'No data for chart',
                style: TextStyle(fontSize: 24),
              ),
            );
    }

    Widget _buildIncomeGraph() {
      return incomeMap.length > 0
          ? _buildPieChart(incomeMap)
          : Center(
              child: Text(
                'No data for chart',
                style: TextStyle(fontSize: 24),
              ),
            );
    }

    Widget _buildPieChart(Map<String, double> data) {
      // Sort the entries by value in descending order and take the top 5
      var sortedEntries = data.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      var topEntries = sortedEntries.take(5).toList();
    
      var sections = topEntries.map((e) {
        double total = data.values.reduce((a, b) => a + b);
        double percentage = (e.value / total) * 100;
        int index = topEntries.indexOf(e);
        Color? color = Color.lerp(Colors.red, Colors.yellow, index / topEntries.length.toDouble());
        return PieChartSectionData(
          value: e.value,
          radius: 50,
          color: color,
          title: percentage >= 10 ? '${percentage.toStringAsFixed(2)}%' : '',
        );
      }).toList();
    
      return Column(
        children: [
          SizedBox(height: 20),
          Container(
            height: 200, 
            child: PieChart(
              PieChartData(sections: sections),
            ),
          ),
          SizedBox(height: 10),
          Divider(),
          SizedBox(height: 10),
          ...topEntries.map((entry) {
            double total = data.values.reduce((a, b) => a + b);
            double percentage = (entry.value / total) * 100;
            return Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  color: Color.lerp(Colors.red, Colors.yellow, topEntries.indexOf(entry) / topEntries.length.toDouble()),
                ),
                SizedBox(width: 8),
                Text('${entry.key}: \$${entry.value.toStringAsFixed(2)}'),
              ],
            );
          }).toList(),
        ],
      );
    }

  Widget _buildLegend(List<MapEntry<String, double>> topEntries) {
    return Column(
      children: topEntries.map((entry) {
        int index = topEntries.indexOf(entry);
        Color? color = Color.lerp(Colors.red, Colors.yellow, index / topEntries.length.toDouble());
        return Row(
          children: [
            Container(
              width: 20,
              height: 20,
              color: color,
            ),
            SizedBox(width: 8),
            Text(entry.key),
          ],
        );
      }).toList(),
    );
  }
  
  Widget _buildBarChart(Map<String, double> data) {
  if (data.isEmpty) {
    return Center(
      child: Text(
        'No data for chart',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  List<BarChartGroupData> barGroups = [];

  // Sort the entries by value in descending order and take the top 5
  var sortedEntries = data.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  var topEntries = sortedEntries.take(3).toList();

  topEntries.forEach((entry) {
    int index = topEntries.indexOf(entry);
    Color? color = Color.lerp(Colors.red, Colors.yellow, index / topEntries.length.toDouble());
    barGroups.add(
      BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            y: entry.value,
            colors: [color!],
            width: 40,
          ),
        ],
      ),
    );
  });

  return Padding(
    padding: const EdgeInsets.all(40.0),
    child: BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value, _) => const TextStyle(color: Colors.black, fontSize: 10,  fontWeight: FontWeight.bold),
            getTitles: (double value) {
              return topEntries[value.toInt()].key;
            },
          ),
          leftTitles: SideTitles(showTitles: false),
        ),
      ),
    ),
  );
}
}
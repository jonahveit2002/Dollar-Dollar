import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dollar_dollar/controllers/auth_controller.dart';
import 'package:dollar_dollar/main.dart';
import 'package:dollar_dollar/pages/GraphsPage.dart';
import 'package:dollar_dollar/pages/ReciptPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
          
        ),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            AuthController().signOut();
          },
        ),
      ),
      
      body: Column(
        children: [
          SizedBox(height: 10), // Add spacing
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.yellow[800],
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Left to budget:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('income').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> incomeSnapshot) {
                    if (incomeSnapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (incomeSnapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    }

                    double totalIncome = 0.0;
                    for (var doc in incomeSnapshot.data?.docs ?? []) {
                      totalIncome += doc.data()!['amount'] as double;
                    }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('expense').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> expenseSnapshot) {
                  if (expenseSnapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (expenseSnapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                    double totalExpense = 0.0;
                    for (var doc in expenseSnapshot.data?.docs ?? []) {
                      totalExpense += doc.data()!['amount'] as double;
                    }
                                        
                    return Text(
                      '\$${(totalIncome - totalExpense).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                },
              );
            },
          ),
                
              ],
            ),
          ),
          SizedBox(height: 20), // Add spacing
          Container(
            height: 260,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: 
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Income', // Header for income section
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(), 
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('income').snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading");
                      }
                      return ListView(
                        
                        children: snapshot.data?.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(data['name']),
                            subtitle: Text('\$${data['amount']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                document.reference.delete();
                              },
                            ),
                          );
                        }).toList() ?? [],
                        
                      );
                    },
                  ),
                ),
                
              ],
              
            ),
            
          ),
          Container(
            height: 260,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expenses', // Header for income section
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(), // Add a line under the header
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('expense').snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading");
                      }
                      return ListView(
                        
                        children: snapshot.data?.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(data['name']),
                            subtitle: Text('\$${data['amount']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                document.reference.delete();
                              },
                            ),
                          );
                        }).toList() ?? [],
                        
                      );
                    },
                  ),
                ),
              ],
              
            ),
            
          ) 
          
        ],
        
        
      ),
      floatingActionButton: Container(
        height: 80.0,
        width: 80.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.red[400],
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  child: Wrap(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.paid),
                        title: Text('Income'),
                        onTap: () {
                          _showAddDialog();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.sell),
                        title: Text('Expense'),
                        onTap: () {
                          _showExpenseDialog();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Icon(Icons.add, size: 40.0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 30.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.receipt),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReceiptPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.bar_chart),
              onPressed: () {
                print("Button pushed!");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GraphsPage()),
                );
              },
            ),
          ],
        ),
      ),
      );
    }

  void _showAddDialog() {
    
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        double amount = 0;
        String category = '';

        List<String> categories = ['Salary', 'Wages', 'Freelancing', 'Rental', 'Dividends', 'Interest', 'Royalties', 'Capital gains', 'Business', 'Affiliates', 'Other',]; // Your income categories


        return AlertDialog(
          title: Text('Add Income Item'),
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
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0;
                },
              ),
              DropdownButtonFormField<String>(
                value: category.isEmpty ? null : category,
                decoration: InputDecoration(
                  labelText: category.isEmpty ? 'Select Category' : category,
                ),
                items: categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  category = newValue!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && amount > 0) {
                  FirebaseFirestore.instance.collection('users').doc(uid).collection('income').add({
                      'name': name,
                      'amount': amount.toDouble(),
                      'category': category,
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                }
              },
              child: Text('Add'),
            ),
          ],
        );

        
      },
    );
  }
  void _showExpenseDialog(){
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        double amount = 0;
        String category = '';

        List<String> categories = ['Rent/Mortgage', 'Utilities', 'Groceries', 'Transportation', 'Insurance', 'Debt payments', 'Entertainment', 'Clothing', 'Health care', 'Education', 'Other',]; // Your expense categories
        return AlertDialog(
          title: Text('Add Expense Item'),
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
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0;
                },
      
              ),
              DropdownButtonFormField<String>(
                value: category.isEmpty ? null : category,
                decoration: InputDecoration(
                  labelText: category.isEmpty ? 'Select Category' : category,
                ),
                items: categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  category = newValue!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && amount > 0) {
                  FirebaseFirestore.instance.collection('users').doc(uid).collection('expense').add({
                    'name': name,
                    'amount': amount.toDouble(),
                    'category': category,
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                }
              },
              child: Text('Add'),
            ),
          ],
        
        );

        
      },
    );

  }
}


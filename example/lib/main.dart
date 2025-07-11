// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ariyanpay/models/customer_model.dart';
import 'package:ariyanpay/models/request_response.dart';
import 'package:ariyanpay/ariyanpay.dart';
import 'package:ariyanpay/widget/custom_snackbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ariyanpay Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _key,
            child: Column(
              children: [
                TextFormField(
                  validator: (p0) {
                    if (p0!.isEmpty) {
                      return 'Field is required';
                    }
                    return null;
                  },
                  controller: _name,
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  validator: (p0) {
                    if (p0!.isEmpty) {
                      return 'Field is required';
                    }
                    return null;
                  },
                  controller: _email,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_key.currentState!.validate()) {
                      final response = await Ariyanpay.createPayment(
                        context: context,
                        customer: CustomerDetails(
                          fullName: 'Ariyan Shipu',
                          cusPhone: '0181111111',
                        ),
                        amount: '50',
                        valueA: '',
                        valueB: '',
                        valueC: '',
                        valueD: '',
                        valueE: '',
                        valueF: '',
                        valueG: '',
                      );



                      if (response.status == ResponseStatus.completed) {
                        // handle on complete
                        snackBar('Success. TRX_ID ${response.invoiceId}', context);
                      }

                      if (response.status == ResponseStatus.canceled) {
                        // handle on cancel
                      }

                      if (response.status == ResponseStatus.pending) {
                        // handle on pending
                      }
                    }
                  },
                  child: const Text('Make Payment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
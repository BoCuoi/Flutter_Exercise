import 'package:flutter/material.dart';

import '../models/transaction.dart';
import './new_transaction.dart';
import 'transaction_list (Card_custom).dart';

class UserTransactions extends StatefulWidget {
  @override
  _UserTransactionsState createState() => _UserTransactionsState();
}

class _UserTransactionsState extends State<UserTransactions> {
  final List<Transaction> _userTransactions = [
    Transaction(
      id: 't1',
      title: 'New Card',
      amount: 69.99,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't2',
      title: 'New Shoes',
      amount: 99.99,
      date: DateTime.now(),
    ),
  ];

  void _addNewTransaction(String txTitle, double txAmount) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: DateTime.now(),
      id: DateTime.now().toString(),
    );
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        /** 
         * _addNewTransaction is private BUT passing here is a pointer 
         * Note 1: NewTransaction at first is defined as Stateless Widget
         * => after triggerd by onPressed: submitData by addTx() not re-render!
         * => BUT... (read in new_transaction.dart)
         * <> TransactionList() re-render because changing in _userTransactions
         */
        NewTransaction(_addNewTransaction),
        TransactionList(_userTransactions), //Execute by _addNewTransaction()
      ],
    );
  }
}

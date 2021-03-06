import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './models/transaction.dart';

import './widgets/new_transaction.dart';
import './widgets/chart.dart';
import './widgets/transaction_list.dart';

void main() {
  /// Lock landscape-mode
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        //more shades of single color
        //some default Widget not support single but other shape of it
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
        errorColor: Colors.red,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
              ),
              button: TextStyle(color: Colors.white),
            ),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                title: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/// only add WidgetsBindingObserver in State
class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool _showChart = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  ///
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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

  List<Transaction> get _recentTransactions {
    // function returns true -> item is kept into newly returned list
    // Note: where() return Iterable not List
    return _userTransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  // ignore: slash_for_doc_comments
  /**
   * _addNewTransaction() from user_transaction.dart
   * BUT need to trigger in showModalBottomSheet() 
   * => Bring all back here so no need user_transaction.dart
   * => Also it has setState() => Turn main State to Stateful
   */
  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      /**DateTime.now(): Constructor */
      id: DateTime.now().toString(),
    );
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    // showModalBottomSheet(
    //     context: ctx,
    //     builder: (_) {
    //       return GestureDetector(
    //         onTap: () {}, // Do nothing, avoid sheet closed
    //         child: NewTransaction(_addNewTransaction),
    //         behavior: HitTestBehavior.opaque,
    //       );
    //     });

    /// Can get rid of SingleScrollView in new_transaction.dart
    showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        builder: (_) {
          //return NewTransaction(_addNewTransaction);
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: NewTransaction(_addNewTransaction),
            ),
          );
        });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List<Widget> _buildLandscapeContent(AppBar appBar, Widget txListWidget) {
    return [
      Row(
        children: <Widget>[
          Text(
            'Show Chart',
            style: Theme.of(context).textTheme.headline6,
          ),

          /// StatefulWidget to use Switch | adaptive: adjust look base on platform
          Switch.adaptive(
            activeColor: Theme.of(context).accentColor,
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      _showChart
          ? Container(
              height: (MediaQuery.of(context).size.height -
                      appBar.preferredSize.height -
                      MediaQuery.of(context).padding.top) *
                  0.7,
              child: Chart(_recentTransactions),
            )
          : txListWidget
    ];
  }

  List<Widget> _buildPortraitContent(AppBar appBar, Widget txListWidget) {
    return [
      Container(
        height: (MediaQuery.of(context).size.height -
                appBar.preferredSize.height -
                MediaQuery.of(context).padding.top) *
            0.3,
        child: Chart(_recentTransactions),
      ),
      txListWidget
    ];
  }

  Widget _buildAppBar() {
    return Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(
              'Flutter App',
            ),
            trailing: Row(
              /// (defaul) take all the width it can get
              /// <> shrink along its main axis > not cover middle Text()
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //// IconButton require Material Widget ancestor
                ///But in the end it in CupertinoPageScaffold
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(context),
                )
              ],
            ),
          )
        : AppBar(
            title: Text(
              'Flutter App',
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    ///Check is orientation or not
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    /// For calculate height appBar
    /// PreferredSizeWidget for determining which preferredSize using
    final PreferredSizeWidget appBar = _buildAppBar();

    final txListWidget = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );

    /// SafeArea: not push down by respect to the navigation bar iOS
    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // NOTE: weight take infinity => crossAxis not apply
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            /**
             * Container is universal styling (How sth styled, sized, aligned)
             * Card assumes the size of its child
             * - Parent is Container => Card takes it as a measurement
             * => crossAxisAligment.strech
             * TextWidget takes as much space as Text needs
             */

            // Container(
            //   width: double.infinity,
            //   child: Card(
            //     elevation: 5,
            //     color: Colors.blue,
            //     child: Container(
            //       width: double.infinity,
            //       child: Text('CHART!'),
            //     ),
            //   ),
            // ),
            if (isLandscape) ..._buildLandscapeContent(appBar, txListWidget),
            if (!isLandscape) ..._buildPortraitContent(appBar, txListWidget),
            // UserTransactions()
          ],
        ),
      ),
    );
    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            // one Floating Button per page
            floatingActionButtonLocation: Platform.isIOS
                ? Container()
                : FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              onPressed: () => _startAddNewTransaction(context),
              child: Icon(Icons.add),
            ),
          );
  }
}

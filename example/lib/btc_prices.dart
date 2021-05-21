import 'package:flt_worker_nullsafety/flt_worker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'btc_price_file.dart';

/// An example for using low level `WorkManager` api on the Android platform,
/// which polls Bitcoin price periodically every 900 seconds.
class BtcPrices extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BtcPricesState();
}

class _BtcPricesState extends State<BtcPrices> {
  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    // Comments out this line to keep the work running in background
    cancelWork(kTagBtcPricesWork);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Bitcoin Price'),
    ),
    body: SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: _buildDashboard(),
      ),
    ),
  );

  /// Renders the latest Bitcoin price by watching a data file.
  Widget _buildDashboard() => StreamBuilder<dynamic>(
    stream: btcPriceStream(),
    builder: (_, snapshot) => Column(
      children: <Widget>[
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '₿1',
            style: TextStyle(
              color: Colors.lime.shade700,
              fontSize: 56,
              height: 1.618,
            ),
            children: <TextSpan>[
              TextSpan(
                text: '\n=\n',
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 36,
                  height: null,
                ),
              ),
              TextSpan(
                text: snapshot.hasData
                  ? NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                    .format(snapshot.data['amount'])
                  : '',
                style: const TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              TextSpan(
                text: snapshot.hasData
                  ? '\nUpdated at: ${DateFormat('hh:mm a, yyyy MMM dd')
                    .format(DateTime.fromMillisecondsSinceEpoch(snapshot.data['time']))}'
                  : '',
                style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 14,
                  height: null,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  /// Enqueues a work request to poll the price.
  void _startPolling() async {
    await cancelWork(kTagBtcPricesWork); // cancel the previous work
    await enqueueWorkIntent(const WorkIntent(
      identifier: kTagBtcPricesWork,
      repeatInterval: Duration(seconds: 60), // TODO minimum is 900 on Android
      constraints: WorkConstraints(
        networkType: NetworkType.connected,
        batteryNotLow: true,
      ),
    ));
  }
}

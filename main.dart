import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MicoaApp());

class Asset {
  final String symbol, name;
  double price;
  final double change;
  Asset(this.symbol, this.name, this.price, this.change);
}

class Trade {
  final String symbol;
  final bool buy;
  final double quantity, price;
  final DateTime time;
  Trade(this.symbol, this.buy, this.quantity, this.price, this.time);
}

class MicoaApp extends StatelessWidget {
  const MicoaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Micoa Tech Trading',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07111F),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF18C88A), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const TradingHome(),
    );
  }
}

class TradingHome extends StatefulWidget {
  const TradingHome({super.key});
  @override
  State<TradingHome> createState() => _TradingHomeState();
}

class _TradingHomeState extends State<TradingHome> {
  int tab = 0;
  double cash = 10000;
  final Map<String, double> holdings = {};
  final List<Trade> trades = [];
  final List<String> watchlist = ['BTC', 'ETH', 'EURUSD'];
  final assets = [
    Asset('BTC', 'Bitcoin', 67420, 2.31),
    Asset('ETH', 'Ethereum', 3620, 1.84),
    Asset('EURUSD', 'EUR / USD', 1.0912, -0.42),
    Asset('AAPL', 'Apple', 211.40, 0.77),
    Asset('TSLA', 'Tesla', 321.10, -1.15),
    Asset('XAUUSD', 'Gold / USD', 3370.50, 0.53),
  ];

  Asset asset(String s) => assets.firstWhere((a) => a.symbol == s);
  double portfolioValue() => holdings.entries.fold(0, (sum, e) => sum + e.value * asset(e.key).price);
  double totalValue() => cash + portfolioValue();

  void execute(String symbol, bool buy, double qty) {
    final a = asset(symbol);
    final value = qty * a.price;
    if (buy && value > cash) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient virtual funds.')));
      return;
    }
    final current = holdings[symbol] ?? 0;
    if (!buy && qty > current) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You do not own enough of this asset.')));
      return;
    }
    setState(() {
      cash += buy ? -value : value;
      holdings[symbol] = buy ? current + qty : current - qty;
      if (holdings[symbol] == 0) holdings.remove(symbol);
      trades.insert(0, Trade(symbol, buy, qty, a.price, DateTime.now()));
    });
    Navigator.pop(context);
  }

  void order(String symbol) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D1A2A),
      builder: (_) => OrderSheet(asset: asset(symbol), onExecute: execute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Dashboard(cash: cash, total: totalValue(), holdings: holdings, asset: asset, onOrder: order),
      Markets(assets: assets, watchlist: watchlist, onOrder: order, onToggle: (s) => setState(() => watchlist.contains(s) ? watchlist.remove(s) : watchlist.add(s))),
      Portfolio(holdings: holdings, asset: asset, value: portfolioValue(), cash: cash, onOrder: order),
      History(trades: trades),
      const Profile(),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Micoa Tech Trading', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Markets'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Portfolio'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'History'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final double cash, total;
  final Map<String,double> holdings;
  final Asset Function(String) asset;
  final void Function(String) onOrder;
  const Dashboard({super.key, required this.cash, required this.total, required this.holdings, required this.asset, required this.onOrder});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF123B35), Color(0xFF0C1E2E)])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total portfolio value', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('+ Virtual trading account', style: TextStyle(color: Color(0xFF18C88A))),
        ]),
      ),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _stat('Available cash', '\$${cash.toStringAsFixed(2)}')),
        const SizedBox(width: 12),
        Expanded(child: _stat('Positions', '${holdings.length}')),
      ]),
      const SizedBox(height: 24),
      const Text('Popular markets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      for (final s in ['BTC','ETH','EURUSD']) MarketTile(a: asset(s), onOrder: onOrder),
    ]);
  }
  Widget _stat(String title, String value) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white60)), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))])));
}

class Markets extends StatelessWidget {
  final List<Asset> assets;
  final List<String> watchlist;
  final void Function(String) onOrder;
  final void Function(String) onToggle;
  const Markets({super.key, required this.assets, required this.watchlist, required this.onOrder, required this.onToggle});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Markets', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Prices shown here are demo data for paper trading.', style: TextStyle(color: Colors.white60)),
    const SizedBox(height: 14),
    for (final a in assets) MarketTile(a: a, watched: watchlist.contains(a.symbol), onOrder: onOrder, onToggle: () => onToggle(a.symbol)),
  ]);
}

class MarketTile extends StatelessWidget {
  final Asset a;
  final bool watched;
  final VoidCallback? onToggle;
  final void Function(String) onOrder;
  const MarketTile({super.key, required this.a, required this.onOrder, this.watched=false, this.onToggle});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(child: Text(a.symbol.substring(0, 1))),
      title: Text(a.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(a.name),
      trailing: SizedBox(width: 145, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(a.price.toStringAsFixed(a.price < 10 ? 4 : 2)),
          Text('${a.change >= 0 ? '+' : ''}${a.change.toStringAsFixed(2)}%', style: TextStyle(color: a.change >= 0 ? Colors.greenAccent : Colors.redAccent)),
        ]),
        IconButton(onPressed: onToggle, icon: Icon(watched ? Icons.star : Icons.star_border)),
        IconButton(onPressed: () => onOrder(a.symbol), icon: const Icon(Icons.swap_vert)),
      ])),
  );
}

class Portfolio extends StatelessWidget {
  final Map<String,double> holdings;
  final Asset Function(String) asset;
  final double value, cash;
  final void Function(String) onOrder;
  const Portfolio({super.key, required this.holdings, required this.asset, required this.value, required this.cash, required this.onOrder});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Portfolio', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    Card(child: ListTile(title: const Text('Virtual cash'), trailing: Text('\$${cash.toStringAsFixed(2)}'))),
    Card(child: ListTile(title: const Text('Positions value'), trailing: Text('\$${value.toStringAsFixed(2)}'))),
    const SizedBox(height: 18),
    if (holdings.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No open positions yet. Buy an asset to get started.'))),
    for (final e in holdings.entries) Card(child: ListTile(
      title: Text(e.key),
      subtitle: Text('${e.value.toStringAsFixed(6)} units'),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('\$${(e.value * asset(e.key).price).toStringAsFixed(2)}'),
        TextButton(onPressed: () => onOrder(e.key), child: const Text('Trade')),
      ]),
    )),
  ]);
}

class History extends StatelessWidget {
  final List<Trade> trades;
  const History({super.key, required this.trades});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Trade History', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    if (trades.isEmpty) const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No trades yet.'))),
    for (final t in trades) Card(child: ListTile(
      leading: CircleAvatar(child: Icon(t.buy ? Icons.arrow_upward : Icons.arrow_downward)),
      title: Text('${t.buy ? 'BUY' : 'SELL'} ${t.symbol}'),
      subtitle: Text('${t.quantity} @ ${t.price} • ${DateFormat('MMM d, HH:mm').format(t.time)}'),
      trailing: Text('\$${(t.quantity*t.price).toStringAsFixed(2)}'),
    )),
  ]);
}

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
    const SizedBox(height: 14),
    const Center(child: Text('Micoa Trader', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    const SizedBox(height: 24),
    const Card(child: ListTile(leading: Icon(Icons.security), title: Text('Security'), subtitle: Text('Authentication will be added in the next version.'))),
    const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('About'), subtitle: Text('Micoa Tech Trading • Paper Trading v1.0'))),
  ]);
}

class OrderSheet extends StatefulWidget {
  final Asset asset;
  final void Function(String, bool, double) onExecute;
  const OrderSheet({super.key, required this.asset, required this.onExecute});
  @override
  State<OrderSheet> createState() => _OrderSheetState();
}
class _OrderSheetState extends State<OrderSheet> {
  bool buy = true;
  final controller = TextEditingController(text: '0.01');
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${widget.asset.symbol} • \$${widget.asset.price}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 18),
      SegmentedButton<bool>(segments: const [ButtonSegment(value: true, label: Text('Buy')), ButtonSegment(value: false, label: Text('Sell'))], selected: {buy}, onSelectionChanged: (v) => setState(() => buy = v.first)),
      const SizedBox(height: 14),
      TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder())),
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: () {
        final q = double.tryParse(controller.text) ?? 0;
        if (q <= 0) return;
        widget.onExecute(widget.asset.symbol, buy, q);
      }, child: Text(buy ? 'BUY ${widget.asset.symbol}' : 'SELL ${widget.asset.symbol}'))),
    ]),
  );
}

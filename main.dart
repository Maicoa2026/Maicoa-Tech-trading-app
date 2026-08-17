import 'package:flutter/material.dart';

void main() {
  runApp(const MaicoaTradingApp());
}

class MaicoaTradingApp extends StatelessWidget {
  const MaicoaTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maicoa Tech Trading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF146B5B)),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
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
  int index = 0;

  final pages = const [
    DashboardPage(),
    MarketsPage(),
    PortfolioPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: 'Markets'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Portfolio'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back', style: TextStyle(fontSize: 14, color: Colors.black54)),
                  SizedBox(height: 4),
                  Text('Maicoa Trader', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            CircleAvatar(
              radius: 23,
              child: Icon(Icons.person),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: const Color(0xFF146B5B),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Demo portfolio value', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text('₦1,250,000.00', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('+₦18,450.00  +1.50%', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text('Quick actions', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _ActionButton(icon: Icons.add, label: 'Deposit')),
            const SizedBox(width: 12),
            Expanded(child: _ActionButton(icon: Icons.swap_horiz, label: 'Trade')),
          ],
        ),
        const SizedBox(height: 26),
        const Text('Watchlist', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const MarketTile(symbol: 'BTC/USD', name: 'Bitcoin', price: '\$67,420.50', change: '+2.14%'),
        const MarketTile(symbol: 'ETH/USD', name: 'Ethereum', price: '\$3,540.12', change: '+1.21%'),
        const MarketTile(symbol: 'XAU/USD', name: 'Gold', price: '\$2,990.40', change: '+0.48%'),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label is available in demo mode.')),
      ),
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
    );
  }
}

class MarketsPage extends StatelessWidget {
  const MarketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final markets = [
      ('BTC/USD', 'Bitcoin', '\$67,420.50', '+2.14%'),
      ('ETH/USD', 'Ethereum', '\$3,540.12', '+1.21%'),
      ('EUR/USD', 'Euro / Dollar', '1.1684', '+0.36%'),
      ('XAU/USD', 'Gold', '\$2,990.40', '+0.48%'),
      ('AAPL', 'Apple', '\$228.60', '-0.41%'),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Markets', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Market prices shown here are sample data for the starter app.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 18),
        ...markets.map((m) => MarketTile(symbol: m.$1, name: m.$2, price: m.$3, change: m.$4)),
      ],
    );
  }
}

class MarketTile extends StatelessWidget {
  final String symbol, name, price, change;
  const MarketTile({super.key, required this.symbol, required this.name, required this.price, required this.change});

  @override
  Widget build(BuildContext context) {
    final positive = !change.startsWith('-');
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Text(symbol.substring(0, 1))),
        title: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(name),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(change, style: TextStyle(color: positive ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }
}

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text('Portfolio', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        SizedBox(height: 18),
        Card(
          child: Padding(
            padding: EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Demo balance', style: TextStyle(color: Colors.black54)),
                SizedBox(height: 8),
                Text('₦1,250,000.00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        SizedBox(height: 18),
        Text('Holdings', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        MarketTile(symbol: 'BTC', name: 'Bitcoin', price: '₦520,000', change: '+4.2%'),
        MarketTile(symbol: 'ETH', name: 'Ethereum', price: '₦290,000', change: '+2.1%'),
        MarketTile(symbol: 'USD', name: 'US Dollar', price: '₦310,000', change: '+0.3%'),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 45)),
        const SizedBox(height: 12),
        const Center(child: Text('Maicoa Trader', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 25),
        Card(
          child: Column(
            children: [
              ListTile(leading: const Icon(Icons.security), title: const Text('Security'), trailing: const Icon(Icons.chevron_right)),
              ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('Notifications'), trailing: const Icon(Icons.chevron_right)),
              ListTile(leading: const Icon(Icons.help_outline), title: const Text('Help & support'), trailing: const Icon(Icons.chevron_right)),
            ],
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'This starter app uses sample market and portfolio data. Real-money trading, deposits, withdrawals, KYC, authentication and live market data require secure backend services and appropriate regulatory/compliance setup.',
          style: TextStyle(color: Colors.black54, height: 1.4),
        ),
      ],
    );
  }
}

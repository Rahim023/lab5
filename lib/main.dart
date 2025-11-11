import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

const String kApiKey = '17997715-779c-41bc-8a68-6f3d644d50bf';
const String kApiUrl = 'https://api.pokemontcg.io/v2/cards';

const Color primaryRed = Color(0xFFFF6B6B);
const Color primaryYellow = Color(0xFFFFD93D);
const Color darkBg = Color(0xFF0F1419);
const Color cardBg = Color(0xFF1A1F2E);
const Color accentBlue = Color(0xFF6BCB77);
const Color accentPurple = Color(0xFF4D96FF);

void main() => runApp(const PokemonBattleApp());

class PokemonBattleApp extends StatelessWidget {
  const PokemonBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokémon Battle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryRed),
        useMaterial3: true,
        scaffoldBackgroundColor: darkBg,
      ),
      home: const BattleScreen(),
    );
  }
}

enum ViewMode { battle, cards }

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? left;
  Map<String, dynamic>? right;
  String status = '';
  bool loading = false;
  List<dynamic> pool = [];
  ViewMode mode = ViewMode.battle;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _battle();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _ensurePool() async {
    if (pool.isNotEmpty) return;
    setState(() => loading = true);
    final uri = Uri.parse(kApiUrl).replace(queryParameters: {'q': 'supertype:pokemon', 'pageSize': '200'});
    final res = await http.get(uri, headers: {'X-Api-Key': kApiKey});
    final data = json.decode(res.body) as Map<String, dynamic>;
    final list = (data['data'] as List<dynamic>?) ?? [];
    pool = list.where((c) {
      final img = (c['images']?['small'] ?? '') as String;
      final hp = int.tryParse((c['hp'] ?? '').toString()) ?? 0;
      return img.isNotEmpty && hp > 0;
    }).toList();
    setState(() => loading = false);
  }

  Future<void> _battle() async {
    await _ensurePool();
    if (pool.isEmpty) return;
    setState(() => loading = true);
    _scaleController.reset();

    final r = Random();
    var i = r.nextInt(pool.length);
    var j = r.nextInt(pool.length);
    while (j == i) j = r.nextInt(pool.length);

    left = pool[i] as Map<String, dynamic>;
    right = pool[j] as Map<String, dynamic>;

    final lh = int.tryParse((left!['hp']).toString()) ?? 0;
    final rh = int.tryParse((right!['hp']).toString()) ?? 0;

    if (lh > rh) {
      status = '${left!['name']} wins!';
    } else if (rh > lh) {
      status = '${right!['name']} wins!';
    } else {
      status = 'Draw! Same HP.';
    }

    setState(() => loading = false);
    _scaleController.forward();
  }

  Future<void> _showCards() async {
    await _ensurePool();
    setState(() => mode = ViewMode.cards);
  }

  void _showBattleView() => setState(() => mode = ViewMode.battle);

  Widget _fightButton() => ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.08)
            .animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut)),
        child: GestureDetector(
          onTap: (mode == ViewMode.battle && !loading) ? _battle : null,
          child: Container(
            width: 280,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [primaryRed, Color(0xFFFF4757)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: primaryRed.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Center(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (!loading)
                  const Icon(Icons.flash_on, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  loading ? 'Battling...' : 'FIGHT!',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2),
                ),
              ]),
            ),
          ),
        ),
      );

  Widget _bottomButtons() => SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(children: [
          Expanded(
              child: _ModernButton(
                  onPressed: _showCards,
                  icon: Icons.collections_bookmark,
                  label: 'Cards',
                  color: accentBlue)),
          const SizedBox(width: 12),
          Expanded(
              child: _ModernButton(
                  onPressed: _showBattleView,
                  icon: Icons.flash_on,
                  label: 'Battle',
                  color: primaryRed)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final lh = int.tryParse((left?['hp'] ?? '').toString()) ?? 0;
    final rh = int.tryParse((right?['hp'] ?? '').toString()) ?? 0;
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pokémon Battle',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5)),
        centerTitle: true,
      ),
      bottomNavigationBar: _bottomButtons(),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [darkBg, const Color(0xFF1A2332)])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (mode == ViewMode.battle) ...[
                    if (status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: status.contains('Draw')
                                  ? [accentPurple, accentPurple.withOpacity(0.6)]
                                  : [primaryYellow, const Color(0xFFFFC947)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(status,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: darkBg)),
                      ),
                    const SizedBox(height: 24),
                    _fightButton(),
                    const SizedBox(height: 32),
                    LayoutBuilder(builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 700;
                      final leftCard = _PokemonCard(
                          card: left, hp: lh, highlight: lh > rh, position: 'left');
                      final rightCard = _PokemonCard(
                          card: right, hp: rh, highlight: rh > lh, position: 'right');
                      return isNarrow
                          ? Column(children: [
                              leftCard,
                              const SizedBox(height: 20),
                              rightCard
                            ])
                          : Row(
                              children: [
                                Expanded(child: leftCard),
                                const SizedBox(width: 20),
                                Expanded(child: rightCard)
                              ],
                            );
                    }),
                  ] else ...[
                    const Text('Pokémon Cards Gallery',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    if (loading && pool.isEmpty)
                      const Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryRed)))
                    else
                      _CardsGrid(pool: pool),
                  ],
                  const SizedBox(height: 90),
                ]),
          ),
        ),
      ),
    );
  }
}

class _PokemonCard extends StatelessWidget {
  final Map<String, dynamic>? card;
  final int hp;
  final bool highlight;
  final String position;

  const _PokemonCard(
      {required this.card,
      required this.hp,
      required this.highlight,
      required this.position});

  @override
  Widget build(BuildContext context) {
    if (card == null) {
      return const SizedBox(
          height: 300,
          child: Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentBlue))));
    }

    final img = (card!['images']['small']) as String;
    final name = card!['name'];
    final hpColor = highlight ? primaryYellow : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardBg, cardBg.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: highlight ? primaryYellow : Colors.transparent,
            width: highlight ? 3 : 0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            Column(mainAxisSize: MainAxisSize.min, children: [
          Text(name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 12),
          CachedNetworkImage(
            imageUrl: img,
            height: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('HP:',
                    style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold)),
                Text('$hp',
                    style: TextStyle(
                        color: hpColor,
                        fontWeight: FontWeight.bold))
              ]),
          const SizedBox(height: 6),
          ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 8,
                color: Colors.grey.shade700,
                child: FractionallySizedBox(
                    widthFactor: (hp / 200).clamp(0.0, 1.0),
                    child: Container(color: hpColor)),
              )),
          if (highlight)
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: primaryYellow,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: darkBg, size: 16),
                          SizedBox(width: 6),
                          Text('Winner!',
                              style: TextStyle(
                                  color: darkBg,
                                  fontWeight: FontWeight.bold))
                        ])))
        ]),
      ),
    );
  }
}

class _ModernButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _ModernButton(
      {required this.onPressed,
      required this.icon,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16))
        ]),
      ),
    );
  }
}

class _CardsGrid extends StatelessWidget {
  final List<dynamic> pool;
  const _CardsGrid({required this.pool});

  @override
  Widget build(BuildContext context) {
    if (pool.isEmpty) {
      return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
              child: Text('No cards found.',
                  style: TextStyle(color: Colors.white70))));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14),
      itemCount: pool.length,
      itemBuilder: (_, i) {
        final c = pool[i] as Map<String, dynamic>;
        final img = (c['images']?['small'] ?? '') as String;
        final name = (c['name'] ?? '') as String;
        final hp = int.tryParse((c['hp'] ?? '').toString()) ?? 0;
        return Container(
          decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ]),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Expanded(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                          imageUrl: img, fit: BoxFit.contain))),
              const SizedBox(height: 8),
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Text('HP: $hp',
                  style: const TextStyle(color: Colors.white70, fontSize: 12))
            ]),
          ),
        );
      },
    );
  }
}

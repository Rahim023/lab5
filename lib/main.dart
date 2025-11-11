import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

const String kApiKey = '17997715-779c-41bc-8a68-6f3d644d50bf'; // your old key
const String kApiUrl = 'https://api.pokemontcg.io/v2/cards';

void main() => runApp(const PokemonBattleApp());

class PokemonBattleApp extends StatelessWidget {
  const PokemonBattleApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokémon Battle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
        useMaterial3: true,
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

class _BattleScreenState extends State<BattleScreen> {
  Map<String, dynamic>? left;
  Map<String, dynamic>? right;
  String status = '';
  bool loading = false;
  List<dynamic> pool = [];
  ViewMode mode = ViewMode.battle;

  @override
  void initState() {
    super.initState();
    _battle();
  }

  Future<void> _ensurePool() async {
    if (pool.isNotEmpty) return;
    setState(() => loading = true);
    final uri = Uri.parse(kApiUrl).replace(queryParameters: {
      'q': 'supertype:pokemon',
      'pageSize': '200',
    });
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
    final r = Random();
    var i = r.nextInt(pool.length);
    var j = r.nextInt(pool.length);
    while (j == i) {
      j = r.nextInt(pool.length);
    }
    left = pool[i] as Map<String, dynamic>;
    right = pool[j] as Map<String, dynamic>;
    final lh = int.tryParse((left!['hp']).toString()) ?? 0;
    final rh = int.tryParse((right!['hp']).toString()) ?? 0;
    if (lh > rh) {
      status = '${left!['name']} wins!';
    } else if (rh > lh) status = '${right!['name']} wins!';
    else status = 'Draw! Same HP';
    setState(() => loading = false);
  }

  Future<void> _showCards() async {
    await _ensurePool();
    setState(() => mode = ViewMode.cards);
  }

  void _showBattleView() {
    setState(() => mode = ViewMode.battle);
  }

  Widget _fightButton() {
    return SizedBox(
      width: 260,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C5CE7),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: (mode == ViewMode.battle && !loading) ? _battle : null,
        icon: const Icon(Icons.sports_martial_arts, size: 24),
        label: Text(loading ? 'Battling...' : 'FIGHT!'),
      ),
    );
  }

  Widget _bottomButtons() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: _showCards,
                icon: const Icon(Icons.collections),
                label: const Text('Show Cards'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _showBattleView,
                icon: const Icon(Icons.sports_martial_arts),
                label: const Text('Battle'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lh = int.tryParse((left?['hp'] ?? '').toString()) ?? 0;
    final rh = int.tryParse((right?['hp'] ?? '').toString()) ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon Battle')), // no “Lab 5”
      bottomNavigationBar: _bottomButtons(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (mode == ViewMode.battle) ...[
                if (status.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                _fightButton(),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 700;

                    final leftCard = Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: _PokemonCard(card: left, hp: lh, highlight: lh > rh),
                      ),
                    );
                    final rightCard = Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: _PokemonCard(card: right, hp: rh, highlight: rh > lh),
                      ),
                    );

                    return isNarrow
                        ? Column(children: [leftCard, const SizedBox(height: 12), rightCard])
                        : Row(children: [
                            Expanded(child: leftCard),
                            const SizedBox(width: 12),
                            Expanded(child: rightCard),
                          ]);
                  },
                ),
                const SizedBox(height: 12),
              ] else ...[
                const Text('All Pokémon Cards',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (loading && pool.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  _CardsGrid(pool: pool),
                const SizedBox(height: 12),
              ],
              // keeps content above the bottom buttons -> no overflow stripe
              const SizedBox(height: 90),
            ],
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
  const _PokemonCard({required this.card, required this.hp, required this.highlight});

  @override
  Widget build(BuildContext context) {
    if (card == null) {
      return const SizedBox(
        height: 210,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final img = (card!['images']['small']) as String;
    final name = card!['name'];

    return Card(
      elevation: highlight ? 8 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              width: 220,
              height: 140, // smaller image to avoid overflow
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(imageUrl: img, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'HP: $hp',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: highlight ? Colors.green : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardsGrid extends StatelessWidget {
  final List<dynamic> pool;
  const _CardsGrid({required this.pool});

  @override
  Widget build(BuildContext context) {
    if (pool.isEmpty) return const Center(child: Text('No cards found.'));
    return LayoutBuilder(
      builder: (context, constraints) {
        int cross = 2;
        if (constraints.maxWidth > 900) {
          cross = 4;
        } else if (constraints.maxWidth > 700) cross = 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3 / 4,
          ),
          itemCount: pool.length,
          itemBuilder: (_, i) {
            final c = pool[i] as Map<String, dynamic>;
            final img = (c['images']?['small'] ?? '') as String;
            final name = (c['name'] ?? '') as String;
            final hp = int.tryParse((c['hp'] ?? '').toString()) ?? 0;
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(imageUrl: img, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('HP: $hp', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

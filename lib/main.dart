import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const MercavistaApp());
}

class MercavistaApp extends StatelessWidget {
  const MercavistaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercavista v2.0',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

enum Mode { cheapest, fastest }

class _HomePageState extends State<HomePage> {
  // ZONA2: direcciones
  final List<String> _addresses = [
    "Carlos Antunez 2557, Chile",
    "Los Nogales 827, Chile",
    "Isla Mocha 912, Chile",
  ];
  String _selectedAddress = "Carlos Antunez 2557, Chile";

  // ZONA3: modo
  Mode _mode = Mode.cheapest;

  // ZONA4: marketplaces fijos
  final List<Map<String, String>> _marketplaces = [
    {"label": "Temu", "logo": "https://i.imgur.com/jqherKS.png"},
    {"label": "Shein", "logo": "https://i.imgur.com/yqGyzsp.png"},
    {"label": "AliExpress", "logo": "https://i.imgur.com/hYBzgt2.png"},
    {"label": "Amazon", "logo": "https://i.imgur.com/tp5NK8k.png"},
    {"label": "Mercado Libre", "logo": "https://i.imgur.com/qWyvyGd.png"},
    {"label": "Shopee", "logo": "https://i.imgur.com/Mua65R9.png"},
  ];

  // Por cada producto:
  // - una lista ordenada de detalles por marketplace (winner siempre en 0)
  late final List<List<Map<String, dynamic>>> _productDetailData;
  // índice actual del carrusel por producto
  late List<int> _carouselIndexPerProduct;

  // Datos de los productos
  final List<Map<String, String>> _products = [
    {
      "name":
          "GMKtec Mini PC Intel N150 (Turbo 3.6GHz) 16GB DDR4 1TB PCIe M.2 NVMe SSD, Desktop Computer 4K Dual HDMI Display/4x USB3.2/WiFi 6/BT5.2/RJ45 Ethernet Nucbox G3 Plus",
      "image":
          "https://f.media-amazon.com/images/I/71VNuUTaTBL._AC_UY218_.jpg"
    },
    {
      "name":
          "KAMRUI GK3Plus Mini PC, 16GB RAM 512GB M.2 SSD Mini Computers,12th Gen Alder Lake N95 (up to 3.4GHz) Micro PC, 2.5''SSD, Gigabit Ethernet,4K UHD,WiFi,BT,VESA/Home/Business Small pc",
      "image":
          "https://f.media-amazon.com/images/I/61x9n4E3a7L._AC_UY218_.jpg"
    },
    {
      "name":
          "GMKtec Mini PC, Intel Twin Lake N150 (Upgraded N100), 16GB DDR4 RAM 512GB PCIe M.2 SSD, Desktop Computer 4K Dual HDMI/USB3.2/WiFi 6/BT5.2/2.5GbE RJ45 for Office, Business",
      "image":
          "https://f.media-amazon.com/images/I/71pPJTIqYEL._AC_UY218_.jpg"
    },
  ];

  @override
  void initState() {
    super.initState();

    // inicializar índices de carrusel a 0
    _carouselIndexPerProduct =
        List<int>.filled(_products.length, 0, growable: false);

    // generar datos de detalle por producto
    _productDetailData = List.generate(_products.length, (_) {
      // 1) elegir random "winner" index
      final winnerIdx = Random().nextInt(_marketplaces.length);
      // 2) reordenar para que el winner quede primero
      final raw = List<Map<String, String>>.from(_marketplaces);
      final winnerMap = raw.removeAt(winnerIdx);
      final orderedMaps = [winnerMap, ...raw];

      // 3) para cada marketplace en orderedMaps, generar un map de detalles
      return orderedMaps.map((mp) {
        final price = _randInt(251870, 611600);
        final freeShip = Random().nextBool();
        final shipCost = freeShip ? 0 : _randInt(17001, 62300);
        final total = price + shipCost;
        final rating = _randRating();
        final opin = _fmtOpinions();
        final deliveryDate = DateFormat('d MMM', 'es')
            .format(DateTime.now().add(Duration(days: _randInt(1, 10))));

        return <String, dynamic>{
          'label': mp['label']!,
          'logo': mp['logo']!,
          'price': price,
          'shippingCost': shipCost,
          'total': total,
          'rating': rating,
          'opinions': opin,
          'deliveryDate': deliveryDate,
        };
      }).toList();
    });
  }

  // Helpers aleatorios
  int _randInt(int min, int max) => min + Random().nextInt(max - min + 1);
  double _randRating() => (4 + Random().nextInt(9)) / 2;
  String _fmtOpinions() {
    final v = _randInt(101, 5501);
    return v >= 1000 ? "${(v / 1000).toStringAsFixed(1)}k" : v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ZONA1: buscador
            Container(
              color: const Color(0xFF002844),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Buscar producto',
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.mic, color: Colors.grey),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),

            // ZONA2: dirección
            Container(
              color: const Color(0xFFF99E2B),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedAddress,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: (v) => setState(() => _selectedAddress = v),
                    itemBuilder: (_) => _addresses
                        .map((a) => PopupMenuItem(value: a, child: Text(a)))
                        .toList(),
                  )
                ],
              ),
            ),

            // ZONA3: modo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ModeButton(
                    label: "Más económico",
                    selected: _mode == Mode.cheapest,
                    onTap: () => setState(() => _mode = Mode.cheapest),
                  ),
                  const SizedBox(width: 16),
                  _ModeButton(
                    label: "Más rápido",
                    selected: _mode == Mode.fastest,
                    onTap: () => setState(() => _mode = Mode.fastest),
                  ),  
                ],
              ),
            ),

            // listado de productos
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _products.length,
                itemBuilder: (ctx, idx) {
                  final prod = _products[idx];
                  final detailsList = _productDetailData[idx];
                  final carIdx = _carouselIndexPerProduct[idx];
                  final winner = detailsList[0]; // siempre fijo

                  final sel = detailsList[carIdx]; // datos del carousel actual

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IZQUIERDA: (5,6,7,8)
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // (5) título fijo
                              Text(
                                winner['label'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // (6) tarjeta gris
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 5, right: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F7F7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // (7) logo + (8) cursiva
                                    Row(
                                      children: [
                                        Image.network(
                                          winner['logo'],
                                          height: 24,
                                          width: 24,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            _mode == Mode.cheapest
                                                ? 'es el más económico'
                                                : 'tiene el envío más rápido',
                                            style: const TextStyle(
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // imagen del producto
                                    Center(
                                      child: Image.network(
                                        prod['image']!,
                                        height: 120,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // DERECHA: (4) carrusel + (9–15)
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // (4) carrusel usando detailsList
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: () => setState(() {
                                      _carouselIndexPerProduct[idx] =
                                          (carIdx - 1 + detailsList.length) %
                                              detailsList.length;
                                    }),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: List.generate(
                                          detailsList.length, (i) {
                                            final m = detailsList[i];
                                            final selected = i == carIdx;
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 4),
                                              child: GestureDetector(
                                                onTap: () => setState(() {
                                                  _carouselIndexPerProduct[idx] = i;
                                                }),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: selected
                                                        ? const Color(0xFF002844)
                                                        : const Color(0xFFEAF9FF),
                                                    borderRadius:
                                                        BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    m['label'],
                                                    style: TextStyle(
                                                      color: selected
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () => setState(() {
                                      _carouselIndexPerProduct[idx] =
                                          (carIdx + 1) % detailsList.length;
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // (9) nombre del producto
                              Text(
                                prod['name']!,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // (10) precio
                              Text(
                                'CLP \$${NumberFormat("#,###", "es").format(sel['price'])}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              // (11) estrellas + opiniones
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${sel['rating']} (${sel['opinions']})',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // (12) envío
                              Row(
                                children: [
                                  const Icon(Icons.local_shipping, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    sel['shippingCost'] == 0
                                        ? 'Envío: Gratis'
                                        : 'Envío: CLP ${NumberFormat("#,###", "es").format(sel['shippingCost'])}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // (13) total
                              Container(
                                color: const Color(0xFFF4F4F4),
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  'Total: CLP ${NumberFormat("#,###", "es").format(sel['total'])}',
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // (14) fecha
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black),
                                  children: [
                                    const TextSpan(text: 'Entrega el '),
                                    TextSpan(
                                      text: sel['deliveryDate'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ' a Chile'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // (15) botón
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF99E2B),
                                  ),
                                  onPressed: () {},
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      'Ir a comprar',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ZONA6: barra inferior
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Ofertas'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Guardados'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cuenta'),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF9FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF002844) : const Color(0xFFBCC0BF),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: const Color(0xFF002844),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}




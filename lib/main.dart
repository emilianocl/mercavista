import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'product_database.dart';
import 'webview_page.dart';  // <-- El nuevo widget que crearemos

// ------------------------
// ENUM GLOBAL
// ------------------------
enum Mode { cheapest, fastest }

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
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingPage(),
        '/list': (ctx) {
          final filter = ModalRoute.of(ctx)!.settings.arguments as String?;
          return HomePage(filter: filter);
        },
        '/detail': (ctx) {
          final args =
              ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>;
          return ProductDetailPage(
            details: args['details'] as List<Map<String, dynamic>>,
            selIndex: args['selIndex'] as int,
            mode: args['mode'] as Mode,
          );
        },
      },
    );
  }
}

// ------------------------
// BOTTOM NAV BAR COMPARTIDO
// ------------------------
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavBar({Key? key, required this.currentIndex})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
        BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Ofertas'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Guardados'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cuenta'),
      ],
    );
  }
}

// =============================================================================
//                                VISTA 01
// =============================================================================
class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEDF2),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            const SizedBox(height: 16),
            const _SlideshowCarousel(),
            const SizedBox(height: 16),
            _buildMiniCategoryRow(context),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildSearchBar(BuildContext ctx) => Container(
        color: const Color(0xFF002844),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                const Icon(Icons.search, color: Colors.grey,size: 36),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 24,              // << aquí pones el tamaño que quieras
                      color: Colors.black,       // opcional: color del texto
                        ),
                    onSubmitted: (txt) =>
                        Navigator.pushNamed(ctx, '/list', arguments: txt),
                    decoration: const InputDecoration(
                        hintText: 'Buscar producto', hintStyle: TextStyle(fontSize: 24),border: InputBorder.none),
                  ),
                )
              ]),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration:
                const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child:
                IconButton(icon: const Icon(Icons.mic), color: Colors.grey, onPressed: () {}),
          )
        ]),
      );

  Widget _buildMiniCategoryRow(BuildContext context) {
    final miniPcImg = productDatabase
        .firstWhere((p) => p['subcategoria'] == 'minipc')['imagen_producto']
            as String;
    final smImg = productDatabase
        .firstWhere((p) => p['subcategoria'] == 'smartwatch')['imagen_producto']
            as String;
    const zapatillasImg =
        'https://f.media-amazon.com/images/I/71ShW6RrpKL._AC_UL640_FMwebp_QL65_.jpg';

    Widget card(String title, String img, String filter) {
      return Expanded(
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/list', arguments: filter),
child: Container(
  height: 280,
  margin: const EdgeInsets.symmetric(horizontal: 4),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // — texto en una línea, con "…" si es muy largo
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Continua comprando $title',
          style: const TextStyle(fontSize: 12),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // — ocupa todo el espacio restante para encajar la imagen sin forzar altura fija
      Expanded(
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(12)),
          child: Image.network(
            img,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ],
  ),
),

        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        card('Mini pc', miniPcImg, 'minipc'),
        card('Smartwatch', smImg, 'smartwatch'),
        card('Zapatillas', zapatillasImg, 'zapatillas'),
      ]),
    );
  }
}

// Carousel que rota cada 4 segundos
class _SlideshowCarousel extends StatefulWidget {
  const _SlideshowCarousel({Key? key}) : super(key: key);
  @override
  __SlideshowCarouselState createState() => __SlideshowCarouselState();
}

class __SlideshowCarouselState extends State<_SlideshowCarousel> {
  final _imgs = [
    'https://f.media-amazon.com/images/I/71pXrwZWWXL._SX3000_.jpg',
    'https://f.media-amazon.com/images/I/61nqLqnFKnL._SX3000_.jpg',
    'https://f.media-amazon.com/images/I/81hxkKd9IgL._SX3000_.jpg',
  ];
  late final PageController _ctrl;
  late Timer _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _page = (_page + 1) % _imgs.length;
      _ctrl.animateToPage(_page,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: PageView(
        controller: _ctrl,
        children: _imgs
            .map((url) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(url, fit: BoxFit.cover),
                ))
            .toList(),
      ),
    );
  }
}

// =============================================================================
//                                VISTA 02
// =============================================================================
class HomePage extends StatefulWidget {
  final String? filter;
  const HomePage({Key? key, this.filter}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _addresses = [
    "Carlos Antunez 2557, Chile",
    "Los Nogales 827, Chile",
    "Isla Mocha 912, Chile",
  ];
  String _selectedAddress = "Carlos Antunez 2557, Chile";
  Mode _mode = Mode.cheapest;
  late final List<int> _carouselIndex;
  late final List<ScrollController> _controllers;
  final Map<String, String> _logoMap = {
    "Temu": "https://i.imgur.com/jqherKS.png",
    "Shein": "https://i.imgur.com/yqGyzsp.png",
    "Aliexpress": "https://i.imgur.com/hYBzgt2.png",
    "Amazon": "https://i.imgur.com/tp5NK8k.png",
    "Mercado Libre": "https://i.imgur.com/qWyvyGd.png",
    "Shopee": "https://i.imgur.com/Mua65R9.png",
  };

  @override
  void initState() {
    super.initState();
    _carouselIndex = List<int>.filled(productDatabase.length, 0, growable: false);
    _controllers = List.generate(
        productDatabase.length, (_) => ScrollController(initialScrollOffset: 0));
  }

  @override
  Widget build(BuildContext context) {
    final all = productDatabase;
    final filtered = widget.filter == null
        ? all
        : all.where((p) {
            final sub = (p['subcategoria'] as String).toLowerCase();
            final prod = (p['producto'] as String).toLowerCase();
            final f = widget.filter!.toLowerCase();
            return sub.contains(f) || prod.contains(f);
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEAEDF2),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildSearchBar(context),
            _buildAddressBar(),
            _buildModeSelector(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: filtered.length,
                itemBuilder: (_, idx) => _buildProductCard(idx, filtered),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  // Barra de búsqueda CON FLECHA
  Widget _buildSearchBar(BuildContext ctx) => Container(
        color: const Color(0xFF002844),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            iconSize:36,
            onPressed: () => Navigator.pop(ctx),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                const Icon(Icons.search, color: Colors.grey, size:36),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 24,              // << aquí pones el tamaño que quieras
                      color: Colors.black,       // opcional: color del texto
                      ),
                    onSubmitted: (txt) => Navigator.pushReplacementNamed(
                        ctx, '/list',
                        arguments: txt),
                    decoration: const InputDecoration(
                        hintText: 'Buscar producto', border: InputBorder.none,hintStyle: TextStyle(fontSize: 24)),
                  ),
                )
              ]),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration:
                const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child:
                IconButton(icon: const Icon(Icons.mic), color: Colors.grey, onPressed: () {}),
          )
        ]),
      );

  Widget _buildAddressBar() => Container(
        color: const Color(0xFFF99E2B),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          const Icon(Icons.location_on, color: Colors.black),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_selectedAddress,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.arrow_drop_down),
            onSelected: (v) => setState(() => _selectedAddress = v),
            itemBuilder: (_) =>
                _addresses.map((a) => PopupMenuItem(value: a, child: Text(a,style: const TextStyle(fontSize: 20)))).toList(),
          ),
        ]),
      );

  Widget _buildModeSelector() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
        ]),
      );

  Widget _buildProductCard(int idx, List<Map<String, dynamic>> filtered) {
    final product = filtered[idx];
    final ids = (product['id_mismo_producto'] as String)
        .replaceAll('(', '')
        .replaceAll(')', '')
        .split(',')
        .map(int.parse)
        .toList();
    final details = ids.map((i) => productDatabase[i - 1]).toList();
    details.sort((a, b) {
      if (_mode == Mode.cheapest) {
        return (a['costo_producto'] as int)
            .compareTo(b['costo_producto'] as int);
      } else {
        return DateTime.parse(a['fecha_entrega_inicial'] as String)
            .compareTo(DateTime.parse(b['fecha_entrega_inicial'] as String));
      }
    });
    final winner = details.first;
    final sel = details[_carouselIndex[idx]];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: LayoutBuilder(builder: (_, constraints) {
        final cardWidth = constraints.maxWidth;
        return Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Best logo + name
              Row(children: [
                Image.network(_logoMap[winner['marketplace']]!, width: 60, height: 60),
                const SizedBox(width: 8),
                Text(winner['marketplace'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 12),
              // Carrusel marketplaces
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: cardWidth * 2 / 3,
                  height: 38,
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        final c = _controllers[idx];
                        c.animateTo(c.offset - 80,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease);
                        setState(() {
                          _carouselIndex[idx] =
                              (_carouselIndex[idx] - 1 + details.length) %
                                  details.length;
                        });
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _controllers[idx],
                        scrollDirection: Axis.horizontal,
                        itemCount: details.length,
                        itemBuilder: (_, i) {
                          final m = details[i];
                          final active = i == _carouselIndex[idx];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _carouselIndex[idx] = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: active
                                      ? const Color(0xFF002844)
                                      : const Color(0xFFEAF9FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(m['marketplace'],
                                    style: TextStyle(
                                        color:
                                            active ? Colors.white : Colors.black,
                                        fontSize: 20)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        final c = _controllers[idx];
                        c.animateTo(c.offset + 80,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease);
                        setState(() {
                          _carouselIndex[idx] =
                              (_carouselIndex[idx] + 1) % details.length;
                        });
                      },
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              // Imagen + detalles
              Row(children: [
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Image.network(sel['imagen_producto'] as String,
                        height: 140, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sel['producto'] as String,
                          style: const TextStyle(fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text(
                        '${sel['prefijo_costo']}${NumberFormat("#,###", "es").format(sel['costo_producto'])}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                            '${(sel['numero_estrellas'] as double).toStringAsFixed(1)} (${sel['numero_reviews']})',
                            style: const TextStyle(fontSize: 14)),
                      ]),
                      const SizedBox(height: 6),
                      Text(
                        sel['costo_envio'] == 0
                            ? 'Envío: Gratis'
                            : 'Envío: ${sel['prefijo_costo']}${NumberFormat("#,###", "es").format(sel['costo_envio'])}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        color: const Color(0xFFF4F4F4),
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          'Total: ${sel['prefijo_costo']}${NumberFormat("#,###", "es").format(sel['costo_total'])}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Builder(builder: (_) {
                        final di =
                            DateTime.parse(sel['fecha_entrega_inicial'] as String);
                        final df =
                            DateTime.parse(sel['fecha_entrega_final'] as String);
                        final start = DateFormat('dd MMMM', 'es').format(di);
                        final end = DateFormat('dd MMMM', 'es').format(df);
                        return RichText(
                          text: TextSpan(
                            style:
                                const TextStyle(fontSize: 12, color: Colors.black),
                            children: [
                              const TextSpan(text: 'Envío ',style: TextStyle(fontSize: 16)),
                              TextSpan(
                                  text: '$start - $end',
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                              TextSpan(text: ' a Chile',style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF99E2B),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          onPressed: () {
                            Navigator.pushNamed(context, '/detail', arguments: {
                              'details': details,
                              'selIndex': _carouselIndex[idx],
                              'mode': _mode,
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('Ir a comprar',
                                style: TextStyle(color: Colors.white,fontSize: 24)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ],
          ),
        );
      }),
    );
  }
}

// ------------------------
// BOTONES MODO
// ------------------------
class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeButton(
      {Key? key, required this.label, required this.selected, required this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF9FF) : const Color(0xFFEAEDF2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? const Color(0xFF002844) : const Color(0xFFBCC0BF),
              width: 2),
        ),
        child: Text(label,
            style:
                const TextStyle(color: Color(0xFF002844), fontWeight: FontWeight.bold,fontSize: 20)),
      ),
    );
  }
}

// =============================================================================
//                                VISTA 03
// =============================================================================
class ProductDetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> details;
  final int selIndex;
  final Mode mode;
  const ProductDetailPage({
    Key? key,
    required this.details,
    required this.selIndex,
    required this.mode,
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late int _currentImg;
  late bool _favorite;

  @override
  void initState() {
    super.initState();
    _currentImg = widget.selIndex;
    _favorite = false;
  }

  @override
  Widget build(BuildContext context) {
    const double stripeHeight = 250.0; // altura de la franja naranja
    final sel = widget.details[widget.selIndex];
    final complement = (sel['imagen_producto_complement'] as List).cast<String>();
    final total = sel['costo_total'] as int;
    final di = DateTime.parse(sel['fecha_entrega_inicial'] as String);
    final df = DateTime.parse(sel['fecha_entrega_final'] as String);
    final start = DateFormat('dd MMMM', 'es').format(di);
    final end = DateFormat('dd MMMM', 'es').format(df);
    final int marketplaceCount = widget.details.length;
    final String subtitle = 'El producto se encontró en $marketplaceCount marketplaces';

    final logoMap = {
      "Temu": "https://i.imgur.com/jqherKS.png",
      "Shein": "https://i.imgur.com/yqGyzsp.png",
      "Aliexpress": "https://i.imgur.com/hYBzgt2.png",
      "Amazon": "https://i.imgur.com/tp5NK8k.png",
      "Mercado Libre": "https://i.imgur.com/qWyvyGd.png",
      "Shopee": "https://i.imgur.com/Mua65R9.png",
    };

    return Scaffold(
      backgroundColor: const Color(0xFFEAEDF2),
      body: Stack(
        children: [
          // Fondo: franja naranja + gris
          Column(
            children: [
              Container(height: stripeHeight, color: const Color(0xFFF99E2B)),
              const Expanded(child: SizedBox()),
            ],
          ),

          // Contenido desplazable
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: stripeHeight * 0.5),

                // Tarjeta blanca grande 
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  // height: 700,  // ajustado a 700px
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo + nombre + tag
                      Row(children: [
                        Image.network(logoMap[sel['marketplace']]!, width: 50, height: 50),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(sel['marketplace'] as String,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.mode == Mode.cheapest
                                ? Colors.redAccent
                                : Colors.blueAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.mode == Mode.cheapest ? 'Más económico' : 'Más rápido',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),

                      // Descripción
                      Text(sel['producto'] as String, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),

                      // Carrusel
                      SizedBox(
                        height: 250,
                        child: PageView.builder(
                          onPageChanged: (i) => setState(() => _currentImg = i),
                          itemCount: complement.length,
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              complement[i],
                              height: 120,         // altura interna de la imagen
                              fit: BoxFit.contain, // centra y mantiene proporción
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Puntos indicadores
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(complement.length, (i) {
                          final active = i == _currentImg;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 10 : 6,
                            height: active ? 10 : 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active ? Colors.black : Colors.grey,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),

                      // Total
                      Container(
                        color: const Color(0xFFF4F4F4),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Total: CLP ${NumberFormat("#,###", "es").format(total)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rango de fechas
                      Text(
                        'Envío $start - $end del ${di.year} a Chile',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Sección "Ir a comprar"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ir a comprar',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black54)),
                      const SizedBox(height: 12),

// Tarjetas pequeñas
Column(
  children: widget.details.map((m) {
    final stars = (m['numero_estrellas'] as double).toStringAsFixed(1);
    final reviews = m['numero_reviews'];
    final price = m['costo_producto'] as int;
    final total2 = m['costo_total'] as int;
    final di2 = DateTime.parse(m['fecha_entrega_inicial'] as String);
    final df2 = DateTime.parse(m['fecha_entrega_final'] as String);
    final st2 = DateFormat('dd MMMM', 'es').format(di2);
    final en2 = DateFormat('dd MMMM', 'es').format(df2);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,  // <— Alinear filas 1 y 2
          children: [
            // IZQUIERDA
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila 1: Nombre
                  Text(
                    m['marketplace'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Fila 2: Estrellas y reviews
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$stars ($reviews)',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),  // <— doble espacio relativo

                  // Fila 3: Fechas
                  Text(
                    'Envío $st2 - $en2',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            // DERECHA
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,            // <— Shrink a contenido
                crossAxisAlignment: CrossAxisAlignment.end, // <— Alinear a la derecha
                children: [
                  // Fila 1: Precio
                  Text(
                    'CLP ${NumberFormat("#,###", "es").format(price)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

// Fila 2: “Con envío” y precio con estilos distintos
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,          // tamaño para “Con envío ”
                        color: Colors.black54,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Con envío ',
                        ),
                        TextSpan(
                          text: 'CLP ${NumberFormat("#,###", "es").format(total2)}',
                          style: const TextStyle(
                            fontSize: 14,       // <-- aquí cambias el tamaño solo para el precio
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8), // <— igual espacio que izquierda

                  // Fila 3: Botón
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002844),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      minimumSize: const Size(110, 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WebViewPage(
                            url:   m['url_producto'] as String,
                            title: m['marketplace'] as String,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Ir al sitio',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }).toList(),
),
const SizedBox(height: 32),


                    ],
                  ),
                ),
              ],
            ),
          ),

          // Flecha y corazón superpuestos (misma posición & tamaño final)
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 8.0),
                  child: IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, right: 8.0),
                  child: IconButton(
                    iconSize: 28,
                    icon: Icon(
                      _favorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => _favorite = !_favorite),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}






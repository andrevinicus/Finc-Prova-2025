import 'package:flutter/material.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  final GlobalKey _iconKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _notifications = [
    {"title": "Pagamento recebido!", "subtitle": "Ontem às 18:30"},
    {"title": "Conta de luz registrada", "subtitle": "Hoje às 08:12"},
    {"title": "Compra no mercado", "subtitle": "Hoje às 09:45"},
  ];

  bool _isOpen = false;
  double _arrowPos = 30;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _closeOverlay();
    }
  }

  void _showOverlay() {
    final renderBox = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final overlay = Overlay.of(context);
    const double popupWidth = 260;

    final bellCenterX = offset.dx + renderBox.size.width / 2;
    final screenWidth = MediaQuery.of(context).size.width;
    const rightMargin = 20.0;
    final popupLeft = screenWidth - rightMargin - popupWidth;
    _arrowPos = bellCenterX - popupLeft;

    setState(() => _isOpen = true); // Atualiza estado do sino rapidamente

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeOverlay,
        child: Stack(
          children: [
            Positioned(
              top: offset.dy + renderBox.size.height + 8,
              right: 20,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  alignment: Alignment.topRight,
                  scale: _scaleAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: ClipPath(
                      clipper: _NotificationClipper(arrowPos: _arrowPos),
                      child: Container(
                        width: popupWidth,
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _notifications.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey[300]),
                          itemBuilder: (context, index) {
                            final notif = _notifications[index];
                            return ListTile(
                              leading: const Icon(Icons.notifications),
                              title: Text(notif["title"]!),
                              subtitle: Text(notif["subtitle"]!),
                              onTap: () {
                                debugPrint("Clicou em ${notif["title"]}");
                                _closeOverlay();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay?.insert(_overlayEntry!);
    _controller.forward();
  }

  void _closeOverlay() {
    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) setState(() => _isOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    int notifCount = _notifications.length;

    return Stack(
      children: [
        IconButton(
          key: _iconKey,
          icon: Icon(
            _isOpen ? Icons.notifications : Icons.notifications_none,
            color: _isOpen ? Colors.blue : null,
          ),
          onPressed: _toggleOverlay,
        ),
        if (notifCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                "$notifCount",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationClipper extends CustomClipper<Path> {
  final double arrowPos;

  _NotificationClipper({required this.arrowPos});

  @override
  Path getClip(Size size) {
    const double radius = 12;
    const double arrowWidth = 14;
    const double arrowHeight = 10;

    final path = Path();
    path.moveTo(radius, 0);

    // Flecha arredondada
    path.lineTo(arrowPos - arrowWidth / 2, 0);
    path.quadraticBezierTo(arrowPos, -arrowHeight, arrowPos + arrowWidth / 2, 0);

    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius));
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height), radius: const Radius.circular(radius));
    path.lineTo(radius, size.height);
    path.arcToPoint(Offset(0, size.height - radius), radius: const Radius.circular(radius));
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: const Radius.circular(radius));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

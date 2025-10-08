import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_notifica/notification_bloc.dart';
import 'bloc_notifica/notification_event.dart';
import 'bloc_notifica/notification_state.dart';

class NotificationBell extends StatefulWidget {
  final NotificationBloc bloc;

  const NotificationBell({super.key, required this.bloc});

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

  bool _isOpen = false;
  double _arrowPos = 30;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Carrega as notificações ao iniciar
    widget.bloc.add(LoadNotifications(widget.bloc.idApp));
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

    final state = widget.bloc.state;
    List<NotificationModel> notifications = [];
    if (state is NotificationLoaded) {
      notifications =
          state.notifications.where((n) => n.visualizado == false).toList();
    }

    setState(() => _isOpen = true);

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
                        child: notifications.isNotEmpty
                            ? ListView.builder(
                                padding: const EdgeInsets.all(8),
                                shrinkWrap: true,
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  final notif = notifications[index];
                                  final isDespesa =
                                      notif.tipo.toLowerCase() == 'despesa';

                                  return Card(
                                    color: Colors.white,
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      leading: Icon(
                                        isDespesa
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        color: isDespesa ? Colors.red : Colors.green,
                                      ),
                                      title: Text(
                                        notif.detalhes,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'R\$ ${notif.valorTotal.toStringAsFixed(2)}',
                                      ),
                                      onTap: () {
                                        widget.bloc.add(
                                          MarkAsVisualized(notif.documentId),
                                        );
                                        _closeOverlay();
                                      },
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  'Nenhuma notificação',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
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

    overlay.insert(_overlayEntry!);
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
    return BlocListener<NotificationBloc, NotificationState>(
      bloc: widget.bloc,
      listener: (context, state) {
        // Dispara notificação local para cada item não visualizado
        if (state is NotificationLoaded) {
          final unvisualized =
              state.notifications.where((n) => !n.visualizado).toList();
          for (var notif in unvisualized) {
            widget.bloc.add(TriggerLocalNotification(
              id: notif.documentId.hashCode,
              title: notif.tipo,
              body: notif.detalhes,
            ));
          }
        }
      },
      child: BlocBuilder<NotificationBloc, NotificationState>(
        bloc: widget.bloc,
        builder: (context, state) {
          int notifCount = 0;
          if (state is NotificationLoaded) {
            notifCount =
                state.notifications.where((n) => !n.visualizado).length;
          }

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
        },
      ),
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
    path.lineTo(arrowPos - arrowWidth / 2, 0);
    path.quadraticBezierTo(
      arrowPos,
      -arrowHeight,
      arrowPos + arrowWidth / 2,
      0,
    );
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius),
    );
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: const Radius.circular(radius),
    );
    path.lineTo(radius, size.height);
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: const Radius.circular(radius),
    );
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: const Radius.circular(radius));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

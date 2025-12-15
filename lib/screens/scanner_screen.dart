import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Nécessaire pour l'interface de scan

// Définition du type de callback pour le résultat du scan
typedef OnScanDataReceived = void Function(String data);

class ScannerScreen extends StatefulWidget {
  // Le titre sera affiché en haut de l'écran (ex: "Scanner un bulletin" ou "Scanner mon QR Code")
  final String title;
  // La fonction à appeler lorsque le QR code est scanné avec succès
  final OnScanDataReceived onScanDataReceived;
  // Texte du bouton d'action secondaire (ex: "Se connecter") - peut être null
  final String? actionButtonText;
  // Callback du bouton d'action secondaire (à appeler par l'utilisateur APRÈS le scan)
  final VoidCallback? onActionButtonPressed;
  // Indique si le bouton d'action doit être affiché
  final bool showActionButton;

  const ScannerScreen({
    super.key,
    required this.title,
    required this.onScanDataReceived,
    this.actionButtonText,
    this.onActionButtonPressed,
    this.showActionButton =
        false, // Par défaut, on ne montre pas le bouton d'action
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  // Variable pour stocker la donnée scannée temporairement
  String? _scannedData;
  // Contrôleur pour le widget MobileScanner
  final MobileScannerController _controller = MobileScannerController();

  // Indicateur si le scan a déjà été traité (pour éviter les scans multiples)
  bool _isProcessing = false;

  // Fonction appelée par le scanner lorsqu'un code est trouvé
  void _handleScan(BarcodeCapture capture) {
    if (_isProcessing) return; // Ne rien faire si déjà en cours de traitement

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? rawData = barcodes.first.rawValue;
      if (rawData != null && _scannedData == null) {
        setState(() {
          _scannedData = rawData;
          _isProcessing =
              true; // Empêche d'autres scans tant que le traitement n'est pas fini
          _controller.stop(); // Arrête la caméra
        });

        // Si aucun bouton d'action n'est requis (traitement immédiat)
        if (!widget.showActionButton) {
          widget.onScanDataReceived(rawData);
          // Permet un nouveau scan si l'utilisateur revient sur l'écran
          _resetScanner();
        }
      }
    }
  }

  // Permet de relancer le scanner si nécessaire
  void _resetScanner() {
    _scannedData = null;
    _isProcessing = false;
    _controller.start();
  }

  // Traite l'action du bouton (dans le cas de l'authentification)
  void _onActionButtonTap() {
    if (_scannedData != null && widget.onActionButtonPressed != null) {
      // Option 1: Appeler la callback du bouton pour le traitement API
      widget.onActionButtonPressed!();

      // Option 2: Appeler la callback de donnée pour le traitement API
      widget.onScanDataReceived(_scannedData!);

      // Vous pouvez ajouter ici la navigation de retour si l'action réussit
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Largeur de la "fenêtre" de scan (carré central)
    const double scanWindowSize = 250;

    return Scaffold(
      backgroundColor: Colors.black, // Fond noir pour contraster la caméra
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_outlined, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: Colors.white),
            onPressed: _resetScanner,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Le flux de la caméra
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _handleScan,
              // Délimiter la zone de scan (pour le confort visuel)
              scanWindow: Rect.fromCenter(
                center: Offset(
                  MediaQuery.of(context).size.width / 2,
                  MediaQuery.of(context).size.height / 2,
                ),
                width: scanWindowSize,
                height: scanWindowSize,
              ),
            ),
          ),

          // 2. Calque de superposition (Overlay) pour l'effet de fenêtre de scan
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlay(
                scanWindow: scanWindowSize,
                borderColor: _scannedData != null
                    ? Colors.green.shade500
                    : Colors.white,
              ),
            ),
          ),

          // 3. Texte d'instruction/Statut
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Text(
              _scannedData != null
                  ? 'Code QR détecté !'
                  : 'Pointez la caméra vers le code QR',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _scannedData != null
                    ? Colors.green.shade500
                    : Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),

          // 4. Message de résultat et Bouton d'Action
          if (_scannedData != null)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // Affichage de la donnée (pour le débogage ou confirmation)
                  // Vous pouvez cacher ceci en production si les données sont sensibles
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Donnée scannée: ${widget.showActionButton ? 'Prête à la connexion' : 'Traitement immédiat...'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),

                  if (widget.showActionButton &&
                      widget.actionButtonText != null)
                    ElevatedButton.icon(
                      onPressed: _onActionButtonTap,
                      icon: const Icon(Icons.login),
                      label: Text(widget.actionButtonText!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                  else if (!widget.showActionButton)
                    const CircularProgressIndicator(color: Colors.green),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// WIDGET D'OVERLAY POUR L'EFFET DE FENÊTRE DE SCAN
// -------------------------------------------------------------

class ScannerOverlay extends CustomPainter {
  final double scanWindow;
  final Color borderColor;

  ScannerOverlay({required this.scanWindow, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 5.0;
    const double cornerLength = 30.0;

    final Rect rect = Rect.fromLTWH(
      (size.width - scanWindow) / 2,
      (size.height - scanWindow) / 2,
      scanWindow,
      scanWindow,
    );

    // 1. Dessiner le calque transparent à l'extérieur de la fenêtre (foncé)
    final RRect cutout = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(12),
    );
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.saveLayer(null, Paint());
    canvas.drawRect(Offset.zero & size, backgroundPaint);
    canvas.drawRRect(
      cutout,
      Paint()..blendMode = BlendMode.clear,
    ); // Crée le trou
    canvas.restore();

    // 2. Dessiner les coins du carré (lignes colorées)
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Coins (Top-Left)
    canvas.drawLine(
      rect.topLeft,
      Offset(rect.left + cornerLength, rect.top),
      borderPaint,
    );
    canvas.drawLine(
      rect.topLeft,
      Offset(rect.left, rect.top + cornerLength),
      borderPaint,
    );

    // Coins (Top-Right)
    canvas.drawLine(
      rect.topRight,
      Offset(rect.right - cornerLength, rect.top),
      borderPaint,
    );
    canvas.drawLine(
      rect.topRight,
      Offset(rect.right, rect.top + cornerLength),
      borderPaint,
    );

    // Coins (Bottom-Left)
    canvas.drawLine(
      rect.bottomLeft,
      Offset(rect.left + cornerLength, rect.bottom),
      borderPaint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      Offset(rect.left, rect.bottom - cornerLength),
      borderPaint,
    );

    // Coins (Bottom-Right)
    canvas.drawLine(
      rect.bottomRight,
      Offset(rect.right - cornerLength, rect.bottom),
      borderPaint,
    );
    canvas.drawLine(
      rect.bottomRight,
      Offset(rect.right, rect.bottom - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

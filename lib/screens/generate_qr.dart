import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';


class QRGenerate extends StatelessWidget {
  final Map<String, String> qrData = {
    'Company': 'Risebeyond Consultancy',
    'Value': '0123456789abcdefghij0123456789' // 32 characters example value
  };

   QRGenerate({super.key}); // Replace with your logo asset path

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<Widget>(
              future: generateCustomizedQrCode(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return snapshot.data!;
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            const SizedBox(height: 20.0),
            const Text('Scan the QR code'),
          ],
        ),
      ),
    );
  }

  Future<Widget> generateCustomizedQrCode() async {
    final String concatenatedData =
        '${qrData['Company']} | ${qrData['Value']}'; // Concatenating the data

    final qrImage = QrImageView(
      data: concatenatedData,
      version: QrVersions.auto,
      size: 300.0,
      backgroundColor: Colors.white,
    );

    final qrImageWidget = RepaintBoundary(
      child: qrImage,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        qrImageWidget,

      ],
    );
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sowaste/core/themes/app_colors.dart';
import 'package:sowaste/data/models/api_result.dart';

import '../reward_controller.dart';
import '../widgets/default_dialog.dart';
import '../widgets/qr_code_result_dialog.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  final rewardController = Get.find<RewardController>();
  @override
  void initState() {
    super.initState();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.resumeCamera();
    controller.scannedDataStream.listen(
      (scanData) async {
        result = scanData;
        if (result != null) {
          controller.pauseCamera();
          var apiResult = await rewardController.postQrCode(result!.code!);
          print(apiResult);
          switch (apiResult.runtimeType) {
            case SuccessResult:
              int point = (apiResult as SuccessResult).data as int;
              await Get.dialog(QrCodeResultDialog(point: point),
                  barrierDismissible: false);
              Get.back();
              break;
            case FailedResult:
              await defaultDialog(
                  title: "Failed",
                  content: (apiResult as FailedResult).message);
              controller.resumeCamera();
              break;
            case ErrorResult:
              await defaultDialog(
                  title: "Error", content: (apiResult as ErrorResult).message);
              controller.resumeCamera();
              break;
          }
        }
      },
      onError: (error) => log(error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                controller?.flipCamera();
              });
            },
            icon: const Icon(Icons.flip_camera_ios),
          )
        ],
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
                borderLength: 20,
                borderColor: AppColors.primary,
                borderWidth: 10,
                borderRadius: 10),
            formatsAllowed: const [BarcodeFormat.qrcode],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: Get.width,
              height: 100,
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Text(
                  "Scan QR Code",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

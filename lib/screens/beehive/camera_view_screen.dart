import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class CameraViewScreen extends StatefulWidget {
  final String cameraUrl;
  const CameraViewScreen({
    super.key,
    required this.cameraUrl,
  });

  @override
  State<CameraViewScreen> createState() => _CameraViewScreenState();
}

class _CameraViewScreenState extends State<CameraViewScreen> {
  late VlcPlayerController _videoPlayerController;

  // -- التعديل رقم 1: إضافة متغير لتتبع حالة المشغل --
  // هذا المتغير يخبرنا متى يكون المشغل جاهزاً لعرض الفيديو
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();

    // -- التعديل رقم 2: إضافة خيارات متقدمة مهمة لـ RTSP --
    _videoPlayerController = VlcPlayerController.network(
      widget.cameraUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        // هذه الخيارات ضرورية لتشغيل RTSP بشكل صحيح
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
        // هذا الخيار يحسن من استقرار البث عبر الشبكة
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(1500),
        ]),
      ),
    );

    // -- التعديل رقم 3: إضافة مستمع (Listener) لتحديث الواجهة --
    // هذا الكود يستمع لحالة المشغل، وعندما يصبح جاهزاً،
    // يقوم بتحديث الواجهة لعرض الفيديو بدلاً من شاشة التحميل.
    _videoPlayerController.addListener(() {
      // نتأكد أن الواجهة لا تزال موجودة على الشاشة
      if (!mounted) return;

      // إذا لم يكن المشغل جاهزاً بعد، لا تفعل شيئاً
      if (_isPlayerReady) return;

      // عندما يصبح المشغل جاهزاً (isInitialized)
      if (_videoPlayerController.value.isInitialized) {
        // نقوم بتحديث الحالة لإخبار الواجهة أن عليها إعادة البناء
        setState(() {
          _isPlayerReady = true;
        });
      }
    });
  }

  @override
  void dispose() async {
    // الكود هنا سليم، لا يحتاج تعديل.
    super.dispose();
    await _videoPlayerController.stop();
    await _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Camera Stream'),
        // يمكنك إضافة لون مميز هنا
        // backgroundColor: Colors.amber[700],
      ),
      body: Center(
        // -- التعديل رقم 4: عرض الفيديو فقط عندما يكون جاهزاً --
        // نستخدم الشرط الثلاثي (ternary operator) هنا
        // إذا كان المشغل جاهزاً، اعرض الفيديو.
        // وإلا، اعرض مؤشر تحميل ورسالة للمستخدم.
        child: _isPlayerReady
            ? VlcPlayer(
          controller: _videoPlayerController,
          aspectRatio: 16 / 9,
          placeholder: const Center(child: CircularProgressIndicator()),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Connecting to camera stream..."),
            SizedBox(height: 8),
            Text("(This might take a few seconds)", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
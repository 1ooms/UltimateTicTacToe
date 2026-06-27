import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ultimate_tic_tac_toe/controllers/ad_controller.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, this.adSize = AdSize.banner});

  final AdSize adSize;
  final adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  final adController = AdController();

  @override
  void initState() {
    super.initState();
    adController.adSettingNotifier.addListener(_adSettingChanged);
    if (adController.adSettingNotifier.value) {
      _loadAd();
    }
  }

  @override
  void dispose() {
    adController.adSettingNotifier.removeListener(_adSettingChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  void _adSettingChanged() {
    if (adController.adSettingNotifier.value && _bannerAd == null) {
      _loadAd();
    }
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: adController.adSettingNotifier,
      builder: (context, showAd, child) {
        if (!showAd || _bannerAd == null) {
          return const SizedBox();
        }

        return SafeArea(
          child: SizedBox(
            width: widget.adSize.width.toDouble(),
            height: widget.adSize.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        );
      },
    );
  }
}

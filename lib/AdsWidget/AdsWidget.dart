import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

//Programado por HeroRickyGames

const String testDevice = '3AF718FF327D10F4E91C786E10E905C4';
const int maxFailedLoadAttempts = 3;

void main() {
  MobileAds.instance.initialize();
}

bool isInDebug = false;

class AdBannerLayout extends StatefulWidget {
  bool isPremium = false;
  AdBannerLayout(this.isPremium, {super.key});

  @override
  State<AdBannerLayout> createState() => _AdBannerLayoutState();
}

class _AdBannerLayoutState extends State<AdBannerLayout> {
  static final AdRequest request = const AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  final adUnitId = 'ca-app-pub-1895475762491539/1058389315';
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  Future<void> loadAd() async {
    isInDebug = true;
    //Botar o meu device como teste device
    List<String> testDeviceIds = ['3AF718FF327D10F4E91C786E10E905C4'];

    RequestConfiguration configuration =
    RequestConfiguration(testDeviceIds: testDeviceIds);
    MobileAds.instance.updateRequestConfiguration(configuration);

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          if(isInDebug){
            debugPrint('${ad.responseInfo} loaded.');
          }
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          if(isInDebug){
            debugPrint('BannerAd failed to load: $error');
          }
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/1033173712'
            : 'ca-app-pub-3940256099942544/4411468910',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadAd();
    _showInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {

    return _bannerAd != null ?
    Align(
      alignment: Alignment.bottomCenter,
      child:
      widget.isPremium == false ?
      SafeArea(
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      )
     :
      Container(

      ),
    ):
    Container(

    );
  }
}



interAd(bool isPremium) async {
  if(isPremium == false){
    MobileAds.instance.initialize();
    InterstitialAd? _interstitialAd;
    int _numInterstitialLoadAttempts = 0;
    final AdRequest request = const AdRequest(
      keywords: <String>['foo', 'bar'],
      contentUrl: 'http://foo.com/bar.html',
      nonPersonalizedAds: true,
    );

    void _createInterstitialAd() {
      InterstitialAd.load(
          adUnitId: "ca-app-pub-1895475762491539/8805033305",
          request: request,
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              print('$ad loaded');
              _interstitialAd = ad;
              _numInterstitialLoadAttempts = 0;
              _interstitialAd!.setImmersiveMode(true);
            },
            onAdFailedToLoad: (LoadAdError error) {
              print('InterstitialAd failed to load: $error.');
              _numInterstitialLoadAttempts += 1;
              _interstitialAd = null;
              if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
                _createInterstitialAd();
              }
            },
          ));
    }

    void _showInterstitialAd() {
      if (_interstitialAd == null) {
        print('Warning: attempt to show interstitial before loaded.');
        return;
      }
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) =>
            print('ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
    _createInterstitialAd();
    showinterad() async {
      await Future.delayed(const Duration(seconds: 5));
      _showInterstitialAd();
    }
    showinterad();
  }else{

  }
}

void interAdReward(bool isPremium) async {
  if(isPremium == false){
    MobileAds.instance.initialize();
    InterstitialAd? _interstitialAd;
    int _numInterstitialLoadAttempts = 0;
    final AdRequest request = const AdRequest(
      keywords: <String>['foo', 'bar'],
      contentUrl: 'http://foo.com/bar.html',
      nonPersonalizedAds: true,
    );

    void _createInterstitialAd() {
      InterstitialAd.load(
          adUnitId: "ca-app-pub-1895475762491539/8805033305",
          request: request,
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              print('$ad loaded');
              _interstitialAd = ad;
              _numInterstitialLoadAttempts = 0;
              _interstitialAd!.setImmersiveMode(true);
            },
            onAdFailedToLoad: (LoadAdError error) {
              print('InterstitialAd failed to load: $error.');
              _numInterstitialLoadAttempts += 1;
              _interstitialAd = null;
              if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
                _createInterstitialAd();
              }
            },
          ));
    }

    void _showInterstitialAd() {
      if (_interstitialAd == null) {
        print('Warning: attempt to show interstitial before loaded.');
        return;
      }
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) =>
            print('ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
    _createInterstitialAd();
    showinterad() async {
      await Future.delayed(const Duration(seconds: 5));
      _showInterstitialAd();
    }
    showinterad();
  }else{

  }
}
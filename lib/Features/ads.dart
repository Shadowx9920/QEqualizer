import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdService {
  final int maxFailedLoadAttempts = 3;

  int _numInterstitialLoadAttempts = 0;
  int _numRewardedLoadAttempts = 0;

  InterstitialAd _interstitialAd;
  RewardedAd _rewardedAd;

  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: "ca-app-pub-7511772989365508/4363078076",
        request: AdRequest(
          nonPersonalizedAds: true,
        ),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }

  void createRewardedAd() {
    RewardedAd.load(
        adUnitId: RewardedAd.testAdUnitId,
        request: AdRequest(
          keywords: <String>['foo', 'bar'],
          contentUrl: 'http://foo.com/bar.html',
          nonPersonalizedAds: true,
        ),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
              createRewardedAd();
            }
          },
        ));
  }

  void showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createRewardedAd();
      },
    );

    _rewardedAd.show(onUserEarnedReward: (RewardedAd ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type}');
    });
    _rewardedAd = null;
  }
}

class AdBanner extends StatefulWidget {
  const AdBanner({Key key}) : super(key: key);
  @override
  _BannerState createState() => _BannerState();
}

class _BannerState extends State<AdBanner> {
  BannerAd _banner;
  bool bannerisloaded = false;
  Widget showBanner() {
    if (bannerisloaded) {
      return AdWidget(ad: _banner);
    } else {
      return Container();
    }
  }

  @override
  void initState() {
    super.initState();
    _banner = BannerAd(
        size: AdSize.banner,
        adUnitId:
            BannerAd.testAdUnitId, //"ca-app-pub-7511772989365508/7418833863",
        listener: BannerAdListener(onAdLoaded: (ad) {
          setState(() {
            _banner = ad;
            bannerisloaded = true;
            debugPrint(bannerisloaded.toString());
          });
        }, onAdFailedToLoad: (ad, error) {
          setState(() {
            _banner = null;
            bannerisloaded = false;
            debugPrint(error.toString());
            ad.dispose();
          });
        }),
        request: AdRequest());
    _banner.load();
  }

  @override
  void dispose() {
    _banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(30.0),
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      alignment: Alignment.topCenter,
      child: showBanner(),
    );
  }
}

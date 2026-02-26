import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../core/logger.dart';

/// AdMob 광고를 관리하는 싱글톤
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // 리워드 광고 Ad Unit ID (Google Test ID)
  // 실제 배포 시 'ca-app-pub-6814440197582204/3533563935'로 교체
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // 전면 광고 Ad Unit ID (Google Test ID)
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;

  /// 앱 시작 시 MobileAds 초기화
  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      // 리워드 및 전면 광고 미리 로드
      loadRewardedAd();
      loadInterstitialAd();
    } catch (e) {
      Logger.log('AdManager init warning: $e');
    }
  }

  /// 전면 광고 로드
  void loadInterstitialAd() {
    if (_interstitialAd != null || _isInterstitialAdLoading) return;
    _isInterstitialAdLoading = true;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          Logger.log('✅ Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoading = false;
          Logger.log('❌ Interstitial ad failed to load: ${error.message}');
          // 5초 후 재시도
          Future.delayed(const Duration(seconds: 5), loadInterstitialAd);
        },
      ),
    );
  }

  /// 리워드 광고 로드
  void loadRewardedAd() {
    if (_rewardedAd != null || _isRewardedAdLoading) return;
    _isRewardedAdLoading = true;

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          Logger.log('✅ Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoading = false;
          Logger.log('❌ Rewarded ad failed to load: ${error.message}');
          // 5초 후 재시도
          Future.delayed(const Duration(seconds: 5), loadRewardedAd);
        },
      ),
    );
  }

  /// 리워드 광고가 준비되었는지 확인
  bool get isRewardedAdReady => _rewardedAd != null;

  /// 리워드 광고 표시
  /// [onRewarded] - 사용자가 광고를 끝까지 시청했을 때 호출되는 콜백
  /// [onNotReady] - 광고가 준비되지 않았을 때 호출되는 콜백
  void showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onNotReady,
  }) {
    if (_rewardedAd == null) {
      Logger.log('⚠️ Rewarded ad not ready');
      onNotReady?.call();
      loadRewardedAd(); // 다시 로드 시도
      return;
    }

    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // 다음 광고 미리 로드
        
        // 사용자가 광고 화면을 닫고 게임 화면으로 돌아왔을 때 보상 제공
        if (rewardEarned) {
          onRewarded();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Logger.log('❌ Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        Logger.log('🎁 User earned reward: ${reward.amount} ${reward.type}');
        // 리워드 조건 달성 기록 (아직 광고가 띄워져 있음)
        rewardEarned = true;
      },
    );
  }

  /// 전면 광고 표시
  /// [onAdClosed] - 광고가 닫혔을 때(또는 실패 시) 다음 작업을 진행하기 위한 콜백
  void showInterstitialAd({required VoidCallback onAdClosed}) {
    if (_interstitialAd == null) {
      Logger.log('⚠️ Interstitial ad not ready');
      onAdClosed();
      loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // 다음 광고 미리 로드
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Logger.log('❌ Interstitial ad failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdClosed();
      },
    );

    _interstitialAd!.show();
  }

  /// 리소스 해제
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

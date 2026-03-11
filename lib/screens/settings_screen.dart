import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants.dart';
import '../data/settings_manager.dart';
import '../data/score_manager.dart';
import '../data/auth_service.dart';
import '../data/cloud_save_service.dart';
import 'package:arrow_escape/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle, style: const TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: SettingsManager(),
        builder: (context, _) {
          final sm = SettingsManager();
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              _buildSectionTitle(AppLocalizations.of(context)!.settingsGameDisplay),
              _buildSwitchCard(
                title: AppLocalizations.of(context)!.settingsSfx,
                icon: Icons.music_note,
                value: sm.sfxEnabled,
                onChanged: sm.setSfxEnabled,
              ),
              const SizedBox(height: 12),
              _buildSwitchCard(
                title: AppLocalizations.of(context)!.settingsBgm,
                icon: Icons.library_music,
                value: sm.bgmEnabled,
                onChanged: sm.setBgmEnabled,
              ),
              const SizedBox(height: 12),
              _buildSwitchCard(
                title: AppLocalizations.of(context)!.settingsHaptic,
                icon: Icons.vibration,
                value: sm.hapticEnabled,
                onChanged: sm.setHapticEnabled,
              ),
              const SizedBox(height: 12),
              _buildSwitchCard(
                title: AppLocalizations.of(context)!.settingsDots,
                icon: Icons.blur_on,
                value: sm.showGrid,
                onChanged: sm.setShowGrid,
              ),
              const SizedBox(height: 12),
              
              // 언어 변경 토글 (English <-> 한국어)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.transparent),
                ),
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.settingsLanguage, style: const TextStyle(color: AppColors.textPrimary)),
                  leading: const Icon(Icons.language, color: AppColors.textMuted),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'en',
                        label: Text('EN'),
                      ),
                      ButtonSegment<String>(
                        value: 'ko',
                        label: Text('KO'),
                      ),
                    ],
                    selected: {sm.languageCode},
                    onSelectionChanged: (Set<String> newSelection) {
                      sm.setLanguageCode(newSelection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: AppColors.neonCyan.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle(AppLocalizations.of(context)!.settingsAccountData),
              
              StreamBuilder<User?>(
                stream: AuthService().authStateChanges,
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  final isGuest = user == null || user.isAnonymous;

                  if (isGuest) {
                    return Column(
                      children: [
                        // Guest 정보 카드
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, color: AppColors.neonPurple),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.playingAsGuest,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.guestDescription,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                         _buildActionButton(
                          title: AppLocalizations.of(context)!.signInGoogle,
                          icon: Icons.g_mobiledata,
                          color: Colors.white,
                          onTap: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.signingIn)),
                            );
                            final result = await AuthService().signInWithGoogle();
                            if (!context.mounted) return;
                            
                            if (result is String) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result),
                                  backgroundColor: Colors.redAccent,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            } else if (result != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.signInSuccess)),
                              );
                              
                              // ⓪ 삭제된 계정인지 확인하고 30일 이내면 자동 복구
                              final restored = await CloudSaveService().checkAndRestoreUser();
                              if (restored && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!.accountRestored),
                                    backgroundColor: AppColors.neonGreen,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }

                              // ① 클라우드 → 로컬 병합
                              await CloudSaveService().downloadProgress();
                              // ② 로컬 → 클라우드 업로드
                              await CloudSaveService().uploadProgress();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.progressSynced)),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildActionButton(
                          title: AppLocalizations.of(context)!.signInApple,
                          icon: Icons.apple,
                          color: Colors.white,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.appleSignInSoon)),
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        // 로그인 다이어그램
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: AppColors.neonCyan),
                                  const SizedBox(width: 8),
                                  Text(
                                    user.displayName ?? AppLocalizations.of(context)!.googleAccount,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.email ?? AppLocalizations.of(context)!.connected,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActionButton(
                          title: AppLocalizations.of(context)!.forceUpdateCloud,
                          icon: Icons.cloud_download,
                          color: AppColors.neonCyan,
                          onTap: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.downloadingProgress)),
                            );
                            await CloudSaveService().downloadProgress();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.downloadComplete)),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildActionButton(
                          title: AppLocalizations.of(context)!.signOut,
                          icon: Icons.logout,
                          color: Colors.redAccent,
                          onTap: () async {
                            await AuthService().signOut();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.signedOut)),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildActionButton(
                          title: AppLocalizations.of(context)!.deleteAccount,
                          icon: Icons.person_remove,
                          color: Colors.red,
                          onTap: () => _showDeleteAccountDialog(context),
                        ),
                      ],
                    );
                  }
                },
              ),
              
              const SizedBox(height: 32),
              
              // 데이터 초기화 버튼
              OutlinedButton.icon(
                onPressed: () => _showResetDialog(context),
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                label: Text(
                  AppLocalizations.of(context)!.resetAllProgress,
                  style: const TextStyle(color: Colors.redAccent, letterSpacing: 1.2),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.neonCyan,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? AppColors.neonCyan.withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      child: SwitchListTile(
        title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
        secondary: Icon(icon, color: value ? AppColors.neonCyan : AppColors.textMuted),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.neonCyan,
        activeTrackColor: AppColors.neonCyan.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text(AppLocalizations.of(context)!.resetProgressTitle, style: const TextStyle(color: Colors.redAccent)),
        content: Text(
          AppLocalizations.of(context)!.resetProgressMsg,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await ScoreManager().resetAll();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.allProgressReset)),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text(AppLocalizations.of(context)!.deleteAccountTitle, style: const TextStyle(color: Colors.red)),
        content: Text(
          AppLocalizations.of(context)!.deleteAccountMsg,
          style: TextStyle(color: AppColors.textPrimary, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _performAccountDeletion(context);
            },
            child: Text(AppLocalizations.of(context)!.deleteAccountBtn, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performAccountDeletion(BuildContext context) async {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.deletingAccount)),
    );

    // ① Firestore 유저 데이터 삭제
    await CloudSaveService().deleteUserData();
    
    // ② Firebase Auth 계정 삭제
    final result = await AuthService().deleteAccount();
    
    if (result == 'REAUTH_REQUIRED') {
      // 재인증 필요 → 구글 재로그인 요청
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.reauthPrompt)),
      );
      
      final reauthOk = await AuthService().reauthenticateWithGoogle();
      if (!reauthOk) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
               content: Text(AppLocalizations.of(context)!.reauthCancelled),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }
      
      // 재인증 후 다시 삭제 시도
      final retryResult = await AuthService().deleteAccount();
      if (retryResult != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(retryResult), backgroundColor: Colors.redAccent),
          );
        }
        return;
      }
    } else if (result != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    // ③ 로컬 데이터 초기화
    await ScoreManager().resetAll();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.accountDeleted)),
      );
      setState(() {}); // UI 갱신
    }
  }
}

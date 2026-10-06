import 'package:flutter/material.dart';
import '../../settings/app_settings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/styled_header_scaffold.dart';
import '../../services/database_service.dart';
import '../../services/operator_icon_service.dart';

class StatsSettingsPage extends StatefulWidget {
  const StatsSettingsPage({super.key});

  @override
  State<StatsSettingsPage> createState() => _StatsSettingsPageState();
}

class _StatsSettingsPageState extends State<StatsSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings(),
      builder: (context, _) {
        final settings = AppSettings();
        return StyledHeaderScaffold(
          title: 'Nekoko Cloud',
          subtitle: '帮助改进兼容性与容量预测',
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, "隐私 / PRIVACY"),
                const SizedBox(height: 16),
                _buildEnhancerToggle(context, settings),
                const SizedBox(height: 24),
                _buildSectionHeader(context, "统计收集"),
                const SizedBox(height: 16),
                _buildMainToggle(context, settings),
                const SizedBox(height: 16),
                _buildSecondaryOptions(context, settings),
                const SizedBox(height: 24),
                _buildInfoBox(
                  context,
                  "启用后会上传安装相关数据，用于改进容量预测和兼容性判断。关闭后将失去容量预测功能。\n\n注意：实际上报内容包含卡号(ICCID)、EID 及卡片鉴权响应等技术数据，并非匿名；官方隐私政策亦确认服务器会保留 ICCID 与 EID。介意的话请保持此开关关闭。",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEnhancerToggle(BuildContext context, AppSettings settings) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceSubtle(context)),
      ),
      child: _buildSwitchRow(
        context,
        title: "档案状态增强",
        subtitle: "允许向运营商查询卡片状态（会发送 ICCID）。关闭后不再对外发送卡号。",
        value: settings.enableProfileStatusEnhancer,
        onChanged: (v) => settings.setEnableProfileStatusEnhancer(v),
      ),
    );
  }

  Widget _buildMainToggle(BuildContext context, AppSettings settings) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceSubtle(context)),
      ),
      child: _buildSwitchRow(
        context,
        title: "启用 Nekoko Cloud 统计",
        subtitle: "上报安装数据以改进数据库（会上传 ICCID/EID）",
        value: settings.enableNekokoStats,
        onChanged: (v) => settings.setEnableNekokoStats(v),
      ),
    );
  }

  Widget _buildSecondaryOptions(BuildContext context, AppSettings settings) {
    final theme = Theme.of(context);
    final enabled = settings.enableNekokoStats;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceSubtle(context)),
      ),
      child: Column(
        children: [
          _buildSwitchRow(
            context,
            title: "估算档案容量",
            subtitle: "预测已安装档案的存储占用",
            value: settings.estimateProfileSize,
            onChanged: (v) => settings.setEstimateProfileSize(v),
            isDisabled: !enabled,
          ),
          const Divider(),
          _buildClearCacheButton(context, enabled),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isDisabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.onSurfaceSubtle(context),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isDisabled ? false : value,
              onChanged: isDisabled ? null : onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearCacheButton(BuildContext context, bool enabled) {
    return InkWell(
      onTap: enabled ? () => _clearIconCache(context) : null,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "清除图标缓存",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Remove all cached operator icons",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceSubtle(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.delete_outline,
                color: enabled
                    ? Theme.of(context).colorScheme.error
                    : AppTheme.onSurfaceSubtle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _clearIconCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Icon Cache'),
        content: const Text(
          'This will remove all cached operator icons. They will be re-downloaded when needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await DatabaseService().clearOperatorIcons();
        OperatorIconService().clearMemoryCache();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('图标缓存已清除'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('清除缓存失败：$e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildInfoBox(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.analytics_outlined,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

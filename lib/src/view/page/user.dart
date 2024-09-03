import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pocketbase/pocketbase.dart';

final class UserPage extends StatefulWidget {
  const UserPage({super.key});

  static const route = AppRouteNoArg(page: UserPage.new, path: '/user');

  @override
  State<UserPage> createState() => _UserPageState();
}

final class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.user),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Pbs.user.listenVal(
      (user) {
        if (user == null) return _buildLogin();
        return _buildUserInfo(user);
      },
    );
  }

  Widget _buildLogin() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: double.infinity),
        Text(
          l10n.loginTip,
          textAlign: TextAlign.center,
        ).paddingSymmetric(horizontal: 13),
        UIs.height77,
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await context.showLoadingDialog(
                  timeout: const Duration(minutes: 2),
                  fn: Pbs.login,
                );
              },
              child: const Icon(MingCute.github_line),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserInfo(RecordModel user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: double.infinity),
        const PbUserAvatar(),
        UIs.height13,
        Text(
          user.getStringValue('username'),
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),
        UIs.height77,
        Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _onLogout,
              child: const Icon(Icons.logout),
            ),
            ElevatedButton(
              onPressed: _onRename,
              child: const Icon(BoxIcons.bx_rename),
            ),
            ElevatedButton(
              onPressed: _onDelete,
              child: const Icon(Icons.delete),
            ),
          ].joinWith(UIs.width13),
        ),
      ],
    );
  }

  Future<void> _onLogout() async {
    final sure = await context.showRoundDialog(
      title: l10n.logout,
      actions: Btnx.oks,
    );
    if (sure != true) return;
    Pbs.logout();
  }

  void _onRename() async {
    final ctrl = TextEditingController();
    void onOk() async {
      final name = ctrl.text;
      if (name.isEmpty) return;
      await Pbs.userRename(name);
    }

    await context.showRoundDialog(
      title: l10n.rename,
      child: Input(
        controller: ctrl,
        label: l10n.name,
        icon: BoxIcons.bx_rename,
        onSubmitted: (p0) => onOk(),
      ),
      actions: Btn.ok(onTap: onOk).toList,
    );
  }

  void _onDelete() async {
    final sure = await context.showRoundDialog(
      title: l10n.delete,
      child: Text(l10n.delFmt(l10n.user, Pbs.userName ?? '???')),
      actions: [
        CountDownBtn(
          onTap: () => context.pop(true),
          text: l10n.ok,
          afterColor: Colors.red,
        ),
      ],
    );
    if (sure != true) return;

    await _onLogout();
  }

  void _onImageRet(ImagePageRet ret) async {
    if (ret.isDeleted) {
      await context.showLoadingDialog(fn: () async {
        await Pbs.userCol.update(pb.authStore.model.id, body: {
          'avatar': null,
        });
        await Pbs.userCol.authRefresh();
      });
    }
  }
}

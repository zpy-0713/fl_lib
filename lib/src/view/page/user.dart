import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/model/user.dart';
import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

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
    return Apis.user.listenVal(
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
                  fn: Apis.login,
                );
              },
              child: const Icon(MingCute.github_line),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserInfo(User user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: double.infinity),
        PbUserAvatar(onRet: _onImageRet),
        UIs.height13,
        Text(
          user.name,
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
    Apis.logout(_onAnonyUserLogout);
  }

  Future<bool> _onAnonyUserLogout() async {
    final sure = await context.showRoundDialog(
      title: l10n.attention,
      child: Text(l10n.anonLoseDataTip),
      actions: Btnx.oks,
    );
    return sure == true;
  }

  void _onRename() async {
    final ctrl = TextEditingController(text: Apis.user.value?.name);
    void onOk() async {
      context.pop();
      final name = ctrl.text;
      if (name.isEmpty) return;
      await context.showLoadingDialog(fn: () => Apis.userEdit(name: name));
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
      child: Text(l10n.delFmt(l10n.user, Apis.user.value?.name ?? '???')),
      actions: [
        CountDownBtn(
          onTap: () => context.pop(true),
          text: l10n.ok,
          afterColor: Colors.red,
        ),
      ],
    );
    if (sure != true) return;

    Apis.logout(_onAnonyUserLogout);
  }

  void _onImageRet(ImagePageRet ret) async {
    if (ret.isDeleted) {
      await context.showLoadingDialog(fn: () async {
        await Apis.userEdit(avatar: '');
      });
    }
  }
}

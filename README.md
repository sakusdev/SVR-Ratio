# SVR-Ratio / RatioSlime

SlimeVR Server のAndroid版へ、アバター体型に合わせた腰・膝・足の比率補正を追加する実験プロジェクトです。

このリポジトリはSlimeVR Server全体を複製せず、公式ソースを固定コミットから取得して `patches/ratioslime.patch` を適用します。

- Upstream: `SlimeVR/SlimeVR-Server`
- 固定コミット: `d7205bb2940de9c3c75921db19f5b9bc2b0bd9d9`
- Android applicationId: `dev.sakus.ratioslime.android`

## 追加機能

- 脚長倍率と歩幅倍率
- 左右脚の個別倍率
- 腰の高さ・左右・前後オフセット
- 床高オフセット
- 位置・回転スムージング
- Android内の設定画面とプリセット
- 公式SlimeVR APKとの共存

## GitHub ActionsでAPKを作る

1. GitHubの **Actions** を開く
2. **Build RatioSlime APK** を選ぶ
3. **Run workflow** を実行する
4. 完了後、Artifactsの **RatioSlime-APK** を取得する

`main`へビルド関連ファイルをpushした場合も自動実行されます。

## Ubuntuでコマンドだけでビルドする

必要なもの:

- Git
- JDK 17
- Node.js 22.17.0
- Corepack / pnpm
- Android SDK Platform 36
- Android Build Tools 35.0.0

```bash
chmod +x build.sh
./build.sh
```

完成APK:

```text
dist/RatioSlime-debug.apk
```

作業ディレクトリを変更する場合:

```bash
WORK_DIR=/tmp/ratioslime-build ./build.sh
```

## 注意

- 現段階は実機トラッカーで調整前の試作版です。
- Full Body Ratio VRのコードや素材は使用していません。
- SlimeVRの商標・ライセンスには従ってください。
- このプロジェクトはSlimeVR公式プロジェクトではありません。

# SVR-Ratio / RatioSlime

SlimeVR Server のAndroid版へ、アバター体型に合わせた腰・膝・足の比率補正を追加する実験プロジェクトです。

このリポジトリはSlimeVR Server全体を複製せず、公式ソースを固定コミットから取得して、段階的なパッチを適用してビルドします。

- Upstream: `SlimeVR/SlimeVR-Server`
- 固定コミット: `d7205bb2940de9c3c75921db19f5b9bc2b0bd9d9`
- Android applicationId: `dev.sakus.ratioslime.android`

## 追加機能

- 脚長倍率と歩幅倍率
- 左右脚の個別倍率
- 腰の高さ・左右・前後オフセット
- 床高オフセット
- 位置・回転スムージング
- 体型プリセット
- 6秒間のガイド付き自動比率調整
- 短め・自然・脚長の目標脚比率
- 床高、左右差、スムージングの自動推定
- 自動測定の信頼度表示
- 自動調整前の設定へ戻すUndo
- 設定変更時の約0.35秒スムーズ切替
- 公式SlimeVR APKとの共存

## 設定を開く

画面左下に浮いていた専用ボタンは廃止しました。

Android版RatioSlimeでは次の場所から開けます。

```text
設定 → ユーティリティ → RatioSlime 比率補正
```

## 自動比率調整

1. トラッカーを装着して接続する
2. `設定 → ユーティリティ → RatioSlime 比率補正` を開く
3. 目標脚比率を選ぶ
   - 短め: 49%
   - 自然: 53%
   - 脚長: 58%
4. 自動測定を開始する
5. 最初は直立し、その後その場で軽く足踏みする
6. 約6秒後、推定結果と信頼度を確認して適用する

自動測定では、頭・腰・左右足の位置変化から次を推定します。

- 脚長倍率
- 歩幅倍率
- 左右脚の差
- 床高オフセット
- 推奨スムージング

VRChat側のアバター骨格を直接取得する機能ではありません。そのため、アバターに合わせたい脚の長さを「短め・自然・脚長」またはスライダーで指定し、トラッカーの実測値をその目標へ合わせます。

結果が不自然な場合は、設定画面の **自動調整前の設定に戻す** で直前の設定へ戻せます。

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

- 自動推定の精度は、トラッカー配置、接続数、姿勢、床の安定性に依存します。
- 現段階は実機トラッカーで幅広く検証する前の実験版です。
- Full Body Ratio VRのコードや素材は使用していません。
- SlimeVRの商標・ライセンスには従ってください。
- このプロジェクトはSlimeVR公式プロジェクトではありません。

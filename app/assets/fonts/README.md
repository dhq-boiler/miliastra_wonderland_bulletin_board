# フォントファイル（移動済み）

**注意**: フォントファイルは `public/fonts/` に移動されました。

## 移動理由

大きなフォントファイル（各57MB）をアセットパイプライン経由で処理すると、以下の問題が発生します：

- `rails assets:precompile` が非常に重くなる
- メモリ消費が大幅に増加
- ビルド時間が長くなる
- 本番環境でのデプロイが遅くなる、または固まる可能性

## 新しい配置場所

フォントファイルは以下のディレクトリに配置されています：

```
public/fonts/
├── NotoSerifCJKsc-VF.ttf  (57MB)
├── NotoSerifCJKtc-VF.ttf  (57MB)
└── README.md
```

## CSS での参照

`application.tailwind.css` では `/fonts/` パスで参照されています：

```css
src: url('/fonts/NotoSerifCJKsc-VF.ttf') format('truetype');
src: url('/fonts/NotoSerifCJKtc-VF.ttf') format('truetype');
```

## このディレクトリの用途

このディレクトリ (`app/assets/fonts/`) は、**小さなアイコンフォントやカスタムフォント**など、アセットパイプライン経由で管理したいフォントファイルの配置場所として使用できます。

大きなWebフォント（Noto CJK など）は `public/fonts/` に配置することを推奨します。

## 詳細

詳しくは `public/fonts/README.md` を参照してください。

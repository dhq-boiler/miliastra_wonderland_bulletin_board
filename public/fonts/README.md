# フォントファイル

このディレクトリには、中国語表示用のWebフォントファイルが配置されています。

## 重要：アセットパイプラインを使用しない

これらのフォントファイルは **アセットパイプラインを経由せず、直接 `public/fonts/` から配信** されます。

### 理由

- 各フォントファイルが57MBと非常に大きい
- アセットプリコンパイル時のメモリ消費とビルド時間を削減
- 本番環境での `rails assets:precompile` の負荷を軽減

## 配置済みフォント

### Noto Serif CJK (中国語) - Variable Font

- **NotoSerifCJKsc-VF.ttf** (57MB) - 簡体字中国語（Simplified Chinese）用
- **NotoSerifCJKtc-VF.ttf** (57MB) - 繁体字中国語（Traditional Chinese）用

これらは **Variable Font（可変フォント）** で、font-weight 200〜900 の範囲で太さを自由に調整できます。

## CSS での参照

`application.tailwind.css` で以下のように設定されています：

```css
@font-face {
  font-family: 'Noto Serif CJK SC';
  font-style: normal;
  font-weight: 200 900;
  font-display: swap;
  src: url('/fonts/NotoSerifCJKsc-VF.ttf') format('truetype');
}

@font-face {
  font-family: 'Noto Serif CJK TC';
  font-style: normal;
  font-weight: 200 900;
  font-display: swap;
  src: url('/fonts/NotoSerifCJKtc-VF.ttf') format('truetype');
}
```

**パス**: `/fonts/` を使用（`/assets/` ではなく）

## デプロイ時の注意

- `public/fonts/*.ttf` ファイルをGitで管理する
- アセットプリコンパイルは不要（フォントファイルは静的に配信される）
- Nginxやロードバランサーで適切なキャッシュヘッダーを設定することを推奨

## パフォーマンス最適化（オプション）

ファイルサイズが大きいため、以下の最適化を検討してください：

1. **CDN経由で配信**
2. **フォントサブセット化** - 必要な文字だけを含める
3. **Brotli/Gzip圧縮** - Webサーバー側で圧縮を有効化
4. **HTTP/2プッシュ** - フォントファイルを先読み

## フォントの特徴

- **フォントタイプ**: Serif（明朝体）
- **ライセンス**: SIL Open Font License 1.1
- **提供元**: Google Fonts / Noto Fonts
- **対応文字**: CJK（中国語、日本語、韓国語）統合漢字
- **Variable Font**: font-weight 200〜900 まで滑らかに対応

## 参考リンク

- [Noto Serif CJK - Google Fonts](https://fonts.google.com/noto/specimen/Noto+Serif+SC)
- [Noto CJK - GitHub](https://github.com/notofonts/noto-cjk)
- [Variable Fonts について](https://developer.mozilla.org/ja/docs/Web/CSS/CSS_Fonts/Variable_Fonts_Guide)

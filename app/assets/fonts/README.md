# フォントファイル

このディレクトリには、中国語表示用のWebフォントファイルが配置されています。

## 配置済みフォント

### Noto Serif CJK (中国語) - Variable Font

- **NotoSerifCJKsc-VF.ttf** (57MB) - 簡体字中国語（Simplified Chinese）用
- **NotoSerifCJKtc-VF.ttf** (57MB) - 繁体字中国語（Traditional Chinese）用

これらは **Variable Font（可変フォント）** で、font-weight 200〜900 の範囲で太さを自由に調整できます。

## フォントの特徴

- **フォントタイプ**: Serif（明朝体）
- **ライセンス**: SIL Open Font License 1.1
- **提供元**: Google Fonts / Noto Fonts
- **対応文字**: CJK（中国語、日本語、韓国語）統合漢字

## 現在の設定

`application.tailwind.css` で以下のように設定されています：

```css
/* Noto Serif CJK SC (Simplified Chinese) - Variable Font */
@font-face {
  font-family: 'Noto Serif CJK SC';
  font-style: normal;
  font-weight: 200 900;
  font-display: swap;
  src: url('/assets/NotoSerifCJKsc-VF.ttf') format('truetype');
}

/* Noto Serif CJK TC (Traditional Chinese) - Variable Font */
@font-face {
  font-family: 'Noto Serif CJK TC';
  font-style: normal;
  font-weight: 200 900;
  font-display: swap;
  src: url('/assets/NotoSerifCJKtc-VF.ttf') format('truetype');
}
```

## フォント優先順位

フォントファミリーの優先順位（`--font-sans`）：

1. システムフォント（-apple-system, BlinkMacSystemFont, etc.）
2. 欧米フォント（Segoe UI, Roboto, Helvetica Neue, Arial, Noto Sans）
3. 日本語フォント（Hiragino Sans, Hiragino Kaku Gothic ProN, Yu Gothic, Meiryo）
4. **Noto Serif CJK SC** ← 簡体字中国語
5. **Noto Serif CJK TC** ← 繁体字中国語
6. その他の中国語システムフォント（Microsoft YaHei, PingFang SC/TC, etc.）
7. 韓国語フォント（Malgun Gothic, Apple SD Gothic Neo, Noto Sans KR）
8. 絵文字フォント

## 注意事項

- フォントファイルは各57MBと大きいため、初回読み込み時にダウンロード時間がかかります
- `font-display: swap` により、フォント読み込み前はシステムフォントで表示されます
- 本番環境では、CDNの使用やサブセット化も検討してください
- Variable Fontのため、細字（200）から極太（900）まで滑らかに対応可能です

## 参考リンク

- [Noto Serif CJK - Google Fonts](https://fonts.google.com/noto/specimen/Noto+Serif+SC)
- [Noto CJK - GitHub](https://github.com/notofonts/noto-cjk)
- [Variable Fonts について](https://developer.mozilla.org/ja/docs/Web/CSS/CSS_Fonts/Variable_Fonts_Guide)

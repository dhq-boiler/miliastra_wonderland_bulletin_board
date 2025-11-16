import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "form", "category", "details", "attachmentId"]

  connect() {
    // モーダルの初期状態は非表示
  }

  openModal(event) {
    event.preventDefault()
    const attachmentId = event.currentTarget.dataset.attachmentId
    this.attachmentIdTarget.value = attachmentId
    this.modalTarget.classList.add("active")
    document.body.style.overflow = "hidden"
  }

  closeModal() {
    this.modalTarget.classList.remove("active")
    document.body.style.overflow = ""
    this.formTarget.reset()
  }

  selectCategory(event) {
    // すべてのカテゴリボタンから選択状態を解除
    this.categoryTargets.forEach(btn => btn.classList.remove("selected"))

    // クリックされたボタンを選択状態にする
    event.currentTarget.classList.add("selected")

    // 選択されたカテゴリの値を取得
    const category = event.currentTarget.dataset.category
    const categoryText = event.currentTarget.textContent.trim()

    // 詳細欄に自動入力（ユーザーは追加で詳細を書ける）
    if (category !== "other") {
      this.detailsTarget.value = categoryText
    } else {
      this.detailsTarget.value = ""
      this.detailsTarget.focus()
    }
  }

  submitReport(event) {
    event.preventDefault()

    // 選択されたカテゴリを確認
    const selectedCategory = this.categoryTargets.find(btn => btn.classList.contains("selected"))
    if (!selectedCategory) {
      alert("通報理由を選択してください")
      return
    }

    // 詳細が入力されているか確認
    if (!this.detailsTarget.value.trim()) {
      alert("詳細を入力してください")
      return
    }

    // フォームを送信
    this.formTarget.submit()
  }

  // ESCキーでモーダルを閉じる
  handleKeydown(event) {
    if (event.key === "Escape" && this.modalTarget.classList.contains("active")) {
      this.closeModal()
    }
  }
}

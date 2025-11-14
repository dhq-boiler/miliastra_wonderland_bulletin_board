import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["popover", "summary", "checkbox"]

  connect() {
    this.updateSummary()
  }

  // Popover APIが開閉を処理するので、open/closeメソッドは不要
  // ただし、summaryの更新は必要

  toggleCheckbox(event) {
    // チェックボックスの変更を検知してサマリーを更新
    setTimeout(() => this.updateSummary(), 10)
  }

  updateSummary() {
    const selectedTags = []

    this.checkboxTargets.forEach(checkbox => {
      if (checkbox.checked) {
        const label = checkbox.nextElementSibling
        if (label) {
          selectedTags.push(label.textContent.trim())
        }
      }
    })

    if (this.hasSummaryTarget) {
      if (selectedTags.length === 0) {
        this.summaryTarget.classList.add("empty")
        this.summaryTarget.textContent = this.summaryTarget.dataset.emptyText || "タグが選択されていません"
      } else {
        this.summaryTarget.classList.remove("empty")
        this.summaryTarget.innerHTML = selectedTags
          .map(tag => `<span class="tag-summary-badge">${tag}</span>`)
          .join("")
      }
    }
  }

  clearAll(event) {
    event.preventDefault()
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = false
    })
    this.updateSummary()
  }

  apply(event) {
    event.preventDefault()
    this.updateSummary()
    // Popover APIのhidePopover()メソッドを使用
    if (this.hasPopoverTarget) {
      this.popoverTarget.hidePopover()
    }
  }
}

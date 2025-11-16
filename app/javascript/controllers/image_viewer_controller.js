import { Controller } from "@hotwired/stimulus"

// 画像拡大表示コントローラー
export default class extends Controller {
  static targets = ["modal", "image"]

  connect() {
    // モーダル要素を作成
    this.createModal()
  }

  createModal() {
    // モーダルが既に存在する場合は作成しない
    if (document.getElementById("image-viewer-modal")) {
      this.modal = document.getElementById("image-viewer-modal")
      this.modalImage = this.modal.querySelector(".modal-image")
      return
    }

    // モーダル要素を作成
    const modal = document.createElement("div")
    modal.id = "image-viewer-modal"
    modal.className = "image-viewer-modal"
    modal.innerHTML = `
      <div class="modal-backdrop"></div>
      <div class="modal-content">
        <button class="modal-close" aria-label="閉じる">×</button>
        <img src="" alt="" class="modal-image">
      </div>
    `

    document.body.appendChild(modal)
    this.modal = modal
    this.modalImage = modal.querySelector(".modal-image")

    // モーダルを閉じるイベント
    const closeButton = modal.querySelector(".modal-close")
    const backdrop = modal.querySelector(".modal-backdrop")

    closeButton.addEventListener("click", () => this.closeModal())
    backdrop.addEventListener("click", () => this.closeModal())

    // Escapeキーで閉じる
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape" && modal.classList.contains("active")) {
        this.closeModal()
      }
    })
  }

  openModal(event) {
    event.preventDefault()
    const imgSrc = event.currentTarget.src
    const imgAlt = event.currentTarget.alt

    this.modalImage.src = imgSrc
    this.modalImage.alt = imgAlt
    this.modal.classList.add("active")
    document.body.style.overflow = "hidden"
  }

  closeModal() {
    this.modal.classList.remove("active")
    document.body.style.overflow = ""
  }
}

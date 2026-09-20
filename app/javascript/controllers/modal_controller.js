import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "content"]

  connect() {
    this.boundKeydown = this.handleKeydown.bind(this)
  }

  open(event) {
    if (event) event.preventDefault()
    this.dialogTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    window.addEventListener("keydown", this.boundKeydown)
  }

  close(event) {
    if (event) event.preventDefault()
    this.dialogTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
    window.removeEventListener("keydown", this.boundKeydown)
  }

  backdropClick(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  disconnect() {
    window.removeEventListener("keydown", this.boundKeydown)
    document.body.classList.remove("overflow-hidden")
  }
}

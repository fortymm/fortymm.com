import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-menu"
export default class extends Controller {
  static targets = [ "mobileMenu", "showMobileMenuIcon", "hideMobileMenuIcon" ]

  connect() {
    this.hideMenu();
  }

  get isHidden() {
    return this.mobileMenuTarget.classList.contains("hidden")
  }

  toggle() {
    this.isHidden ? this.showMenu() : this.hideMenu();
  }

  showMenu() {
    this.hideMobileMenuIconTarget.classList.remove("hidden")
    this.hideMobileMenuIconTarget.classList.add("block")
    this.showMobileMenuIconTarget.classList.add("hidden")
    this.showMobileMenuIconTarget.classList.remove("block")

    this.mobileMenuTarget.classList.remove("hidden")
  }

  hideMenu() {
    this.hideMobileMenuIconTarget.classList.remove("block")
    this.hideMobileMenuIconTarget.classList.add("hidden")
    this.showMobileMenuIconTarget.classList.add("block")
    this.showMobileMenuIconTarget.classList.remove("hidden")

    this.mobileMenuTarget.classList.add("hidden")
  }
}

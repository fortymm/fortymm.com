import { Controller } from "@hotwired/stimulus"

const fadeInClasses = ["transition", "ease-out", "duration-200", "transform", "opacity-100", "scale-100"]
const fadeOutClasses = ["transition", "ease-in", "duration-75", "transform", "opacity-0", "scale-95"]

export default class extends Controller {
  static targets = [ "profileDropdown" ]

  connect() {
    this.profileDropdownTarget.classList.add(...fadeOutClasses)
  }

  get isHidden() {
    return this.profileDropdownTarget.classList.contains("hidden")
  }

  toggle() {
    this.isHidden ? this.showMenu() : this.hideMenu();
  }

  hide(event) {
    const eventComesFromMenu = this.profileDropdownTarget.contains(event.target)
    !eventComesFromMenu && this.hideMenu();
  }

  showMenu() {
    this.profileDropdownTarget.classList.remove("hidden")

    window.requestAnimationFrame(() => {
        this.profileDropdownTarget.classList.remove(...fadeOutClasses)
        this.profileDropdownTarget.classList.add(...fadeInClasses)
    });
  }

  hideMenu() {
    this.profileDropdownTarget.addEventListener("transitionend", () => this.profileDropdownTarget.classList.add("hidden"), { once: true });
    this.profileDropdownTarget.classList.remove(...fadeInClasses)
    this.profileDropdownTarget.classList.add(...fadeOutClasses)
  }

}

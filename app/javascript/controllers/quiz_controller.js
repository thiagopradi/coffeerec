import { Controller } from "@hotwired/stimulus"

// Quiz Controller
// Handles multi-step quiz navigation, option selection, and form submission
export default class extends Controller {
  static targets = [
    "step",
    "progressBar",
    "stepNumber",
    "form",
    "chocolateInput",
    "fruitInput",
    "drinkInput",
    "textureInput",
    "adventureInput",
    "brewingInput",
    "grinderInput"
  ]

  connect() {
    this.currentStep = 1
    this.totalSteps = this.stepTargets.length
    this.updateProgress()
  }

  // Handle option selection - advance to next step
  selectOption(event) {
    const button = event.currentTarget
    const value = button.dataset.value
    const inputName = button.dataset.input

    // Update the hidden input value
    const input = this[`${inputName}Target`]
    if (input) {
      input.value = value
    }

    // Visual feedback - mark as selected
    this.markSelected(button)

    // Advance to next step after a brief delay
    setTimeout(() => {
      this.nextStep()
    }, 300)
  }

  // Handle final option selection and form submission
  selectOptionAndSubmit(event) {
    const button = event.currentTarget
    const value = button.dataset.value
    const inputName = button.dataset.input

    // Update the hidden input value
    const input = this[`${inputName}Target`]
    if (input) {
      input.value = value
    }

    // Visual feedback
    this.markSelected(button)

    // Submit the form after a brief delay
    setTimeout(() => {
      this.formTarget.requestSubmit()
    }, 300)
  }

  // Mark a button as selected and unmark siblings
  markSelected(button) {
    // Remove selected class from all siblings
    const parent = button.closest('.quiz-step')
    parent.querySelectorAll('.quiz-card').forEach(card => {
      card.classList.remove('selected')
    })

    // Add selected class to clicked button
    button.classList.add('selected')
  }

  // Navigate to next step
  nextStep() {
    if (this.currentStep < this.totalSteps) {
      // Hide current step
      this.stepTargets[this.currentStep - 1].classList.add('hidden')

      // Show next step
      this.currentStep++
      this.stepTargets[this.currentStep - 1].classList.remove('hidden')

      // Update progress
      this.updateProgress()

      // Scroll to top of quiz
      window.scrollTo({ top: 0, behavior: 'smooth' })
    }
  }

  // Navigate to previous step
  previousStep() {
    if (this.currentStep > 1) {
      // Hide current step
      this.stepTargets[this.currentStep - 1].classList.add('hidden')

      // Show previous step
      this.currentStep--
      this.stepTargets[this.currentStep - 1].classList.remove('hidden')

      // Update progress
      this.updateProgress()
    }
  }

  // Update progress bar and step number
  updateProgress() {
    const progress = (this.currentStep / this.totalSteps) * 100

    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${progress}%`
    }

    if (this.hasStepNumberTarget) {
      this.stepNumberTarget.textContent = this.currentStep
    }
  }
}

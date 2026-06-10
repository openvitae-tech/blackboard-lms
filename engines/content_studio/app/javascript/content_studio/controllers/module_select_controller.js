import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'normalHeader', 'selectHeader', 'selectAll',
    'selectLink', 'cancelBtn',
    'grip', 'lessonCheckbox',
    'deleteBar', 'modalTrigger'
  ]

  static values = {
    allScenesReady: Boolean,
    alertModalUrl: String,
    deleteModulePath: String,
    bulkDeleteLessonsPath: String,
    confirmModuleTitle: String,
    confirmModuleDescription: String,
    confirmLessonsTitle: String,
    confirmLessonsDescription: String
  }

  connect() {
    this._onCollapsibleChanged = () => this._updateSelectLinkVisibility()
    this.element.addEventListener('collapsible:changed', this._onCollapsibleChanged)
    this._updateSelectLinkVisibility()
  }

  disconnect() {
    this.element.removeEventListener('collapsible:changed', this._onCollapsibleChanged)
  }

  enterSelectMode(event) {
    event.preventDefault()
    this.selectLinkTarget.classList.add('hidden')
    this.normalHeaderTarget.classList.add('hidden')
    this.selectHeaderTarget.classList.remove('hidden')
    this.cancelBtnTarget.classList.remove('hidden')
    this.lessonCheckboxTargets.forEach(cb => cb.classList.remove('hidden'))
    this.gripTargets.forEach(g => g.classList.add('hidden'))
    this.element.classList.remove('border-line-colour-light')
    this.element.classList.add('border-primary-light')
  }

  exitSelectMode() {
    this.normalHeaderTarget.classList.remove('hidden')
    this.selectHeaderTarget.classList.add('hidden')
    this.cancelBtnTarget.classList.add('hidden')
    this.lessonCheckboxTargets.forEach(cb => {
      cb.classList.add('hidden')
      cb.checked = false
    })
    this.gripTargets.forEach(g => g.classList.remove('hidden'))
    this.selectAllTarget.checked = false
    this.selectAllTarget.indeterminate = false
    this.deleteBarTarget.classList.add('hidden')
    this.element.classList.remove('border-primary-light')
    this.element.classList.add('border-line-colour-light')
    this._updateSelectLinkVisibility()
  }

  toggleAll(event) {
    const checked = event.target.checked
    this.lessonCheckboxTargets.forEach(cb => { cb.checked = checked })
    this._refreshDeleteBar()
  }

  updateDeleteButton() {
    this._refreshDeleteBar()
    const total = this.lessonCheckboxTargets.length
    const selected = this.lessonCheckboxTargets.filter(cb => cb.checked).length
    this.selectAllTarget.indeterminate = selected > 0 && selected < total
    this.selectAllTarget.checked = total > 0 && selected === total
  }

  deleteSelected() {
    const selected = this.lessonCheckboxTargets.filter(cb => cb.checked)
    const deleteAll = selected.length === this.lessonCheckboxTargets.length

    let actionPath, title, description
    if (deleteAll) {
      actionPath = this.deleteModulePathValue
      title = this.confirmModuleTitleValue
      description = this.confirmModuleDescriptionValue
    } else {
      const params = selected.map(cb => `lesson_ids[]=${encodeURIComponent(cb.dataset.lessonId)}`).join('&')
      actionPath = `${this.bulkDeleteLessonsPathValue}?${params}`
      title = this.confirmLessonsTitleValue
      description = this.confirmLessonsDescriptionValue
    }

    const modalParams = new URLSearchParams({
      title,
      description,
      action_path: actionPath,
      method: 'delete',
      action_type: 'danger'
    })
    this.modalTriggerTarget.href = `${this.alertModalUrlValue}?${modalParams.toString()}`
    this.modalTriggerTarget.click()
  }

  _updateSelectLinkVisibility() {
    if (!this.hasSelectLinkTarget) return
    const content = this.element.querySelector('[data-collapsible-target="content"]')
    const isOpen = content && !content.classList.contains('hidden')
    const inSelectMode = this.hasNormalHeaderTarget && this.normalHeaderTarget.classList.contains('hidden')
    this.selectLinkTarget.classList.toggle('hidden', !isOpen || inSelectMode)
  }

  _refreshDeleteBar() {
    const anyChecked = this.lessonCheckboxTargets.some(cb => cb.checked)
    this.deleteBarTarget.classList.toggle('hidden', !anyChecked)
  }
}

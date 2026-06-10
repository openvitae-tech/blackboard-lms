import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'normalHeader', 'selectHeader', 'selectAll',
    'selectLink', 'cancelBtn',
    'grip', 'lessonCheckbox', 'lessonRow',
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
    this._inSelectMode = false
    this._dragSrc = null
    this._dropTarget = null
    this._dropHalf = null
  }

  disconnect() {
    this.element.removeEventListener('collapsible:changed', this._onCollapsibleChanged)
  }

  enterSelectMode(event) {
    event.preventDefault()
    this._inSelectMode = true
    this.lessonRowTargets.forEach(row => { row.draggable = false })
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
    this._inSelectMode = false
    this.lessonRowTargets.forEach(row => { row.draggable = true })
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

  dragStart(event) {
    this._dragSrc = event.currentTarget
    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('text/plain', '')
    window.dispatchEvent(new CustomEvent('module-select:drag-start'))
    requestAnimationFrame(() => {
      if (this._dragSrc) this._dragSrc.classList.add('opacity-50')
    })
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'
    const row = event.currentTarget
    if (row === this._dragSrc) return
    const rect = row.getBoundingClientRect()
    const half = event.clientY < rect.top + rect.height / 2 ? 'top' : 'bottom'
    if (this._dropTarget !== row || this._dropHalf !== half) {
      this._clearDropIndicators()
      this._dropTarget = row
      this._dropHalf = half
      row.classList.add(half === 'top' ? 'border-t-2' : 'border-b-2', 'border-primary')
    }
  }

  dragLeave(event) {
    const row = event.currentTarget
    if (!row.contains(event.relatedTarget)) {
      row.classList.remove('border-t-2', 'border-b-2', 'border-primary')
      if (this._dropTarget === row) {
        this._dropTarget = null
        this._dropHalf = null
      }
    }
  }

  drop(event) {
    event.preventDefault()
    const target = event.currentTarget
    target.classList.remove('border-t-2', 'border-b-2', 'border-primary')
    if (!this._dragSrc || target === this._dragSrc) return
    const rect = target.getBoundingClientRect()
    const dropBefore = event.clientY < rect.top + rect.height / 2
    if (dropBefore) {
      target.parentElement.insertBefore(this._dragSrc, target)
    } else {
      target.after(this._dragSrc)
    }
    const newPosition = this.lessonRowTargets.indexOf(this._dragSrc)
    const reorderPath = this._dragSrc.dataset.reorderPath
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || ''
    fetch(reorderPath, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken },
      body: JSON.stringify({ new_position: newPosition })
    }).then(response => {
      if (!response.ok) window.location.reload()
    })
  }

  dragEnd(event) {
    if (this._dragSrc) this._dragSrc.classList.remove('opacity-50')
    this._clearDropIndicators()
    this._dragSrc = null
    this._dropTarget = null
    this._dropHalf = null
    window.dispatchEvent(new CustomEvent('module-select:drag-end'))
  }

  _clearDropIndicators() {
    this.lessonRowTargets.forEach(row => {
      row.classList.remove('border-t-2', 'border-b-2', 'border-primary')
    })
  }

  _updateSelectLinkVisibility() {
    if (!this.hasSelectLinkTarget) return
    const content = this.element.querySelector('[data-collapsible-target="content"]')
    const isOpen = content && !content.classList.contains('hidden')
    const inSelectMode = this._inSelectMode
    this.selectLinkTarget.classList.toggle('hidden', !isOpen || inSelectMode)
  }

  _refreshDeleteBar() {
    const anyChecked = this.lessonCheckboxTargets.some(cb => cb.checked)
    this.deleteBarTarget.classList.toggle('hidden', !anyChecked)
  }
}

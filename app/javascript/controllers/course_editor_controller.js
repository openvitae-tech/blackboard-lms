import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "content", 
    "courseTemplate", 
    "moduleTemplate", 
    "lessonTemplate", 
    "quizTemplate",
    "assessmentTemplate",
    "moduleContainer",
    "assessmentContainer",
    "summaryTemplate",
    "jsonOutput",
    "courseTitle"
  ]

  connect() {
    this.moduleCounter = 0
    this.assessmentCounter = 0
    this.summaryCounter = 0
    this.lessonCounter = 0
    this.quizCounter = 0
  
    try {
      const raw = this.jsonOutputTarget?.value?.trim()
      this.courseData = raw
        ? JSON.parse(raw)
        : { title: "", modules: [], assessment: {}, summary: {} }
    } catch (e) {
      console.error("Invalid initial JSON, using empty course.", e)
      this.courseData = { title: "", modules: [], assessment: {}, summary: {} }
    }
  
    this.renderUIFromJSON()
  }
  

  showTemplate() {
    const templateTarget = `courseTemplateTarget`
    
    if (this[templateTarget]) {
      const template = this[templateTarget]
      const clone = template.content.cloneNode(true)
      this.contentTarget.innerHTML = ""
      this.contentTarget.appendChild(clone)
      
      const titleInput = this.contentTarget.querySelector('[data-course-editor-target="courseTitle"]')
      if (titleInput) titleInput.focus()
      this.updateAvailability()
      // this.updateJSON()
    } else {
      alert(`Template for ${tool} not found`)
    }
  }

  renderUIFromJSON() {
    this.showTemplate()
  
    const moduleContainer = this.contentTarget.querySelector('[data-course-editor-target="moduleContainer"]')
    if (moduleContainer) moduleContainer.innerHTML = ''
  
    const assessmentContainer = this.contentTarget.querySelector('[data-course-editor-target="assessmentContainer"]')
    if (assessmentContainer) assessmentContainer.innerHTML = ''

     const summaryContainer = this.contentTarget.querySelector('[data-course-editor-target="summaryContainer"]')
    if (summaryContainer) summaryContainer.innerHTML = ''
  
    const titleInput = this.contentTarget.querySelector('[data-course-editor-target="courseTitle"]')
    if (titleInput) titleInput.value = this.courseData.title || ""
  
    this.courseData.modules.forEach(moduleData => this.addModuleFromData(moduleData))
  
    if (this.courseData.assessment && Object.keys(this.courseData.assessment).length > 0) {
      this.addAssessmentFromData(this.courseData.assessment)
    }
  
    if (this.courseData.summary && Object.keys(this.courseData.summary).length > 0) {
      this.addSummaryFromData(this.courseData.summary)
    }  

  
    this.updateJSON()
    this.updateAvailability()
  }
  

  addModuleFromData(moduleData) {
    const moduleContainer = this.contentTarget.querySelector('[data-course-editor-target="moduleContainer"]')
    if (!moduleContainer) return
    
    const template = this.moduleTemplateTarget
    const clone = template.content.cloneNode(true)
    const moduleDiv = clone.querySelector('[data-module-id]')
    moduleDiv.dataset.moduleId = moduleData.id
    
    const titleInput = moduleDiv.querySelector('[data-target="moduleTitle"]')
    if (titleInput && moduleData.title) {
      titleInput.value = moduleData.title
    }
    
    moduleContainer.appendChild(clone)
    
    moduleData.lessons?.forEach(lessonData => {
      this.addLessonFromData(moduleDiv, lessonData)
    })
    
    moduleData.quizzes?.forEach(quizData => {
      this.addQuizFromData(moduleDiv, quizData)
    })
  }
  addAssessmentFromData(assessmentData) {
    const template = this.assessmentTemplateTarget
    const clone = template.content.cloneNode(true)
    const assessmentDiv = clone.querySelector('[data-assessment-id]')
    assessmentDiv.dataset.assessmentId = assessmentData.id || `assessment_1`
  
    const titleInput = assessmentDiv.querySelector('[data-target="assessmentTitle"]')
    const questionSelect = assessmentDiv.querySelector('[data-target="assessmentQuestion"]')
  
    if (titleInput && assessmentData.title) {
      titleInput.value = assessmentData.title
    }
    if (questionSelect && assessmentData.question) {
      questionSelect.value = assessmentData.question
    }
  
    const assessmentContainer = this.contentTarget.querySelector('[data-course-editor-target="assessmentContainer"]')
    if (assessmentContainer) {
      assessmentContainer.appendChild(clone)
    }
  }
  

  addSummaryFromData(summaryData) {
    const template = this.summaryTemplateTarget
    const clone = template.content.cloneNode(true)
    const summaryDiv = clone.querySelector('[data-summary-id]')
    summaryDiv.dataset.summaryId = summaryData.id || `summary_1`
  
    const noteSelect = summaryDiv.querySelector('[data-target="summaryNote"]')
  
    if (noteSelect && summaryData.note) {
      noteSelect.value = summaryData.note
    }
  
    const summaryContainer = this.contentTarget.querySelector('[data-course-editor-target="summaryContainer"]')
    if (summaryContainer) {
      summaryContainer.appendChild(clone)
    }
  }
  
  
  addLessonFromData(moduleDiv, lessonData) {
    const template = this.lessonTemplateTarget
    const clone = template.content.cloneNode(true)
    const lessonDiv = clone.querySelector('[data-lesson-id]')
    lessonDiv.dataset.lessonId = lessonData.id
    
    const titleInput = lessonDiv.querySelector('[data-target="lessonTitle"]')
    const videoSelect = lessonDiv.querySelector('[data-target="lessonVideo"]')
    
    if (titleInput && lessonData.title) {
      titleInput.value = lessonData.title
    }
    if (videoSelect && lessonData.video) {
      videoSelect.value = lessonData.video
    }
    
    moduleDiv.querySelector('[data-target="lessonContainer"]').appendChild(clone)
  }

  addQuizFromData(moduleDiv, quizData) {
    const template = this.quizTemplateTarget
    const clone = template.content.cloneNode(true)
    const quizDiv = clone.querySelector('[data-quiz-id]')
    quizDiv.dataset.quizId = quizData.id
    
    const questionSelect = quizDiv.querySelector('[data-target="quizQuestion"]')
    if (questionSelect && quizData.question) {
      questionSelect.value = quizData.question
    }
    
    moduleDiv.querySelector('[data-target="lessonContainer"]').appendChild(clone)
  }

  hasLessonAnywhere() {
    return this.courseData.modules.some(m => (m.lessons?.length || 0) > 0)
  }

  updateAvailability() {
    const hasLesson = this.hasLessonAnywhere()
    const assessBtn = this.contentTarget.querySelector('[data-course-editor-target="addAssessmentBtn"]')
    const summaryBtn = this.contentTarget.querySelector('[data-course-editor-target="addSummaryBtn"]')

    ;[assessBtn, summaryBtn].forEach(btn => {
      if (!btn) return
      if (hasLesson) {
        btn.removeAttribute("disabled")
        btn.classList.remove("opacity-50", "cursor-not-allowed")
      } else {
        btn.setAttribute("disabled", "disabled")
        btn.classList.add("opacity-50", "cursor-not-allowed")
      }
    })
  }

  addModule() {
    this.moduleCounter++
    const moduleId = `module_${this.moduleCounter}`

    if (!Array.isArray(this.courseData.modules)) {
      this.courseData.modules = []
    }
    
    this.courseData.modules.push({
      id: moduleId,
      title: "",
      lessons: [],
      quizzes: []
    })
    
    this.renderUIFromJSON()
  }
  addAssessment() {
    if (!this.courseData.assessment || typeof this.courseData.assessment !== "object") {
      this.courseData.assessment = {}
    }

    this.courseData.assessment = {
      id: "assessment_1",
      title: "",
      question: ""
    }
    this.renderUIFromJSON()
  }
  
  addSummary() {
    if (!this.courseData.summary || typeof this.courseData.summary !== "object") {
      this.courseData.summary = {}
    }

    this.courseData.summary = {
      id: "summary_1",
      note: ""
    }
    this.renderUIFromJSON()
  }
  
  addLesson(event) {
    const moduleDiv = event.target.closest('[data-module-id]')
    const moduleId = moduleDiv.dataset.moduleId
    
    this.lessonCounter++
    const lessonId = `lesson_${this.lessonCounter}`
    
    const module = this.courseData.modules.find(m => m.id === moduleId)

    if (!Array.isArray(module.lessons)) {
      module.lessons = []
    }

    if (module) {
      module.lessons.push({
        id: lessonId,
        title: "",
        video: ""
      })
    }
    
    this.renderUIFromJSON()
  }

  addQuiz(event) {
    const moduleDiv = event.target.closest('[data-module-id]')
    const moduleId = moduleDiv.dataset.moduleId
    const module = this.courseData.modules.find(m => m.id === moduleId)
    if (!module || module.lessons.length === 0) {
      alert("Add at least one lesson to this module before adding a quiz.")
      return
    }

    this.quizCounter++
    const quizId = `quiz_${this.quizCounter}`

    if (!Array.isArray(module.quizzes)) {
      module.quizzes = []
    }
    
    module.quizzes.push({
      id: quizId,
      question: ""
    })
    
    this.renderUIFromJSON()
  }

  removeModule(event) {
    const moduleDiv = event.target.closest('[data-module-id]')
    const moduleId = moduleDiv.dataset.moduleId
    
    this.courseData.modules = this.courseData.modules.filter(m => m.id !== moduleId)
    
    this.renderUIFromJSON()
  }

  removeAssessment(event) {
    this.courseData.assessment = {}
    this.renderUIFromJSON()
  }
  
  removeSummary(event) {
    this.courseData.summary = {}
    this.renderUIFromJSON()
  }
  

  removeLesson(event) {
    const lessonDiv = event.target.closest('[data-lesson-id]')
    const lessonId = lessonDiv.dataset.lessonId
    const moduleDiv = event.target.closest('[data-module-id]')
    const moduleId = moduleDiv.dataset.moduleId
    
    const module = this.courseData.modules.find(m => m.id === moduleId)
    if (module) {
      module.lessons = module.lessons.filter(l => l.id !== lessonId)
    }
    
    this.renderUIFromJSON()
  }

  removeQuiz(event) {
    const quizDiv = event.target.closest('[data-quiz-id]')
    const quizId = quizDiv.dataset.quizId
    const moduleDiv = event.target.closest('[data-module-id]')
    const moduleId = moduleDiv.dataset.moduleId
    
    const module = this.courseData.modules.find(m => m.id === moduleId)
    if (module) {
      module.quizzes = module.quizzes.filter(q => q.id !== quizId)
    }
    
    this.renderUIFromJSON()
  }

  saveCourse() {
    const titleInput = this.contentTarget.querySelector('[data-course-editor-target="courseTitle"]')
    if (titleInput) this.courseData.title = titleInput.value
    
    const moduleElements = this.element.querySelectorAll('[data-module-id]')
    moduleElements.forEach(moduleEl => {
      const moduleId = moduleEl.dataset.moduleId
      const module = this.courseData.modules.find(m => m.id === moduleId)
      if (!module) return

      const titleInput = moduleEl.querySelector('[data-target="moduleTitle"]')
      if (titleInput) module.title = titleInput.value
      
      const lessonElements = moduleEl.querySelectorAll('[data-lesson-id]')
      lessonElements.forEach(lessonEl => {
        const lessonId = lessonEl.dataset.lessonId
        const lesson = module.lessons.find(l => l.id === lessonId)
        if (!lesson) return
        const titleInput = lessonEl.querySelector('[data-target="lessonTitle"]')
        const videoSelect = lessonEl.querySelector('[data-target="lessonVideo"]')
        if (titleInput) lesson.title = titleInput.value
        if (videoSelect) lesson.video = videoSelect.value
      })

      const quizElements = moduleEl.querySelectorAll('[data-quiz-id]')
      quizElements.forEach(quizEl => {
        const quizId = quizEl.dataset.quizId
        const quiz = module.quizzes.find(q => q.id === quizId)
        if (!quiz) return
        const select = quizEl.querySelector('[data-target="quizQuestion"]')
        if (select) quiz.question = select.value
      })
    })
    const assessEl = this.element.querySelector('[data-assessment-id]')
    if (assessEl) {
      const titleInput = assessEl.querySelector('[data-target="assessmentTitle"]')
      const questionSelect = assessEl.querySelector('[data-target="assessmentQuestion"]')
  
      this.courseData.assessment.title = titleInput ? titleInput.value : ""
      this.courseData.assessment.question = questionSelect ? questionSelect.value : ""
    }
  
    const summaryEl = this.element.querySelector('[data-summary-id]')
    if (summaryEl) {
      const noteSelect = summaryEl.querySelector('[data-target="summaryNote"]')
      this.courseData.summary.note = noteSelect ? noteSelect.value : ""
    }
    
    this.updateJSON()
    
    alert('Course saved successfully!')    
  }

  editCourse() {
    try {
      const raw = this.jsonOutputTarget.value.trim()
      this.courseData = JSON.parse(raw)
      this.renderUIFromJSON()
    } catch (e) {
      alert("Invalid JSON format. Please fix before applying.")
    }
  }
  

  updateJSON() {
    const jsonOutput = this.jsonOutputTarget
    if (jsonOutput) {
      this.jsonOutputTarget.value = JSON.stringify(this.courseData, null, 2)

    }
  }
  
}
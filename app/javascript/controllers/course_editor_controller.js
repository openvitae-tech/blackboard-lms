import { Controller } from "@hotwired/stimulus";

class Course {
  constructor(title = "") {
    this.title = title;
    this.modules = [];
    this.assessment = [];
    this.summary = [];

  }
}

class Module {
  constructor(title = "") {
    this.type="module";
    this.id = Date.now() + Math.random();
    this.title = title;
    this.lessons = [];
  }
}

class Lesson {
  constructor(title = "") {
    this.type="lesson";
    this.id = Date.now() + Math.random();
    this.title = title;
    this.file = null;
    this.quiz = null;
  }
}

class Quiz {
  constructor(questions = []) {
    this.type="quiz";
    this.id = Date.now() + Math.random();
    this.questions = questions;
  }
}

class Assessment {
  constructor(questions = []) {
    this.type="assesment";
    this.id = Date.now() + Math.random();
    this.questions = questions;
  }
}

class Summary {
  constructor(title = "") {
    this.type="summary";
    this.id = Date.now() + Math.random();
    this.title = title;
  }
}

export default class extends Controller {
  static targets = ["content", "template", "childTools", "jsonOutput"];

  connect() {
    this.course = null;
  }

  addTool(event) {
    const tool = event.currentTarget.dataset.tool;
    const rawTemplate = this.templateTarget.innerHTML;
    const wrapper = document.createElement("div");
    let contentBlock, html, item;

    if (!this.course && tool !== "course") {
      alert("Please create a Course first.");
      return;
    }

    if (tool === "course") {
      if (this.course) {
        alert("Course is already created.");
        return;
      }
      this.course = new Course();
      item = this.course;
    }

    let parentModule = this.course.modules.at(-1);
    let parentLesson = parentModule?.lessons?.at(-1);

    if (tool === "module") {
      item = new Module();
      this.course.modules.push(item);   
    } else if (tool === "lesson") {
      const moduleElement = event.currentTarget.closest("[data-level='1']"); 
      const moduleId = moduleElement?.dataset.itemId;
    
       parentModule = this.course.modules.find(m => m.id == moduleId);
       parentLesson = parentModule?.lessons?.at(-1);
    
      if (!parentModule) {
        alert("Parent Module not found.");
        return;
      }
      const dropdown = event.currentTarget.closest(".flex").querySelector("select[name='lesson']");
      const selected = dropdown?.value || "";
      item = new Lesson(selected);
      parentModule.lessons.push(item);
    } else if (tool === "quiz") {
      const moduleElement = event.currentTarget.closest("[data-level='1']"); 
      const moduleId = moduleElement?.dataset.itemId;
    
       parentModule = this.course.modules.find(m => m.id == moduleId);
       parentLesson = parentModule?.lessons?.at(-1);

      if (!parentLesson) {
        alert("Please add a Lesson before adding a Quiz.");
        return;
      }
      const dropdown = event.currentTarget.closest(".flex").querySelector("select[name='question']");
      const selected = dropdown?.value ? [dropdown.value] : [];
      item = new Quiz(selected);
      parentLesson.quiz = item;
    } else if (tool === "assessment") {
      if (!parentLesson) {
        alert("Please add a Lesson before adding an Assessment.");
        return;
      }
      const dropdown = event.currentTarget.closest(".flex").querySelector("select[name='assessment']");
      const selected = dropdown?.value ? [dropdown.value] : [];
      item = new Assessment(selected);
      this.course.assessment = item;
    } else if (tool === "summary") {
      if (!parentLesson) {
        alert("Please add a Lesson before adding a Summary.");
        return;
      }
      const dropdown = event.currentTarget.closest(".flex").querySelector("select[name='lesson']");
      const selected = dropdown?.value || "";
      item = new Summary(selected);
      this.course.summary = item;
    }

    html = rawTemplate
      .replace(/{{type}}/g, tool)
      .replace(/{{title}}/g, item.title || "")
      .replace(/{{questions}}/g, item.questions || []);

    wrapper.innerHTML = html.trim();
    contentBlock = wrapper.firstElementChild;
    contentBlock.dataset.type = tool;
    contentBlock.dataset.itemId = item.id;
    
    let level = 0; 
    if (tool === "module") level = 1;
    else if (["lesson", "assessment", "summary"].includes(tool)) level = 2;
    else if (tool === "quiz") level = 3;
    
    contentBlock.dataset.level = String(level);
    contentBlock.style.marginLeft = `${level * 20}px`;
    

    const childTools = contentBlock.querySelector("[data-child-tools]");
      if (childTools) {
        const buttons = childTools.querySelectorAll("button");
        buttons.forEach(btn => {
          const btnTool = btn.dataset.tool;
          if ((tool === "course" && btnTool === "module") ||
              (tool === "module" && btnTool === "lesson") || (tool === "module" && btnTool === "quiz")) {
            btn.classList.remove("hidden");
          } else {
            btn.classList.add("hidden");
          }
        });
      }


    const titleField = contentBlock.querySelector("[data-title-field]");
    const input = contentBlock.querySelector("input");
    
    if (["course", "module", "lesson"].includes(tool)) {
      titleField.style.display = "block";
    
      if (input) {
        input.addEventListener("input", (e) => {
          const value = e.target.value;
          if (tool === "course") {
            this.course.title = value;
          } else if (tool === "module") {
            const mod = this.course.modules.find(m => m.id == contentBlock.dataset.itemId);
            if (mod) mod.title = value;
          } else if (tool === "lesson") {
            const lesson = parentModule?.lessons?.find(l => l.id == contentBlock.dataset.itemId);
            if (lesson) lesson.title = value;
          }
        });
      }
    } else {
      titleField.style.display = "none";
    }

    const dropdowns = contentBlock.querySelectorAll("[data-dropdown]");
    dropdowns.forEach(dropdown => {
      dropdown.classList.toggle("hidden", dropdown.dataset.type !== tool);
    });

    if (tool === "lesson") {
      const lesson = parentModule.lessons.find(l => l.id == item.id);
      const dropdown = contentBlock.querySelector("select[name='lesson']");
      if (dropdown && lesson) {
        dropdown.addEventListener("change", (e) => {
          lesson.file = e.target.value;
        });
      }
    }

    if (tool === "quiz") {
      const dropdown = contentBlock.querySelector("select[name='question']");
      if (dropdown && parentLesson?.quiz) {
        dropdown.addEventListener("change", (e) => {
          parentLesson.quiz.questions = [e.target.value];
        });
      }
    }

    if (tool === "assessment") {
      const dropdown = contentBlock.querySelector("select[name='assessment']");
      if (dropdown && parentLesson?.assessment) {
        dropdown.addEventListener("change", (e) => {
          parentLesson.assessment.questions = [e.target.value];
        });
      }
    }

    if (tool === "summary") {
      const dropdown = contentBlock.querySelector("select[name='lesson']");
      if (dropdown && parentLesson?.summary) {
        dropdown.addEventListener("change", (e) => {
          parentLesson.summary.title = e.target.value;
        });
      }
    }
    
    const deleteBtn = contentBlock.querySelector("button[aria-label='Delete']");
    deleteBtn.addEventListener("click", () => {
      const type = contentBlock.dataset.type;
      const id = contentBlock.dataset.itemId;

      if (type === "module") {
        const index = this.course.modules.findIndex(m => m.id == id);
        if (index !== -1 && this.course.modules[index].lessons.length === 0) {
          this.course.modules.splice(index, 1);
          contentBlock.remove();
        } else {
          alert("Cannot delete Module that contains Lessons.");
        }
        return;
      }

      if (type === "lesson") {
        for (const module of this.course.modules) {
          const index = module.lessons.findIndex(l => l.id == id);
          if (index !== -1 && !module.lessons[index].quiz && !module.lessons[index].assessment && !module.lessons[index].summary) {
            module.lessons.splice(index, 1);
            contentBlock.remove();
            return;
          }
        }
        alert("Cannot delete Lesson with Quiz/Assessment/Summary.");
        return;
      }

      if (["quiz", "assessment", "summary"].includes(type)) {
        for (const module of this.course.modules) {
          for (const lesson of module.lessons) {
            if (lesson[type] && lesson[type].id == id) {
              lesson[type] = null;
              contentBlock.remove();
              return;
            }
          }
        }
      }
    });

    if (tool === "lesson" || tool === "quiz") {
      const moduleElement = event.currentTarget.closest("[data-level='1']");
      if (moduleElement) {
        moduleElement.appendChild(contentBlock);
      } else {
        this.contentTarget.appendChild(contentBlock);
      }
    } else {
      this.contentTarget.appendChild(contentBlock);
    }
    
  }

  createCourse() {
    if (!this.course) {
      alert("No course created yet.");
      return;
    }
  
    this.finalCourseJson = JSON.stringify(this.course, null, 2);
  
    if (this.hasJsonOutputTarget) {
      this.jsonOutputTarget.innerHTML = `<pre>${this.finalCourseJson}</pre>`;
    } 
  }
  
}
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "index"]
  
  connect() {
    console.log("Questions controller connected");
    this.updateQuestionNumbers();
  }
  
  add(event) {
    event.preventDefault();
    
    const timestamp = new Date().getTime();
    const currentIndex = parseInt(this.indexTarget.value) || 0;
    
    const html = `
      <div class="pergunta-field" data-persisted="false" data-timestamp="${timestamp}">
        <div class="pergunta-header">
          <label>Nova Pergunta</label>
          <button type="button" class="remove-new-question" data-action="click->questions#remove">
            × Remover
          </button>
        </div>
        <textarea 
          name="template[perguntas_attributes][${currentIndex}][texto]" 
          rows="2"
          class="form-control question-text"
          placeholder="Digite o texto da pergunta..."
          data-questions-target="questionText"></textarea>
        <input type="hidden" name="template[perguntas_attributes][${currentIndex}][id]" value="">
      </div>
    `;
    
    this.containerTarget.insertAdjacentHTML('beforeend', html);
    this.indexTarget.value = currentIndex + 1;
    this.updateQuestionNumbers();
  }
  
  remove(event) {
    event.preventDefault();
    const field = event.target.closest('.pergunta-field');
    field.remove();
    this.reindexQuestions();
    this.updateQuestionNumbers();
  }
  
  reindexQuestions() {
    const newFields = this.containerTarget.querySelectorAll('.pergunta-field[data-persisted="false"]');
    let currentIndex = 0;
    
    newFields.forEach((field, position) => {
      const textarea = field.querySelector('textarea');
      textarea.name = `template[perguntas_attributes][${currentIndex}][texto]`;
      
      const hiddenId = field.querySelector('input[type="hidden"][name$="[id]"]');
      if (hiddenId) {
        hiddenId.name = `template[perguntas_attributes][${currentIndex}][id]`;
      }
      
      currentIndex++;
    });
    
    this.indexTarget.value = currentIndex;
  }
  
  updateQuestionNumbers() {
    const allFields = this.containerTarget.querySelectorAll('.pergunta-field');
    let questionNumber = 1;
    
    allFields.forEach((field) => {
      const label = field.querySelector('label');
      if (label && field.dataset.persisted === 'true') {
        label.textContent = `Pergunta #${questionNumber}`;
        questionNumber++;
      }
    });
  }
}
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    console.log("Templates form controller connected");
  }

  addQuestion(event) {
    event.preventDefault();

    const questionCount = this.containerTarget.querySelectorAll('.pergunta-field').length;

    const html = `
      <div class="pergunta-field" data-persisted="false">
        <div class="pergunta-header">
          <label>Nova Pergunta</label>
          <button type="button" class="remove-new-question" onclick="this.closest('.pergunta-field').remove()">
            × Remover
          </button>
        </div>
        <textarea 
          name="template[perguntas_attributes][${questionCount}][texto]" 
          rows="2"
          class="form-control question-text"
          placeholder="Digite o texto da pergunta..."></textarea>
        <input type="hidden" name="template[perguntas_attributes][${questionCount}][id]" value="">
      </div>
    `;

    this.containerTarget.insertAdjacentHTML('beforeend', html);
  }
}
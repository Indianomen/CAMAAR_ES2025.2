class Formulario < ApplicationRecord
  belongs_to :administrador
  belongs_to :template
  belongs_to :turma
  
  # Questions copied from template to this specific form
  has_many :perguntas, dependent: :destroy
  
  # Students who have answered this form
  has_and_belongs_to_many :alunos_respostas,
                          class_name: 'Aluno',
                          join_table: :alunos_formularios
  
  # Answers submitted for this form
  has_many :respostas, through: :perguntas
  
  validates :turma_id, uniqueness: { scope: :template_id, 
    message: "já possui um formulário deste template" }
  
  # After creating a form, copy questions from template
  after_create :copy_questions_from_template
  
  # Scope for forms with answers
  scope :with_responses, -> { 
    joins(:respostas).distinct 
  }
  
  # Scope for pending forms (not answered by all students)
  scope :pending, -> {
    where.not(id: AlunoFormulario.select(:formulario_id).distinct)
  }
  
  private
  
  def copy_questions_from_template
    template.perguntas.each do |template_pergunta|
      perguntas.create(
        template_id: template.id,
        texto: template_pergunta.texto,
        formulario_id: id
      )
    end
  end
end
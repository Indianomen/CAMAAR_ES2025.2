class Formulario < ApplicationRecord
  belongs_to :administrador
  belongs_to :template
  belongs_to :turma
  
  has_many :perguntas, dependent: :destroy
  
  has_and_belongs_to_many :alunos_respostas,
                          class_name: 'Aluno',
                          join_table: :alunos_formularios
  
  has_many :respostas, through: :perguntas
  
  validates :turma_id, uniqueness: { scope: :template_id, 
    message: "já possui um formulário deste template" }
  
  after_create :copy_questions_from_template
  
  scope :with_responses, -> { 
    joins(:respostas).distinct 
  }
  
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
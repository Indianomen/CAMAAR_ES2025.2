##
# Representa um formulário aplicado a uma turma com base em um template.
#
# O formulário é criado por um administrador, pertence a uma turma
# específica e utiliza um template como base para gerar suas perguntas.
#
# Após a criação, todas as perguntas do template são automaticamente
# copiadas para o formulário.
#
class Formulario < ApplicationRecord

  ##
  # Administrador responsável pela criação do formulário.
  #
  # @return [Administrador]
  #
  belongs_to :administrador

  ##
  # Template utilizado como base para o formulário.
  #
  # @return [Template]
  #
  belongs_to :template

  ##
  # Turma à qual o formulário está associado.
  #
  # @return [Turma]
  #
  belongs_to :turma

  ##
  # Perguntas pertencentes a este formulário.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Perguntum>]
  #
  # Efeitos colaterais:
  # - Ao remover o formulário, todas as perguntas associadas
  #   são removidas automaticamente.
  #
  has_many :perguntas, dependent: :destroy

  ##
  # Alunos que responderam este formulário.
  #
  # Associação muitos-para-muitos utilizando a tabela
  # intermediária +alunos_formularios+.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Aluno>]
  #
  has_and_belongs_to_many :alunos_respostas,
                          class_name: 'Aluno',
                          join_table: :alunos_formularios

  ##
  # Respostas associadas ao formulário por meio das perguntas.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Resposta>]
  #
  has_many :respostas, through: :perguntas

  ##
  # Garante que uma mesma turma não possua mais de um formulário
  # para o mesmo template.
  #
  # @return [void]
  #
  validates :turma_id,
            uniqueness: {
              scope: :template_id,
              message: "já possui um formulário deste template"
            }

  ##
  # Callback executado após a criação do formulário.
  #
  # Responsável por copiar automaticamente as perguntas
  # do template associado para este formulário.
  #
  after_create :copy_questions_from_template

  ##
  # Escopo que retorna formulários que possuem ao menos
  # uma resposta associada.
  #
  # @return [ActiveRecord::Relation<Formulario>]
  #
  scope :with_responses, -> {
    joins(:respostas).distinct
  }

  ##
  # Escopo que retorna formulários ainda não respondidos
  # por nenhum aluno.
  #
  # @return [ActiveRecord::Relation<Formulario>]
  #
  scope :pending, -> {
    where.not(id: AlunoFormulario.select(:formulario_id).distinct)
  }

  private

  ##
  # Copia as perguntas do template para o formulário recém-criado.
  #
  # Para cada pergunta do template, uma nova pergunta é criada
  # associada a este formulário, preservando o texto original.
  #
  # @return [void]
  #
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

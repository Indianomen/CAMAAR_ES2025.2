
require 'rails_helper'

RSpec.describe "Admin::Formularios results", type: :request do
  let(:admin)      { create(:administrador) }
  let(:template)   { create(:template, administrador: admin, nome: "Avaliação Docente") }
  let(:disciplina) { create(:disciplina, nome: "Algoritmos") }
  let(:turma)      { create(:turma, disciplina: disciplina, semestre: "2025.1") }
  let(:formulario) { create(:formulario, administrador: admin, template: template, turma: turma) }

  let!(:pergunta) do
    create(
      :pergunta,
      formulario: formulario,
      template: template,
      texto: "Como avalia o conteúdo?"
    )
  end

  let!(:aluno) do
    Aluno.create!(
      nome: "Aluno Teste",
      email: "aluno_teste@example.com",
      password: "password123",
      password_confirmation: "password123",
      matricula: "202512345",
      usuario: "aluno.teste",
      curso: "Engenharia de Software",
      departamento: "Computação"
    )
  end


  let!(:resposta) do
    Resposta.create!(
      pergunta: pergunta,
      aluno: aluno,
      texto: "Muito bom",
      created_at: Time.zone.now
    )
  end


  before do
    allow_any_instance_of(Admin::ApplicationController)
      .to receive(:current_administrador).and_return(admin)

    allow_any_instance_of(Admin::ApplicationController)
      .to receive(:administrador_signed_in?).and_return(true)
  end

  it "renderiza a página de resultados e exibe estatísticas e respostas" do
    get results_admin_formulario_path(formulario)

    expect(response).to have_http_status(:ok)

    expect(response.body).to include("📊 Resultados:")
    expect(response.body).to include("Turma:")
    expect(response.body).to include("Respostas por Pergunta")

    expect(response.body).to include("Como avalia o conteúdo?")
    expect(response.body).to include("Muito bom")
  end
end


require 'rails_helper'

RSpec.describe "Admin::Formularios CSV export", type: :request do
  let(:admin)      { create(:administrador) }
  let(:template)   { create(:template, administrador: admin, nome: "Avaliação Docente") }
  let(:disciplina) { create(:disciplina, nome: "Algoritmos") }
  let(:turma)      { create(:turma, disciplina: disciplina, semestre: "2025.1") }
  let(:formulario) { create(:formulario, administrador: admin, template: template, turma: turma) }

  let!(:aluno1) do
    Aluno.create!(
      nome: "Aluno Um",
      email: "aluno1_export@example.com",
      password: "password123",
      password_confirmation: "password123",
      matricula: "202511111",
      usuario: "aluno.export1",
      curso: "Engenharia de Software",
      departamento: "Computação"
    )
  end

  let!(:aluno2) do
    Aluno.create!(
      nome: "Aluno Dois",
      email: "aluno2_export@example.com",
      password: "password123",
      password_confirmation: "password123",
      matricula: "202522222",
      usuario: "aluno.export2",
      curso: "Engenharia de Software",
      departamento: "Computação"
    )
  end


  let!(:pergunta) do
    create(
      :pergunta,
      formulario: formulario,
      template: template,
      texto: "Como avalia o conteúdo?"
    )
  end

  let!(:resposta1) do
    Resposta.create!(
      pergunta: pergunta,
      aluno: aluno1,
      texto: "Muito bom",
      created_at: Time.zone.parse("2025-12-14 10:00")
    )
  end

  let!(:resposta2) do
    Resposta.create!(
      pergunta: pergunta,
      aluno: aluno2,
      texto: "Regular",
      created_at: Time.zone.parse("2025-12-14 11:00")
    )
  end


  before do
    allow_any_instance_of(Admin::ApplicationController)
      .to receive(:current_administrador).and_return(admin)

    allow_any_instance_of(Admin::ApplicationController)
      .to receive(:administrador_signed_in?).and_return(true)
  end

  it "retorna CSV como attachment com cabeçalho e linhas esperadas" do
    get export_csv_admin_formulario_path(formulario, format: :csv)

    expect(response).to have_http_status(:ok)
    expect(response.headers['Content-Type']).to include('text/csv')
    expect(response.headers['Content-Disposition'])
      .to match(/attachment; filename="?resultados_formulario_#{formulario.id}\.csv"?/)

    csv = response.body

    expect(csv.lines.first.strip).to eq("Template,Turma,Semestre,Pergunta,Resposta,Respondido em")

    expect(csv).to include("Avaliação Docente,Algoritmos,2025.1,Como avalia o conteúdo?,Muito bom")
    expect(csv).to include("Avaliação Docente,Algoritmos,2025.1,Como avalia o conteúdo?,Regular")
  end
end

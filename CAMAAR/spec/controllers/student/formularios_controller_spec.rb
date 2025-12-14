require 'rails_helper'

RSpec.describe Student::FormulariosController, type: :controller do
  let(:admin) { create(:administrador) }
  let(:aluno) { create(:aluno) }
  let(:outro_aluno) { create(:aluno) }
  let(:template) { create(:template, administrador: admin) }
  let(:disciplina) { create(:disciplina) }
  let(:professor) { create(:professor) }
  let(:turma) { create(:turma, professor: professor, disciplina: disciplina) }
  let(:outra_turma) { create(:turma, professor: professor, disciplina: disciplina) }
  
  let!(:formulario) do
    create(:formulario, 
           administrador: admin, 
           template: template, 
           turma: turma)
  end
  
  let!(:pergunta1) { create(:pergunta, template: template, formulario: formulario, texto: "Pergunta 1") }
  let!(:pergunta2) { create(:pergunta, template: template, formulario: formulario, texto: "Pergunta 2") }
  
  before do
    # Matricular aluno na turma
    turma.alunos << aluno
  end

  describe "Authentication" do
    context "when not authenticated" do
      it "redirects to login on index" do
        get :index
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Acesso restrito a alunos")
      end
      
      it "redirects to login on show" do
        get :show, params: { id: formulario.id }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Acesso restrito a alunos")
      end
      
      it "redirects to login on submit" do
        post :submit, params: { id: formulario.id }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Acesso restrito a alunos")
      end
    end
    
    context "when authenticated as admin" do
      before { login_as_admin(admin) }
      
      it "denies access to index" do
        get :index
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Acesso restrito a alunos")
      end
    end
  end

  describe "GET #index" do
    before { login_as_aluno(aluno) }
    
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end
    
    it "assigns only pending formularios for the student's turmas" do
      # Criar formulário para outra turma (não deve aparecer)
      formulario_outra_turma = create(:formulario, turma: outra_turma, template: template)
      
      get :index
      expect(assigns(:formularios_pendentes)).to include(formulario)
      expect(assigns(:formularios_pendentes)).not_to include(formulario_outra_turma)
    end
    
    it "does not include already answered formularios" do
      # Marcar formulário como respondido
      aluno.formularios_respostas << formulario
      
      get :index
      expect(assigns(:formularios_pendentes)).not_to include(formulario)
    end
    
    it "includes formularios with perguntas and template" do
      get :index
      expect(assigns(:formularios_pendentes).first.perguntas).to be_loaded
      expect(assigns(:formularios_pendentes).first.template).to be_loaded
    end
  end

  describe "GET #show" do
    before { login_as_aluno(aluno) }
    
    context "with valid formulario" do
      it "returns a success response" do
        get :show, params: { id: formulario.id }
        expect(response).to be_successful
      end
      
      it "assigns the formulario" do
        get :show, params: { id: formulario.id }
        expect(assigns(:formulario)).to eq(formulario)
      end
      
      it "assigns perguntas ordered by id" do
        get :show, params: { id: formulario.id }
        expect(assigns(:perguntas)).to eq([pergunta1, pergunta2])
      end
    end
    
    context "when formulario does not exist" do
      it "redirects to index with alert" do
        get :show, params: { id: 99999 }
        expect(response).to redirect_to(student_formularios_path)
        expect(flash[:alert]).to eq("Formulário não encontrado.")
      end
    end
    
    context "when formulario does not belong to student's turma" do
      let(:formulario_outra_turma) { create(:formulario, turma: outra_turma, template: template) }
      
      it "redirects to index with alert" do
        get :show, params: { id: formulario_outra_turma.id }
        expect(response).to redirect_to(student_formularios_path)
        expect(flash[:alert]).to eq("Você não tem permissão para acessar este formulário.")
      end
    end
    
    context "when student already answered the formulario" do
      before do
        aluno.formularios_respostas << formulario
      end
      
      it "redirects to index with alert" do
        get :show, params: { id: formulario.id }
        expect(response).to redirect_to(student_formularios_path)
        expect(flash[:alert]).to eq("Você já respondeu este formulário.")
      end
    end
  end

  describe "POST #submit" do
    before { login_as_aluno(aluno) }
    
    let(:valid_respostas) do
      {
        pergunta1.id.to_s => "Resposta para pergunta 1",
        pergunta2.id.to_s => "Resposta para pergunta 2"
      }
    end
    
    context "with valid responses" do
      it "creates respostas for all perguntas" do
        expect {
          post :submit, params: { id: formulario.id, respostas: valid_respostas }
        }.to change(Resposta, :count).by(2)
      end
      
      it "associates respostas with the aluno" do
        post :submit, params: { id: formulario.id, respostas: valid_respostas }
        expect(Resposta.where(aluno: aluno).count).to eq(2)
      end
      
      it "marks formulario as answered" do
        post :submit, params: { id: formulario.id, respostas: valid_respostas }
        expect(aluno.formularios_respostas).to include(formulario)
      end
      
      it "redirects to index with success message" do
        post :submit, params: { id: formulario.id, respostas: valid_respostas }
        expect(response).to redirect_to(student_formularios_path)
        expect(flash[:notice]).to eq("Respostas enviadas com sucesso! Obrigado por participar da avaliação.")
      end
      
      it "strips whitespace from responses" do
        respostas_com_espacos = {
          pergunta1.id.to_s => "  Resposta com espaços  ",
          pergunta2.id.to_s => "Outra resposta  "
        }
        
        post :submit, params: { id: formulario.id, respostas: respostas_com_espacos }
        
        resposta = Resposta.find_by(pergunta: pergunta1, aluno: aluno)
        expect(resposta.texto).to eq("Resposta com espaços")
      end
    end
    
    context "with missing responses" do
      let(:incomplete_respostas) do
        {
          pergunta1.id.to_s => "Apenas uma resposta"
          # pergunta2 não respondida
        }
      end
      
      it "does not create any respostas" do
        expect {
          post :submit, params: { id: formulario.id, respostas: incomplete_respostas }
        }.not_to change(Resposta, :count)
      end
      
      it "does not mark formulario as answered" do
        post :submit, params: { id: formulario.id, respostas: incomplete_respostas }
        expect(aluno.formularios_respostas).not_to include(formulario)
      end
      
      it "renders show with error message" do
        post :submit, params: { id: formulario.id, respostas: incomplete_respostas }
        expect(response).to render_template(:show)
        expect(flash[:alert]).to eq("Por favor, responda todas as perguntas obrigatórias.")
      end
      
      it "assigns perguntas for re-rendering" do
        post :submit, params: { id: formulario.id, respostas: incomplete_respostas }
        expect(assigns(:perguntas)).to eq([pergunta1, pergunta2])
      end
    end
    
    context "with blank responses" do
      let(:blank_respostas) do
        {
          pergunta1.id.to_s => "  ",
          pergunta2.id.to_s => ""
        }
      end
      
      it "does not create respostas" do
        expect {
          post :submit, params: { id: formulario.id, respostas: blank_respostas }
        }.not_to change(Resposta, :count)
      end
      
      it "renders show with error message" do
        post :submit, params: { id: formulario.id, respostas: blank_respostas }
        expect(response).to render_template(:show)
        expect(flash[:alert]).to eq("Por favor, responda todas as perguntas obrigatórias.")
      end
    end
    
    context "when formulario does not belong to student's turma" do
      let(:formulario_outra_turma) { create(:formulario, turma: outra_turma, template: template) }
      
      it "redirects with error" do
        post :submit, params: { id: formulario_outra_turma.id, respostas: valid_respostas }
        expect(response).to redirect_to(student_formularios_path)
        expect(flash[:alert]).to eq("Você não tem permissão para acessar este formulário.")
      end
      
      it "does not create respostas" do
        expect {
          post :submit, params: { id: formulario_outra_turma.id, respostas: valid_respostas }
        }.not_to change(Resposta, :count)
      end
    end
    
    context "when student already answered" do
      before do
        aluno.formularios_respostas << formulario
      end
      
      it "redirects with error" do
        post :submit, params: { id: formulario.id, respostas: valid_respostas }
        expect(response).to redirect_to(student_formularios_path)
        expect(flash[:alert]).to eq("Você já respondeu este formulário.")
      end
      
      it "does not create duplicate respostas" do
        expect {
          post :submit, params: { id: formulario.id, respostas: valid_respostas }
        }.not_to change(Resposta, :count)
      end
    end
    
    context "when session expires during submission" do
      it "redirects to login with session expired message" do
        # Simular sessão expirada
        allow(controller).to receive(:logged_in?).and_return(false)
        
        post :submit, params: { id: formulario.id, respostas: valid_respostas }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Sua sessão expirou. Por favor, faça login novamente.")
      end
      
      it "does not create respostas when session expired" do
        allow(controller).to receive(:logged_in?).and_return(false)
        
        expect {
          post :submit, params: { id: formulario.id, respostas: valid_respostas }
        }.not_to change(Resposta, :count)
      end
    end
    
    context "transaction rollback on error" do
      it "does not save any respostas if one fails" do
        # Forçar erro na segunda resposta
        allow(Resposta).to receive(:create!).and_call_original
        allow(Resposta).to receive(:create!).with(
          hash_including(pergunta: pergunta2)
        ).and_raise(ActiveRecord::RecordInvalid.new(Resposta.new))
        
        expect {
          post :submit, params: { id: formulario.id, respostas: valid_respostas }
        }.not_to change(Resposta, :count)
      end
      
      it "does not mark formulario as answered if save fails" do
        allow(Resposta).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Resposta.new))
        
        post :submit, params: { id: formulario.id, respostas: valid_respostas }
        expect(aluno.formularios_respostas).not_to include(formulario)
      end
      
      it "renders show with error message on save failure" do
        allow(Resposta).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Resposta.new))
        
        post :submit, params: { id: formulario.id, respostas: valid_respostas }
        expect(response).to render_template(:show)
        expect(flash[:alert]).to match(/Erro ao salvar respostas/)
      end
    end
  end
end

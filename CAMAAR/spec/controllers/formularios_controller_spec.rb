require 'rails_helper'

RSpec.describe Admin::FormulariosController, type: :controller do
  let(:admin) { create(:administrador) }
  let(:template) { create(:template, administrador: admin) }
  let(:disciplina) { create(:disciplina) }
  let(:professor) { create(:professor) }
  let(:turma) { create(:turma, professor: professor, disciplina: disciplina) }
  
  let(:valid_attributes) do
    {
      template_id: template.id,
      turma_id: turma.id
    }
  end
  
  let(:invalid_attributes) do
    {
      template_id: nil,
      turma_id: nil
    }
  end

  let(:formulario) do 
  create(:formulario, 
          administrador: admin, 
          template: template, 
          turma: turma)
  end
  
  before do
    login_as_admin(admin)
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns all formularios" do
      formulario1 = create(:formulario, administrador: admin)
      formulario2 = create(:formulario, administrador: admin)
      
      get :index
      expect(assigns(:formularios)).to include(formulario1, formulario2)
    end

    context "when not authenticated" do
      it "redirects to login" do
        logout
        get :index
        expect(response).to redirect_to(admin_login_path)
      end
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: formulario.id }
      expect(response).to be_successful
    end

    it "assigns the requested formulario" do
      get :show, params: { id: formulario.id }
      expect(assigns(:formulario)).to eq(formulario)
    end

    it "assigns perguntas for the formulario" do
      pergunta = create(:pergunta, template: template, formulario: formulario)
      get :show, params: { id: formulario.id }
      expect(assigns(:perguntas)).to include(pergunta)
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end

    it "assigns a new formulario" do
      get :new
      expect(assigns(:formulario)).to be_a_new(Formulario)
    end

    it "assigns templates" do
      get :new
      expect(assigns(:templates)).to include(template)
    end

    it "assigns turmas" do
      get :new
      expect(assigns(:turmas)).to include(turma)
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      get :edit, params: { id: formulario.id }
      expect(response).to be_successful
    end

    it "assigns the requested formulario" do
      get :edit, params: { id: formulario.id }
      expect(assigns(:formulario)).to eq(formulario)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new Formulario" do
        expect {
          post :create, params: { formulario: valid_attributes }
        }.to change(Formulario, :count).by(1)
      end

      it "redirects to the created formulario" do
        post :create, params: { formulario: valid_attributes }
        expect(response).to redirect_to(admin_formulario_path(Formulario.last))
      end

      it "sets a success notice" do
        post :create, params: { formulario: valid_attributes }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid parameters" do
      it "does not create a new Formulario" do
        expect {
          post :create, params: { formulario: invalid_attributes }
        }.not_to change(Formulario, :count)
      end

      it "renders the new template" do
        post :create, params: { formulario: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end

    context "when turma already has a formulário for this template" do
      before do
        create(:formulario, template: template, turma: turma)
      end

      it "does not create duplicate formulario" do
        expect {
          post :create, params: { formulario: valid_attributes }
        }.not_to change(Formulario, :count)
      end
    end
  end

  describe "PUT #update" do
    context "with valid parameters" do
      let(:new_template) { create(:template, administrador: admin) }
      let(:new_turma) { create(:turma) }
      let(:new_attributes) do
        {
          template_id: new_template.id,
          turma_id: new_turma.id
        }
      end

      it "updates the requested formulario" do
        put :update, params: { id: formulario.id, formulario: new_attributes }
        formulario.reload
        expect(formulario.template).to eq(new_template)
        expect(formulario.turma).to eq(new_turma)
      end

      it "redirects to the formulario" do
        put :update, params: { id: formulario.id, formulario: new_attributes }
        expect(response).to redirect_to(admin_formulario_path(formulario))
      end

      it "sets a success notice" do
        put :update, params: { id: formulario.id, formulario: new_attributes }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid parameters" do
      it "does not update the formulario" do
        original_turma = formulario.turma
        put :update, params: { id: formulario.id, formulario: invalid_attributes }
        formulario.reload
        expect(formulario.turma).to eq(original_turma)
      end

      it "renders the edit template" do
        put :update, params: { id: formulario.id, formulario: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "GET #results" do
    let(:aluno) { create(:aluno) }
    
    before do
      create(:pergunta, template: template, texto: "Question 1")
      create(:pergunta, template: template, texto: "Question 2")
      
      formulario.reload
      
      pergunta = formulario.perguntas.first
      create(:resposta, pergunta: pergunta, aluno: aluno, texto: "Resposta de teste")
    end

    it "returns a success response" do
      get :results, params: { id: formulario.id }
      expect(response).to be_successful
    end

    it "assigns respostas from formulario" do
      get :results, params: { id: formulario.id }
      expect(assigns(:respostas)).to be_present
    end
  end
end
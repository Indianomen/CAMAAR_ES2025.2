require 'rails_helper'

RSpec.describe "FactoryBot Test", type: :model do
  it "can create an administrador" do
    admin = FactoryBot.create(:administrador)
    expect(admin).to be_persisted
    expect(admin.nome).to eq("Admin Test")
  end
end

RSpec.describe TemplatesController, type: :controller do
  let(:admin) { FactoryBot.create(:administrador) }
  let(:professor) { FactoryBot.create(:professor) }
  let(:aluno) { FactoryBot.create(:aluno) }
  
  describe "GET #index" do
    context "as admin" do
      before { login_as_admin(admin) }
      
      it "returns a success response" do
        get :index
        expect(response).to be_successful
      end
      
      it "only shows templates created by current admin" do
        template1 = create(:template, administrador: admin)
        template2 = create(:template, administrador: create(:administrador))
        
        get :index
        expect(assigns(:templates)).to include(template1)
        expect(assigns(:templates)).not_to include(template2)
      end
    end
    
    context "as professor" do
      before { login_as_professor(professor) }
      
      it "redirects with unauthorized message" do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Acesso não autorizado.")
      end
    end
    
    context "as student" do
      before { login_as_aluno(aluno) }
      
      it "redirects with unauthorized message" do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Acesso não autorizado.")
      end
    end
  end
  
  describe "POST #create" do
    before { login_as_admin(admin) }
    
    context "with valid params" do
      let(:valid_attributes) do
        {
          nome: "Novo Template",
          perguntas_attributes: {
            "0": { texto: "Pergunta 1?" },
            "1": { texto: "Pergunta 2?" }
          }
        }
      end
      
      it "creates a new Template" do
        expect {
          post :create, params: { template: valid_attributes }
        }.to change(Template, :count).by(1)
      end
      
      it "assigns current admin as creator" do
        post :create, params: { template: valid_attributes }
        expect(assigns(:template).administrador).to eq(admin)
      end
      
      it "redirects to the created template" do
        post :create, params: { template: valid_attributes }
        expect(response).to redirect_to(Template.last)
        expect(flash[:notice]).to eq('Template criado com sucesso.')
      end
      
      it "creates associated questions" do
        expect {
          post :create, params: { template: valid_attributes }
        }.to change(Pergunta, :count).by(2)
      end
    end
    
    context "with invalid params" do
      let(:invalid_attributes) { { nome: "" } }
      
      it "does not create a new Template" do
        expect {
          post :create, params: { template: invalid_attributes }
        }.not_to change(Template, :count)
      end
      
      it "re-renders the 'new' template" do
        post :create, params: { template: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end
  
  describe "DELETE #destroy" do
    before { login_as_admin(admin) }
    
    let!(:template) { create(:template, administrador: admin) }
    
    it "destroys the requested template" do
      expect {
        delete :destroy, params: { id: template.id }
      }.to change(Template, :count).by(-1)
    end
    
    it "redirects to the templates list" do
      delete :destroy, params: { id: template.id }
      expect(response).to redirect_to(templates_url)
      expect(flash[:notice]).to eq('Template excluído com sucesso.')
    end
  end
end
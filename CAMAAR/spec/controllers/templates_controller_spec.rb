require 'rails_helper'

RSpec.describe TemplatesController, type: :controller do
  let(:admin) { create(:administrador) }
  let(:professor) { create(:professor) }
  let(:aluno) { create(:aluno) }
  
  describe "GET #index" do
    context "without authentication" do
      it "returns a success response" do
        get :index
        expect(response).to be_successful
      end
    end
    
    context "when mocking admin" do
      before { login_as_admin(admin) }
      
      it "returns a success response" do
        get :index
        expect(response).to be_successful
      end
      
      it "shows templates created by current admin" do
        template = Template.create!(nome: "Test Template", administrador: admin)
        get :index
        expect(assigns(:templates)).to include(template)
      end
    end
  end
  
  describe "GET #new" do
    context "without authentication" do
      it "redirects to root with unauthorized message" do
        get :new
        expect(response).to redirect_to('/')
        expect(flash[:alert]).to eq("Acesso não autorizado.")
      end
    end
    
    context "when mocking admin" do
      before { login_as_admin(admin) }
      
      it "returns a success response" do
        get :new
        expect(response).to be_successful
      end
    end
  end
  
  describe "POST #create" do
    context "when mocking admin" do
      before { login_as_admin(admin) }
      
      it "creates template" do
        expect {
          post :create, params: { 
            template: { 
              nome: "Test Template",
              perguntas_attributes: {
                "0": { texto: "Pergunta 1" }
              }
            }
          }
        }.to change(Template, :count).by(1)
      end
      
      it "assigns current admin as creator" do
        post :create, params: { 
          template: { 
            nome: "Test Template",
            perguntas_attributes: {
              "0": { texto: "Pergunta 1" }
            }
          }
        }
        expect(Template.last.administrador).to eq(admin)
      end
    end
  end
  
  describe "GET #edit" do
    let!(:template) { create(:template, administrador: admin) }
    
    context "when mocking admin" do
      before { login_as_admin(admin) }
      
      it "returns a success response" do
        get :edit, params: { id: template.id }
        expect(response).to be_successful
      end
    end
  end
  
  describe "DELETE #destroy" do
    let!(:template) { create(:template, administrador: admin) }
    
    context "when mocking admin" do
      before { login_as_admin(admin) }
      
      it "destroys the template" do
        expect {
          delete :destroy, params: { id: template.id }
        }.to change(Template, :count).by(-1)
      end
    end
  end
end
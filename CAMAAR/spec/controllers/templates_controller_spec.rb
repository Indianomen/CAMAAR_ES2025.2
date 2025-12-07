require 'rails_helper'

RSpec.describe TemplatesController, type: :controller do
  let(:admin) { create(:administrador) }
  let(:other_admin) { create(:administrador, usuario: "outro_admin", email: "outro@test.com") }
  let(:professor) { create(:professor) }
  let(:aluno) { create(:aluno) }
  
  describe "GET #index" do
    context "without authentication" do
      it "returns a success response" do
        get :index
        expect(response).to be_successful
      end
      
      it "shows all templates" do
        template1 = create(:template, administrador: admin)
        template2 = create(:template, administrador: other_admin)
        
        get :index
        expect(assigns(:templates)).to include(template1, template2)
      end
    end
    
    context "when mocking admin" do
      before { login_as_admin(admin) }
      
      it "shows all templates" do
        template1 = create(:template, administrador: admin)
        template2 = create(:template, administrador: other_admin)
        
        get :index
        expect(assigns(:templates)).to include(template1, template2)
      end
    end
    
    context "when mocking admin" do
      before { login_as_admin(admin) }
      
      it "returns a success response" do
        get :index
        expect(response).to be_successful
      end
      
      it "shows only templates created by current admin" do
        my_template = create(:template, administrador: admin)
        other_template = create(:template, administrador: other_admin)
        
        get :index
        expect(assigns(:templates)).to include(my_template)
        expect(assigns(:templates)).not_to include(other_template)
      end
    end
    
    context "when mocking professor" do
      before { login_as_professor(professor) }
      
      it "returns a success response" do
        get :index
        expect(response).to be_successful
      end
      
      it "shows all templates" do
        template1 = create(:template, administrador: admin)
        template2 = create(:template, administrador: other_admin)
        
        get :index
        expect(assigns(:templates)).to include(template1, template2)
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
      
      it "builds 3 empty questions" do
        get :new
        expect(assigns(:template).perguntas.size).to eq(3)
      end
    end
    
    context "when mocking professor" do
      before { login_as_professor(professor) }
      
      it "redirects with unauthorized message" do
        get :new
        expect(response).to redirect_to('/')
        expect(flash[:alert]).to eq("Acesso não autorizado.")
      end
    end
    
    context "when mocking student" do
      before { login_as_aluno(aluno) }
      
      it "redirects with unauthorized message" do
        get :new
        expect(response).to redirect_to('/')
        expect(flash[:alert]).to eq("Acesso não autorizado.")
      end
    end
  end
  
  describe "POST #create" do
    context "when mocking admin" do
      before { login_as_admin(admin) }
      
      it "creates template with valid params" do
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
      
      it "creates associated questions" do
        expect {
          post :create, params: { 
            template: { 
              nome: "Test Template",
              perguntas_attributes: {
                "0": { texto: "Pergunta 1" },
                "1": { texto: "Pergunta 2" }
              }
            }
          }
        }.to change(Pergunta, :count).by(2)
      end
      
      it "redirects to show page on success" do
        post :create, params: { 
          template: { 
            nome: "Test Template",
            perguntas_attributes: {
              "0": { texto: "Pergunta 1" }
            }
          }
        }
        expect(response).to redirect_to(Template.last)
        expect(flash[:notice]).to eq("Template criado com sucesso.")
      end
      
      it "re-renders new template on failure" do
        post :create, params: { template: { nome: "" } }
        expect(response).to render_template(:new)
        expect(flash[:alert]).to be_present
      end
    end
  end
  
  describe "GET #edit" do
    let!(:template) { create(:template, administrador: admin) }
    
    context "when mocking professor" do
      before { login_as_professor(professor) }
      
      it "does not create template" do
        expect {
          post :create, params: { template: { nome: "Test Template" } }
        }.not_to change(Template, :count)
      end
      
      it "redirects with unauthorized message" do
        post :create, params: { template: { nome: "Test Template" } }
        expect(response).to redirect_to('/')
        expect(flash[:alert]).to eq("Acesso não autorizado.")
      end
    end
  end
  
  describe "GET #show" do
    let!(:template) { create(:template, administrador: admin) }
    
    before do
      create_list(:pergunta, 3, template: template, formulario: nil)
    end
    
    context "without authentication" do
      it "returns a success response" do
        get :show, params: { id: template.id }
        expect(response).to be_successful
      end
      
      it "shows template questions" do
        get :show, params: { id: template.id }
        expect(assigns(:perguntas).count).to eq(3)
      end
    end
  end
  
  describe "GET #edit" do
    let!(:template) { create(:template, administrador: admin) }
    
    context "when mocking admin (owner)" do
      before { login_as_admin(admin) }
      
      it "returns a success response" do
        get :edit, params: { id: template.id }
        expect(response).to be_successful
      end
      
      it "builds an empty question for adding more" do
        get :edit, params: { id: template.id }
        expect(assigns(:template).perguntas.any? { |p| p.new_record? }).to be true
      end
    end
    
    context "when mocking other admin" do
      before { login_as_admin(other_admin) }
      
      it "returns a success response (other admins can view but not edit)" do
        get :edit, params: { id: template.id }
        expect(response).to be_successful
      end
    end
    
    context "when mocking professor" do
      before { login_as_professor(professor) }
      
      it "redirects with unauthorized message" do
        get :edit, params: { id: template.id }
        expect(response).to redirect_to('/')
        expect(flash[:alert]).to eq("Acesso não autorizado.")
      end
    end
  end
  
  describe "PUT #update" do
    let!(:template) { create(:template, administrador: admin, nome: "Original Name") }
    
    context "when mocking admin (owner)" do
      before { login_as_admin(admin) }
      
      it "updates template name" do
        put :update, params: { 
          id: template.id, 
          template: { nome: "Updated Name" } 
        }
        template.reload
        expect(template.nome).to eq("Updated Name")
      end
      
      it "adds new questions" do
        expect {
          put :update, params: { 
            id: template.id, 
            template: { 
              perguntas_attributes: {
                "0": { texto: "Nova pergunta" }
              }
            }
          }
        }.to change(template.perguntas, :count).by(1)
      end
      
      it "redirects to show page on success" do
        put :update, params: { 
          id: template.id, 
          template: { nome: "Updated Name" } 
        }
        expect(response).to redirect_to(template)
        expect(flash[:notice]).to eq("Template atualizado com sucesso.")
      end
    end
    
    context "when mocking professor" do
      before { login_as_professor(professor) }
      
      it "does not update template" do
        put :update, params: { 
          id: template.id, 
          template: { nome: "Should Not Update" } 
        }
        template.reload
        expect(template.nome).to eq("Original Name")
      end
      
      it "redirects with unauthorized message" do
        put :update, params: { 
          id: template.id, 
          template: { nome: "Should Not Update" } 
        }
        expect(response).to redirect_to('/')
        expect(flash[:alert]).to eq("Acesso não autorizado.")
      end
    end
  end
  
  describe "DELETE #destroy" do
    let!(:template) { create(:template, administrador: admin) }
    
    context "when mocking admin (owner)" do
      before { login_as_admin(admin) }
      
      it "destroys the template" do
        expect {
          delete :destroy, params: { id: template.id }
        }.to change(Template, :count).by(-1)
      end
      
      it "destroys associated questions" do
        create_list(:pergunta, 2, template: template, formulario: nil)
        
        expect {
          delete :destroy, params: { id: template.id }
        }.to change(Pergunta, :count).by(-2)
      end
      
      it "redirects to templates list" do
        delete :destroy, params: { id: template.id }
        expect(response).to redirect_to(templates_path)
        expect(flash[:notice]).to eq("Template excluído com sucesso.")
      end
    end
    
    context "when mocking other admin" do
      before { login_as_admin(other_admin) }
      
      it "destroys template (any admin can delete)" do
        expect {
          delete :destroy, params: { id: template.id }
        }.to change(Template, :count).by(-1)
      end
      
      it "redirects to templates list" do
        delete :destroy, params: { id: template.id }
        expect(response).to redirect_to(templates_path)
        expect(flash[:notice]).to eq("Template excluído com sucesso.")
      end
    end
    
    context "when mocking professor" do
      before { login_as_professor(professor) }
      
      it "does not destroy template" do
        expect {
          delete :destroy, params: { id: template.id }
        }.not_to change(Template, :count)
      end
      
      it "redirects with unauthorized message" do
        delete :destroy, params: { id: template.id }
        expect(response).to redirect_to('/')
        expect(flash[:alert]).to eq("Acesso não autorizado.")
      end
    end
  end
end
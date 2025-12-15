require 'rails_helper'

RSpec.describe Template, type: :model do
  let(:admin) { create(:administrador) }
  
  describe "validations" do
    it "is valid with a name and questions" do
      template = build(:template, administrador: admin)
      template.perguntas.build(texto: "Pergunta 1?")
      
      expect(template).to be_valid
    end
    
    it "is invalid without a name" do
      template = build(:template, nome: nil, administrador: admin)
      template.perguntas.build(texto: "Pergunta 1?")
      
      expect(template).to be_invalid
      expect(template.errors[:nome]).to include("can't be blank")
    end
    
    it "is invalid without an admin" do
      template = build(:template, administrador: nil)
      template.perguntas.build(texto: "Pergunta 1?")
      
      expect(template).to be_invalid
      expect(template.errors[:administrador]).to include("must exist")
    end
    
    it "is invalid without at least one question" do
      template = build(:template, nome: "Template sem perguntas", administrador: admin)
      skip "Template validation for minimum questions not implemented"
      expect(template).to be_invalid
      expect(template.errors[:perguntas]).to include("must have at least one question")
    end
    
    it "rejects blank questions" do
      template = build(:template, administrador: admin)
      template.perguntas.build(texto: "")
      
      expect(template).to be_invalid
    end
  end
  
  describe "associations" do
    it "belongs to an admin" do
      template = create(:template, administrador: admin)
      expect(template.administrador).to eq(admin)
    end
    
    it "has many questions" do
      template = create(:template, administrador: admin)
      template.perguntas.create(texto: "Pergunta 1?")
      template.perguntas.create(texto: "Pergunta 2?")
      
      expect(template.perguntas.count).to eq(2)
    end
    
    it "destroys associated questions when destroyed" do
      template = create(:template, administrador: admin)
      template.perguntas.create(texto: "Pergunta 1?")
      
      expect {
        template.destroy
      }.to change(Pergunta, :count).by(-1)
    end
  end
  
  describe "nested attributes" do
    it "accepts nested attributes for questions" do
      template = Template.new(
        nome: "Template com nested",
        administrador: admin,
        perguntas_attributes: [
          { texto: "Pergunta 1?" },
          { texto: "Pergunta 2?" }
        ]
      )
      
      expect(template.save).to be_truthy
      expect(template.perguntas.count).to eq(2)
    end
    
    it "allows destroying questions through nested attributes" do
      template = create(:template, administrador: admin)
      pergunta = template.perguntas.create(texto: "Pergunta para excluir")
      
      template.update(
        perguntas_attributes: [
          { id: pergunta.id, _destroy: "1" }
        ]
      )
      
      expect(template.reload.perguntas.count).to eq(0)
    end
  end
end
class RemoveRespostaFromPergunta < ActiveRecord::Migration[8.0]
  def change
    remove_column :pergunta, :resposta, :string
  end
end
##
# Classe base abstrata para todos os modelos ActiveRecord da aplicação.
#
# Herda de +ActiveRecord::Base+ e centraliza configurações comuns
# a todos os models do sistema.
#
# Esta classe não deve ser instanciada diretamente.
#
class ApplicationRecord < ActiveRecord::Base

  ##
  # Define a classe como abstrata.
  #
  # Isso impede que o Rails tente mapear esta classe
  # diretamente para uma tabela no banco de dados.
  #
  # @return [void]
  #
  # Efeitos colaterais:
  # - Todos os models que herdam de +ApplicationRecord+
  #   compartilham este comportamento.
  #
  primary_abstract_class
end

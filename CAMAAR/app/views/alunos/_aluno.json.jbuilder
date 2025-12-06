json.extract! aluno, :id, :nome, :curso, :matricula, :departamento, :formacao, :usuario, :email, :ocupacao, :registered, :password_digest, :created_at, :updated_at
json.url aluno_url(aluno, format: :json)

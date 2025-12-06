json.extract! professor, :id, :nome, :departamento, :formacao, :usuario, :email, :ocupacao, :password_digest, :created_at, :updated_at
json.url professor_url(professor, format: :json)

json.extract! admin, :id, :senha, :nome, :departamento, :formacao, :usuario, :email, :ocupacao, :created_at, :updated_at
json.url admin_url(admin, format: :json)

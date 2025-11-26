json.extract! student, :id, :registered, :senha, :nome, :curso, :matricula, :departamento, :formacao, :usuario, :email, :ocupacao, :created_at, :updated_at
json.url student_url(student, format: :json)

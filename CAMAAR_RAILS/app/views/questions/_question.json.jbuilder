json.extract! question, :id, :form_ID, :template_ID, :texto, :resposta, :created_at, :updated_at
json.url question_url(question, format: :json)

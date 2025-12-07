
# frozen_string_literal: true
class ImportJson
  # Public API: ImportJson.call(path_to_file_or_stringio)
  def self.call(path_or_io)
    raw = if path_or_io.respond_to?(:read)
            path_or_io.read
          else
            File.read(path_or_io)
          end

    payload = JSON.parse(raw)
    raise ArgumentError, 'Esperado um array no topo do JSON' unless payload.is_a?(Array)

    ActiveRecord::Base.transaction do
      payload.each do |entry|
        case detect_format(entry)
        when :roster
          process_roster_entry(entry)
        when :catalog
          process_catalog_entry(entry)
        else
          raise ArgumentError, 'Formato de entrada não reconhecido'
        end
      end
    end
  end

  class << self
    private

    # Heurística simples para detectar formato
    def detect_format(entry)
      return :roster  if entry.key?('dicente') || entry.key?('docente')
      return :catalog if entry.key?('name') || entry.key?('class')
      nil
    end

    # Formato 2 (catálogo): { code, name, class: { classCode, semester, time } }
    def process_catalog_entry(entry)
      code = entry.fetch('code')
      name = entry['name']
      klass = entry['class'] || {}

      disciplina = Disciplina.find_or_initialize_by(codigo: code)
      disciplina.nome = name if name.present?
      disciplina.save!

      class_code = klass['classCode']
      semester   = klass['semester']

      return unless class_code.present? && semester.present?

      turma = Turma.find_or_initialize_by(
        disciplina: disciplina,
        class_code: class_code,
        semester:   semester
      )
      turma.time = klass['time'] if klass['time'].present?
      turma.save!
    end

    # Formato 1 (roster): { code, classCode, semester, docente: {...}, dicente: [...] }
    def process_roster_entry(entry)
      code       = entry.fetch('code')
      class_code = entry.fetch('classCode')
      semester   = entry.fetch('semester')

      disciplina = Disciplina.find_or_create_by!(codigo: code)

      turma = Turma.find_or_initialize_by(
        disciplina: disciplina,
        class_code: class_code,
        semester:   semester
      )
      turma.save! # salva mesmo sem professor para garantir existência

      # Docente
      if (doc = entry['docente']).present?
        professor = Professor.find_or_initialize_by(usuario: doc.fetch('usuario'))
        professor.nome        = doc['nome']
        professor.email       = doc['email']
        professor.departamento= doc['departamento']
        professor.formacao    = doc['formacao']
        professor.ocupacao    = doc['ocupacao']
        professor.save!

        turma.professor = professor
        turma.save!
      end

      # Dicente
      Array(entry['dicente']).each do |st|
        aluno = Aluno.find_or_initialize_by(matricula: st.fetch('matricula'))
        aluno.usuario   = st['usuario']
        aluno.nome      = st['nome']
        aluno.email     = st['email']
        aluno.curso     = st['curso']
        aluno.formacao  = st['formacao']
        aluno.ocupacao  = st['ocupacao']
        aluno.turma     = turma
        aluno.save!
      end
    end
  end
end

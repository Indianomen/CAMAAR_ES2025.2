require 'json'
require 'securerandom'

class ImportJson

  def self.call(path_or_io)
    raw =
      if path_or_io.respond_to?(:read)
        path_or_io.read
      else
        File.read(path_or_io.to_s)
      end

    payload = JSON.parse(raw)
    raise ArgumentError, 'Esperado um array no topo do JSON' unless payload.is_a?(Array)

    new_user_ids = { alunos: [], professores: [] }

    ActiveRecord::Base.transaction do
      payload.each do |entry|
        case detect_format(entry)
        when :roster
          new_ids = process_roster_entry(entry)
          new_user_ids[:alunos].concat(new_ids[:alunos])
          new_user_ids[:professores].concat(new_ids[:professores])
        when :catalog
          process_catalog_entry(entry)
        else
          raise ArgumentError, 'Formato de entrada não reconhecido'
        end
      end
    end

    if new_user_ids[:alunos].any? || new_user_ids[:professores].any?
      UserInviteJob.perform_later(new_user_ids)
    end
  end

  class << self
    private

    def detect_format(entry)
      return :roster  if entry.key?('dicente') || entry.key?('docente')
      return :catalog if entry.key?('name') || entry.key?('class')
      nil
    end

    def process_catalog_entry(entry)
      code = entry.fetch('code')
      name = entry['name']

      disciplina = Disciplina.find_or_initialize_by(codigo: code)
      disciplina.nome = name.presence || disciplina.nome || code
      disciplina.save!
    end

    def process_roster_entry(entry)
      new_ids = { alunos: [], professores: [] }
      
      code     = entry.fetch('code')
      semester = entry.fetch('semester')

      disciplina = Disciplina.find_or_initialize_by(codigo: code)
      disciplina.nome = disciplina.nome.presence || code
      disciplina.save!

      doc = entry['docente'] || {}
      professor = Professor.find_or_initialize_by(usuario: doc.fetch('usuario'))
      is_new_professor = professor.new_record?
      
      professor.nome         = doc['nome']
      professor.email        = doc['email']
      professor.departamento = doc['departamento']
      professor.formacao     = doc['formacao']

      if professor.password_digest.blank?
        pwd = SecureRandom.hex(12)
        professor.password = pwd
        professor.password_confirmation = pwd
      end
      
      if is_new_professor
        professor.registered = false
      end
      
      professor.save!
      
      if is_new_professor && !professor.registered?
        new_ids[:professores] << professor.id
      end

      turma = Turma.find_or_initialize_by(
        disciplina: disciplina,
        professor:  professor,
        semestre:   semester
      )
      turma.horario = turma.horario.presence || 'N/A'
      turma.save!

      Array(entry['dicente']).each do |st|
        matricula_normalizada = st.fetch('matricula').to_s.strip
        
        aluno = Aluno.find_or_initialize_by(matricula: matricula_normalizada)
        
        is_new_record = aluno.new_record?
        
        aluno.usuario      = st['usuario']
        aluno.nome         = st['nome']
        aluno.email        = st['email']
        aluno.curso        = st['curso']
        aluno.departamento = aluno.departamento.presence || infer_departamento(st['curso'])

        if aluno.password_digest.blank?
          apwd = SecureRandom.hex(12)
          aluno.password = apwd
          aluno.password_confirmation = apwd
        end
        
        if is_new_record
          aluno.registered = false
        end
        
        aluno.save!

        if is_new_record && !aluno.registered?
          new_ids[:alunos] << aluno.id
        end

        turma.alunos << aluno unless turma.alunos.exists?(aluno.id)
      end
      
      new_ids
    end

    def infer_departamento(curso)
      return 'DEPTO CIÊNCIAS DA COMPUTAÇÃO' if curso&.match?(/CI[ÊE]NCIA DA COMPUTA[ÇC][ÃA]O/i)
      'DEPTO ACADÊMICO'
    end
  end
end

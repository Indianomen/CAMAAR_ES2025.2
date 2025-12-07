# frozen_string_literal: true

require 'json'
require 'securerandom'

class ImportJson

  # Public API: ImportJson.call(path_or_io)
  def self.call(path_or_io)
    raw =
      if path_or_io.respond_to?(:read)
        path_or_io.read
      else
        File.read(path_or_io.to_s)
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

    # Heurística simples para detectar o formato
    # Roster tem chaves 'dicente'/'docente'; catálogo tem 'name'/'class'
    def detect_format(entry)
      return :roster  if entry.key?('dicente') || entry.key?('docente')
      return :catalog if entry.key?('name') || entry.key?('class')
      nil
    end

    # Formato CATÁLOGO
    # Exemplo:
    # { "code": "CIC0097", "name": "BANCOS DE DADOS", "class": { "classCode": "TA", "semester": "2021.2", "time": "35T45" } }
    #
    # Com suas validações em Turma (professor obrigatório), aqui **apenas** criamos/atualizamos Disciplina.
    def process_catalog_entry(entry)
      code = entry.fetch('code')
      name = entry['name']

      disciplina = Disciplina.find_or_initialize_by(codigo: code)
      # Sua Disciplina exige nome. Se não vier, usa o existente ou fallback para o próprio código.
      disciplina.nome = name.presence || disciplina.nome || code
      disciplina.save!
    end

    # Formato ROSTER
    # Exemplo:
    # {
    #   "code": "CIC0097", "classCode": "TA", "semester": "2021.2",
    #   "docente": { ... }, "dicente": [ ... ]
    # }
    #
    # Aqui criamos/atualizamos: Disciplina, Professor (com senha dummy), Turma (sem professor não passa nas validações),
    # e Alunos (com senha dummy e departamento default), além das associações HABTM (alunos_turmas).
    def process_roster_entry(entry)
      code     = entry.fetch('code')
      semester = entry.fetch('semester')
      # classCode existe na entrada, mas sua Turma não tem essa coluna; pode ser ignorado para este fluxo.

      # Disciplina com fallback de nome (obrigatório)
      disciplina = Disciplina.find_or_initialize_by(codigo: code)
      disciplina.nome = disciplina.nome.presence || code
      disciplina.save!

      # Professor (has_secure_password): define senha dummy se necessário
      doc = entry['docente'] || {}
      professor = Professor.find_or_initialize_by(usuario: doc.fetch('usuario'))
      professor.nome         = doc['nome']
      professor.email        = doc['email']
      professor.departamento = doc['departamento']
      professor.formacao     = doc['formacao']

      if professor.password_digest.blank?
        pwd = SecureRandom.hex(12)
        professor.password = pwd
        professor.password_confirmation = pwd
      end
      professor.save!

      # Turma: sua model exige :semestre, :horario, :professor e :disciplina
      turma = Turma.find_or_initialize_by(
        disciplina: disciplina,
        professor:  professor,
        semestre:   semester
      )
      turma.horario = turma.horario.presence || 'N/A' # roster não traz 'time'; usamos um default
      turma.save!

      # Alunos: criar/atualizar e associar via HABTM
      Array(entry['dicente']).each do |st|
        aluno = Aluno.find_or_initialize_by(matricula: st.fetch('matricula'))
        aluno.usuario      = st['usuario']
        aluno.nome         = st['nome']
        aluno.email        = st['email']
        aluno.curso        = st['curso']
        # Seu Aluno valida :departamento; inferimos a partir do curso ou usamos um default
        aluno.departamento = aluno.departamento.presence || infer_departamento(st['curso'])

        if aluno.password_digest.blank?
          apwd = SecureRandom.hex(12)
          aluno.password = apwd
          aluno.password_confirmation = apwd
        end
        aluno.save!

        turma.alunos << aluno unless turma.alunos.exists?(aluno.id)
      end
    end

    # Fallback simples para departamento
    def infer_departamento(curso)
      return 'DEPTO CIÊNCIAS DA COMPUTAÇÃO' if curso&.match?(/CI[ÊE]NCIA DA COMPUTA[ÇC][ÃA]O/i)
      'DEPTO ACADÊMICO'
    end
  end
end

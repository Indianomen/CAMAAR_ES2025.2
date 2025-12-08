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

    # Coletar IDs de novos usuários para envio de email
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

    # FORA da transaction: dispara emails de forma assíncrona
    # Só enfileira o job se houver novos usuários pendentes
    if new_user_ids[:alunos].any? || new_user_ids[:professores].any?
      UserInviteJob.perform_later(new_user_ids)
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
    # 
    # RETORNA: Hash com IDs de novos usuários pendentes { alunos: [1,2,3], professores: [4] }
    def process_roster_entry(entry)
      new_ids = { alunos: [], professores: [] }
      
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
      
      # Forçar registered: false para novos professores
      if is_new_professor
        professor.registered = false
      end
      
      professor.save!
      
      # Coleta ID apenas se for novo E pendente (registered: false)
      if is_new_professor && !professor.registered?
        new_ids[:professores] << professor.id
      end

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
        # Normalizar a matrícula (strip) para garantir a busca correta
        matricula_normalizada = st.fetch('matricula').to_s.strip
        
        aluno = Aluno.find_or_initialize_by(matricula: matricula_normalizada)
        
        # Verificar se o registro é novo (new_record?)
        is_new_record = aluno.new_record?
        
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
        
        # Forçar registered: false para novos registros
        if is_new_record
          aluno.registered = false
        end
        
        aluno.save!

        # Coleta ID apenas se for novo E pendente (registered: false)
        if is_new_record && !aluno.registered?
          new_ids[:alunos] << aluno.id
        end

        turma.alunos << aluno unless turma.alunos.exists?(aluno.id)
      end
      
      new_ids
    end

    # Fallback simples para departamento
    def infer_departamento(curso)
      return 'DEPTO CIÊNCIAS DA COMPUTAÇÃO' if curso&.match?(/CI[ÊE]NCIA DA COMPUTA[ÇC][ÃA]O/i)
      'DEPTO ACADÊMICO'
    end
  end
end

require 'rails_helper'

RSpec.describe ImportJson, type: :service do
  def fixture_file(path)
    Rails.root.join('spec', 'fixtures', 'files', path)
  end

  let(:roster_path)  { fixture_file('class_members_mock.json') }
  let(:catalog_path) { fixture_file('classes_mock.json') }

  describe '.call' do
    context 'com JSON no formato de roster (docente/dicente)' do
      it 'cria disciplina, turma (com horario), professor (com senha) e alunos (com senha), com associações corretas' do
        expect {
          described_class.call(roster_path)
        }.to change(Disciplina, :count).by(1)
         .and change(Turma, :count).by(1)
         .and change(Professor, :count).by(1)
         .and change(Aluno, :count).by(3)

        disc = Disciplina.find_by(codigo: 'CIC0097')
        expect(disc).to be_present
        expect(disc.nome).to be_present

        turma = Turma.find_by(disciplina: disc, semestre: '2021.2')
        expect(turma).to be_present
        expect(turma.horario).to be_present 

        prof = turma.professor
        expect(prof).to be_present
        expect(prof.usuario).to eq('83807519491')
        expect(prof.nome).to eq('MARISTELA TERTO DE HOLANDA')
        expect(prof.email).to eq('mholanda@unb.br')
        expect(prof.departamento).to eq('DEPTO CIÊNCIAS DA COMPUTAÇÃO')
        expect(prof.formacao).to eq('DOUTORADO')

        m1 = Aluno.find_by(matricula: '190084006')
        m2 = Aluno.find_by(matricula: '200033522')
        m3 = Aluno.find_by(matricula: '150005491')

        [m1, m2, m3].each do |al|
          expect(al).to be_present
          expect(al.usuario).to eq(al.matricula)
          expect(al.nome).to be_present
          expect(al.email).to match(URI::MailTo::EMAIL_REGEXP)
          expect(al.curso).to eq('CIÊNCIA DA COMPUTAÇÃO/CIC')
          expect(al.departamento).to be_present
          expect(al.turmas).to include(turma)
          expect(al.password_digest).to be_present
        end
      end

      it 'é idempotente ao rodar novamente com o mesmo arquivo' do
        described_class.call(roster_path)

        expect {
          described_class.call(roster_path)
        }.to change(Disciplina, :count).by(0)
         .and change(Turma, :count).by(0)
         .and change(Professor, :count).by(0)
         .and change(Aluno, :count).by(0)

        turma = Turma.joins(:disciplina).find_by(disciplinas: { codigo: 'CIC0097' }, semestre: '2021.2')
        expect(turma.alunos.count).to eq(3)
      end
    end

    context 'com JSON no formato de catálogo (disciplinas + turmas com time)' do
      it 'cria/atualiza disciplinas (não cria turmas pois professor é obrigatório)' do
        expect {
          described_class.call(catalog_path)
        }.to change(Disciplina, :count).by(3)
         .and change(Turma, :count).by(0)
         .and change(Professor, :count).by(0)
         .and change(Aluno, :count).by(0)

        bd = Disciplina.find_by(codigo: 'CIC0097')
        es = Disciplina.find_by(codigo: 'CIC0105')
        pc = Disciplina.find_by(codigo: 'CIC0202')

        expect(bd&.nome).to eq('BANCOS DE DADOS')
        expect(es&.nome).to eq('ENGENHARIA DE SOFTWARE')
        expect(pc&.nome).to eq('PROGRAMAÇÃO CONCORRENTE')
      end

      it 'é idempotente ao rodar novamente com o mesmo arquivo' do
        described_class.call(catalog_path)
        expect {
          described_class.call(catalog_path)
        }.to change(Disciplina, :count).by(0)
         .and change(Turma, :count).by(0)
      end
    end

    context 'integração: processando catálogo e depois roster' do
      it 'mantém o nome da disciplina do catálogo e cria a turma com professor e alunos via roster' do
        described_class.call(catalog_path)

        bd = Disciplina.find_by(codigo: 'CIC0097')
        expect(bd&.nome).to eq('BANCOS DE DADOS')

        expect {
          described_class.call(roster_path)
        }.to change(Turma, :count).by(1)
         .and change(Professor, :count).by(1)
         .and change(Aluno, :count).by(3)

        turma = Turma.find_by(disciplina: bd, semestre: '2021.2')
        expect(turma).to be_present
        expect(turma.horario).to be_present 

        expect(turma.professor&.usuario).to eq('83807519491')
        expect(turma.alunos.count).to eq(3)
      end
    end

    context 'quando o arquivo não corresponde a nenhum formato esperado' do
      it 'levanta erro ArgumentError e não cria registros' do
        path = Rails.root.join('spec', 'fixtures', 'files', 'unknown.json')
        File.write(path, JSON.dump([{ 'foo' => 'bar' }]))

        expect {
          described_class.call(path)
        }.to raise_error(ArgumentError, /Formato de entrada não reconhecido/i)

        expect(Disciplina.count).to eq(0)
        expect(Turma.count).to eq(0)
        expect(Professor.count).to eq(0)
        expect(Aluno.count).to eq(0)
      ensure
        File.delete(path) if File.exist?(path)
      end
    end

    context 'verificação de novos registros (new_record?)' do
      it 'identifica corretamente quando um aluno é novo' do
        described_class.call(roster_path)
        
        aluno = Aluno.find_by(matricula: '190084006')
        expect(aluno).to be_present
        expect(aluno.persisted?).to be true
        
        initial_count = Aluno.count
        described_class.call(roster_path)
        
        expect(Aluno.count).to eq(initial_count)
        aluno_recarregado = Aluno.find_by(matricula: '190084006')
        expect(aluno_recarregado.id).to eq(aluno.id)
      end
    end

    context 'forçar registered: false para novos registros' do
      it 'define registered como false ao criar novos alunos' do
        described_class.call(roster_path)
        
        alunos = Aluno.where(matricula: ['190084006', '200033522', '150005491'])
        expect(alunos.count).to eq(3)
        
        alunos.each do |aluno|
          expect(aluno.registered).to eq(false)
        end
      end

      it 'não altera registered de alunos existentes ao reimportar' do
        described_class.call(roster_path)
        
        aluno = Aluno.find_by(matricula: '190084006')
        aluno.update!(registered: true)
        
        described_class.call(roster_path)
        
        aluno.reload
        expect(aluno.registered).to eq(true)
      end
    end

    context 'normalização da matrícula com strip' do
      it 'normaliza matrícula com espaços em branco antes de buscar/criar' do
        path = Rails.root.join('spec', 'fixtures', 'files', 'roster_with_spaces.json')
        data = [
          {
            'code' => 'CIC0097',
            'semester' => '2021.2',
            'classCode' => 'TA',
            'docente' => {
              'usuario' => '83807519491',
              'nome' => 'MARISTELA TERTO DE HOLANDA',
              'email' => 'mholanda@unb.br',
              'departamento' => 'DEPTO CIÊNCIAS DA COMPUTAÇÃO',
              'formacao' => 'DOUTORADO'
            },
            'dicente' => [
              {
                'matricula' => '  190084006  ',
                'usuario' => '190084006',
                'nome' => 'ALUNO TESTE',
                'email' => 'aluno@test.com',
                'curso' => 'CIÊNCIA DA COMPUTAÇÃO/CIC'
              }
            ]
          }
        ]
        File.write(path, JSON.dump(data))

        expect {
          described_class.call(path)
        }.to change(Aluno, :count).by(1)

        aluno = Aluno.find_by(matricula: '190084006')
        expect(aluno).to be_present
        expect(aluno.matricula).to eq('190084006')
        expect(aluno.matricula).not_to include(' ')
      ensure
        File.delete(path) if File.exist?(path)
      end

      it 'evita duplicação ao reimportar matrícula com espaços diferentes' do
        described_class.call(roster_path)
        initial_count = Aluno.count

        path = Rails.root.join('spec', 'fixtures', 'files', 'roster_with_spaces2.json')
        data = [
          {
            'code' => 'CIC0097',
            'semester' => '2021.2',
            'classCode' => 'TA',
            'docente' => {
              'usuario' => '83807519491',
              'nome' => 'MARISTELA TERTO DE HOLANDA',
              'email' => 'mholanda@unb.br',
              'departamento' => 'DEPTO CIÊNCIAS DA COMPUTAÇÃO',
              'formacao' => 'DOUTORADO'
            },
            'dicente' => [
              {
                'matricula' => ' 190084006 ',
                'usuario' => '190084006',
                'nome' => 'ALUNO TESTE ATUALIZADO',
                'email' => 'aluno@test.com',
                'curso' => 'CIÊNCIA DA COMPUTAÇÃO/CIC'
              }
            ]
          }
        ]
        File.write(path, JSON.dump(data))

        expect {
          described_class.call(path)
        }.to change(Aluno, :count).by(0)

        expect(Aluno.count).to eq(initial_count)
        aluno = Aluno.find_by(matricula: '190084006')
        expect(aluno).to be_present
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end
end

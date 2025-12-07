
# frozen_string_literal: true
require 'rails_helper'
 
RSpec.describe ImportJson, type: :service do
  describe '.call' do
    let(:roster_path)  { fixture_file('class_members.json') }
    let(:catalog_path) { fixture_file('classes.json') }

    context 'com JSON no formato de roster (docente/dicente)' do
      it 'cria disciplina, turma, professor e alunos, com associações corretas' do
        expect {
          described_class.call(roster_path)
        }.to change(Disciplina, :count).by(1)
         .and change(Turma, :count).by(1)
         .and change(Professor, :count).by(1)
         .and change(Aluno, :count).by(3)

        disc = Disciplina.find_by(codigo: 'CIC0097')
        turma = Turma.find_by(disciplina: disc, class_code: 'TA', semester: '2021.2')
        prof  = turma.professor

        expect(disc).to be_present
        expect(turma).to be_present

        expect(prof.usuario).to eq('83807519491')
        expect(prof.nome).to eq('MARISTELA TERTO DE HOLANDA')
        expect(prof.email).to eq('mholanda@unb.br')
        expect(prof.departamento).to eq('DEPTO CIÊNCIAS DA COMPUTAÇÃO')
        expect(prof.formacao).to eq('DOUTORADO')
        expect(prof.ocupacao).to eq('docente')

        m1 = Aluno.find_by(matricula: '190084006')
        m2 = Aluno.find_by(matricula: '200033522')
        m3 = Aluno.find_by(matricula: '150005491')

        [m1, m2, m3].each do |al|
          expect(al).to be_present
          expect(al.turma).to eq(turma)
          expect(al.curso).to eq('CIÊNCIA DA COMPUTAÇÃO/CIC')
          expect(al.formacao).to eq('graduando')
          expect(al.ocupacao).to eq('dicente')
          expect(al.usuario).to eq(al.matricula) # conforme o JSON
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
      end
    end

    context 'com JSON no formato de catálogo (disciplinas + turmas com time)' do
      it 'cria disciplinas e turmas com seus atributos (sem professor/alunos)' do
        expect {
          described_class.call(catalog_path)
        }.to change(Disciplina, :count).by(3)
         .and change(Turma, :count).by(3)
         .and change(Professor, :count).by(0)
         .and change(Aluno, :count).by(0)

        bd   = Disciplina.find_by(codigo: 'CIC0097')
        es   = Disciplina.find_by(codigo: 'CIC0105')
        pc   = Disciplina.find_by(codigo: 'CIC0202')
        turma_bd = Turma.find_by(disciplina: bd, class_code: 'TA', semester: '2021.2')

        expect(bd.nome).to eq('BANCOS DE DADOS')
        expect(es.nome).to eq('ENGENHARIA DE SOFTWARE')
        expect(pc.nome).to eq('PROGRAMAÇÃO CONCORRENTE')

        expect(turma_bd.time).to eq('35T45')
        expect(turma_bd.professor).to be_nil
      end

      it 'é idempotente ao rodar novamente com o mesmo arquivo' do
        described_class.call(catalog_path)
        expect {
          described_class.call(catalog_path)
        }.to change(Disciplina, :count).by(0)
         .and change(Turma, :count).by(0)
      end
    end

    context 'processando catálogo e depois roster (integração)' do
      it 'reusa a mesma turma e complementa com professor e alunos' do
        # 1) Cria disciplina e turma via catálogo (com time)
        described_class.call(catalog_path)

        # 2) Importa o roster da mesma oferta (CIC0097 TA 2021.2)
        expect {
          described_class.call(roster_path)
        }.to change(Professor, :count).by(1)
         .and change(Aluno, :count).by(3)
         .and change(Turma, :count).by(0)   # não cria outra turma

        disc = Disciplina.find_by(codigo: 'CIC0097')
        turma = Turma.find_by(disciplina: disc, class_code: 'TA', semester: '2021.2')

        expect(turma.time).to eq('35T45')          # preserva o time do catálogo
        expect(turma.professor&.usuario).to eq('83807519491')
        expect(Aluno.where(turma: turma).count).to eq(3)
      end
    end

    context 'quando o arquivo não corresponde a nenhum formato esperado' do
      it 'levanta erro ArgumentError e não cria registros' do
        path = Rails.root.join('spec', 'fixtures', 'files', 'unknown.json')
        File.write(path, JSON.dump([{ 'foo' => 'bar' }]))

        expect {
          described_class.call(path)
        }.to raise_error(ArgumentError, /Formato de entrada não reconhecido/)

        expect(Disciplina.count).to eq(0)
        expect(Turma.count).to eq(0)
        expect(Professor.count).to eq(0)
        expect(Aluno.count).to eq(0)
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end
end

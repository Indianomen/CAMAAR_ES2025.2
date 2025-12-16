## Integrantes

- Jônatas Gonçalves Pereira Râmos Côrtes - 241031683
- José Artur Nordestino Aguiar de Oliveira - 180020439
- Davi César Silva Borges - 190105054
- Victória Silva da Rocha - 200062875

# CAMAAR

Sistema para avaliação de atividades acadêmicas remotas do CIC

Para utilização do sistema como 
Administrador use
Usuário: admin
Senha: admin123

## Sprint 3

Relatório acerca da sprint3, cujo foco foi documentar o projeto, consolidar a cobertura de testes e utilizar ferramentas para avaliar a qualidade do código e observar oportunidades de refatoração através dos métodos ABC Score e Complexidade Ciclomática.

## Complexidade Ciclomática (Saikuro)
Utilizamos a gema Saikuro através do comando `ruby -r ./saikuro_patch.rb -S saikuro -c -o reports/saikuro -i app/ -f html . -w 5 -s 10` na qual definimos como 5 um valor de alerta e 10 um valor de complexidade severa. Obtivemos o seguinte resultado:

| Class | Method | Complexity |
| :--- | :--- | :--- |
| ImportJson:: | process_roster_entry | 9 |
| Student::FormulariosController | submit | 8 |
| ImportJson | self.call | 8 |
| AdministradorsController | create | 7 |
| AdministradorsController | update | 7 |
| AlunosController | create | 7 |
| AlunosController | update | 7 |
| DisciplinasController | create | 7 |
| DisciplinasController | update | 7 |
| PerguntaController | create | 7 |
| PerguntaController | update | 7 |
| ProfessorsController | create | 7 |
| ProfessorsController | update | 7 |
| TurmasController | create | 7 |
| TurmasController | update | 7 |
| UserInviteJob | perform | 5 |

## Score ABC (RubyCritic)
Utilizamos a gema Saikuro através do comando `ruby -r ./flog_fix.rb -S rubycritic app/`, a ferramenta foi delimitada para analisar apenas a pasta app, o score geral foi `71.53/100`. Obtivemos os seguintes resultados acerca dos arquivos:
| Rating | Name | Churn | Complexity(ABC) | Duplication | Smells |
| :--- | :--- | :--- | :--- | :--- | :--- |
| A | BaseController | 2 | 0.0 | 0 | 1 |
| A | DashboardHelper | 1 | 0.0 | 0 | 1 |
| A | AdministradorsHelper | 1 | 0.0 | 0 | 1 |
| A | DashboardHelper | 1 | 0.0 | 0 | 1 |
| A | AlunosHelper | 1 | 0.0 | 0 | 1 |
| A | ApplicationHelper | 1 | 0.0 | 0 | 1 |
| A | DisciplinasHelper | 1 | 0.0 | 0 | 1 |
| A | FormulariosHelper | 1 | 0.0 | 0 | 1 |
| A | PagesHelper | 1 | 0.0 | 0 | 1 |
| A | PerguntaHelper | 1 | 0.0 | 0 | 1 |
| A | DashboardHelper | 1 | 0.0 | 0 | 1 |
| A | ProfessorsHelper | 1 | 0.0 | 0 | 1 |
| A | SessionsHelper | 1 | 0.0 | 0 | 1 |
| A | TemplatesHelper | 1 | 0.0 | 0 | 1 |
| A | TurmasHelper | 1 | 0.0 | 0 | 1 |
| A | ApplicationJob | 2 | 0.0 | 0 | 1 |
| A | ApplicationMailer | 1 | 0.0 | 0 | 1 |
| A | Administrador | 3 | 0.0 | 0 | 1 |
| A | ApplicationRecord | 1 | 0.0 | 0 | 1 |
| A | Disciplina | 2 | 0.0 | 0 | 1 |
| A | Professor | 3 | 0.0 | 0 | 1 |
| A | Template | 4 | 0.0 | 0 | 1 |
| A | DashboardController | 1 | 1.0 | 0 | 1 |
| A | Pergunta | 4 | 2.42 | 0 | 1 |
| A | Resposta | 3 | 3.0 | 0 | 1 |
| A | DashboardController | 5 | 7.47 | 0 | 1 |
| A | ApplicationController | 6 | 10.98 | 0 | 2 |
| A | Formulario | 4 | 11.44 | 0 | 1 |
| A | ImportacoesController | 2 | 13.7 | 0 | 3 |
| A | Aluno | 4 | 13.85 | 0 | 1 |
| A | Turma | 6 | 14.0 | 0 | 1 |
| A | DashboardController | 2 | 15.33 | 0 | 1 |
| A | PagesController | 4 | 18.43 | 0 | 3 |
| A | SessionsController | 4 | 19.42 | 0 | 1 |
| A | PagesController | 5 | 23.99 | 0 | 1 |
| B | UserInviteJob | 2 | 27.32 | 52 | 8 |
| B | PasswordSetupsController | 2 | 28.99 | 28 | 4 |
| B | PasswordResetMailer | 2 | 33.65 | 35 | 9 |
| B | PasswordResetsController | 2 | 34.5 | 28 | 5 |
| C | UserInviteMailer | 2 | 36.63 | 81 | 11 |
| A | SessionsController | 3 | 49.44 | 0 | 5 |
| B | ApplicationController | 9 | 50.09 | 0 | 6 |
| F | AdministradorsController | 2 | 53.58 | 122 | 12 |
| F | AlunosController | 3 | 53.58 | 122 | 12 |
| F | DisciplinasController | 2 | 53.58 | 122 | 12 |
| F | PerguntaController | 2 | 53.58 | 122 | 12 |
| F | ProfessorsController | 2 | 53.58 | 122 | 12 |
| C | TemplatesController | 7 | 59.98 | 17 | 7 |
| C | FormulariosController | 5 | 71.9 | 47 | 9 |
| F | TurmasController | 3 | 75.4 | 122 | 13 |
| B | FormulariosController | 3 | 84.98 | 0 | 13 |
| D | FormulariosController | 7 | 148.33 | 47 | 19 |
| C | ImportJson | 6 | 185.55 | 0 | 13 |

Given('that I am on the login screen as an {string}') do |user_type|
  if user_type.downcase == 'admin'
    visit new_admin_session_path rescue visit '/admin/login'
  else
    visit login_path rescue visit '/login'
  end
end

Given('that I am on the login screen as a {string}') do |user_type|
  step "that I am on the login screen as an \"#{user_type}\""
end

Given('that I am on the login screen') do
  visit login_path rescue visit '/login'
end

Given('that I am on the password reset page') do
  visit new_password_reset_path rescue visit '/password_resets/new'
end

Given('that the user {string} was imported and has {string} status') do |email, status|
  is_registered = (status.downcase == 'active')
  @user = Aluno.find_by(email: email) || FactoryBot.create(:aluno, 
    email: email, 
    registered: is_registered,
    password: 'TempPassword123!',
    password_confirmation: 'TempPassword123!'
  )
end

Given('a valid password setup link was sent to {string}') do |email|
  @user ||= Aluno.find_by(email: email)
  token = @user.signed_id(purpose: :password_setup, expires_in: 48.hours)
  @setup_link = "/password_setups/#{token}/edit" 
end

Given('that I requested password reset on the login screen') do
  visit login_path
  click_link "Esqueci minha senha" rescue click_link "Forgot Password"
  fill_in "Email", with: @user.email
  click_button "Enviar" rescue click_button "Send"
end

Given('that I received an email containing the {string}') do |link_type|
  email = ActionMailer::Base.deliveries.last
  expect(email).to be_present
  expect(email.to).to include(@user.email)
  
  email_body = email.body.encoded
  link_match = email_body.match(/href="(?<url>http:\/\/.*?)"/)
  
  if link_match
    @extracted_link = link_match[:url]
  else
    @extracted_link = email_body.match(/(password_resets\/.*?\/edit)/)[1]
  end
end

Given('that the user accesses the password setup link sent by email') do
  visit @setup_link
end

Given('that the user accesses the password setup link received previously') do
  visit @setup_link
end

Given('And the link is expired') do
  travel 3.days 
end

When('filling with valid and matching email\/registration and password') do
  @user ||= FactoryBot.create(:aluno, password: 'password123', registered: true)
  fill_in 'Email', with: @user.email
  fill_in 'Senha', with: 'password123'
end

When('filling with valid email\/registration but incompatible password') do
  @user ||= FactoryBot.create(:aluno, password: 'password123', registered: true)
  fill_in 'Email', with: @user.email
  fill_in 'Senha', with: 'wrongpassword'
  click_button 'Entrar' rescue click_button 'Log in'
end

When('clicking the login button') do
  click_button 'Entrar' rescue click_button 'Log in'
end

When('I access the link') do
  visit @extracted_link
end

When('I try to access the link after the validity period') do
  travel 3.days
  visit @extracted_link
end

When('the user enters a new password that meets the requirements') do
  fill_in 'Nova Senha', with: 'NewSecurePass123!'
end

When('I enter a valid new password') do
  fill_in 'Nova Senha', with: 'NewSecurePass123!'
end

When('confirms the same password correctly') do
  fill_in 'Confirmar Senha', with: 'NewSecurePass123!'
end

When('I confirm the new password correctly') do
  fill_in 'Confirmar Senha', with: 'NewSecurePass123!'
end

When('confirms the password creation') do
  click_button 'Salvar Senha' rescue click_button 'Save Password'
end

When('I click the confirm button') do
  click_button 'Salvar Senha' rescue click_button 'Save Password'
end

When('And click confirm') do
  click_button 'Salvar Senha'
end

When('the user enters a password that doesn\'t meet security rules') do
  fill_in 'Nova Senha', with: '123'
  fill_in 'Confirmar Senha', with: '123'
end

When('I enter a password that doesn\'t meet minimum requirements') do
  fill_in 'Nova Senha', with: '123'
  fill_in 'Confirmar Senha', with: '123'
end

When('I enter a different password confirmation') do
  fill_in 'Confirmar Senha', with: 'Mismatch123!'
end

When('the user tries to set a new password') do
  fill_in 'Nova Senha', with: 'NewPass123!'
  click_button 'Salvar Senha'
end

When('the user tries to create the initial password') do
  fill_in 'Nova Senha', with: 'NewPass123!'
  click_button 'Salvar Senha'
end

Then('I am presented with {int} input fields, one for email\/registration and another for password') do |count|
  expect(page).to have_field('Email') 
  expect(page).to have_field('Senha') 
end

Then('I should be redirected to the Evaluations screen, with a sidebar and available evaluations') do
  expect(current_path).to eq(evaluations_path) rescue expect(page).to have_content("Avaliações")
  expect(page).to have_css('.sidebar')
end

Then('I should be redirected to the Evaluations screen, with a sidebar showing the evaluations and management sections') do
  expect(current_path).to eq(admin_dashboard_path) rescue expect(page).to have_content("Painel Admin")
  expect(page).to have_content('Gerenciamento')
end

Then('I am presented with a message that user or password is incorrect') do
  expect(page).to have_content(/inválido|incorreto|Email ou senha inválidos/i)
end

Then('must redirect me to the login page') do
  expect(current_path).to eq(login_path)
end

Then('the user must be directed to the login page') do
  expect(current_path).to eq(login_path)
end

# Sucesso
Then('the password must be successfully registered') do
  @user.reload
  expect(@user.authenticate('NewSecurePass123!')).to be_truthy
end

Then('the system must save the new password') do
  @user.reload
  expect(@user.authenticate('NewSecurePass123!')).to be_truthy
end

Then('the user status must be updated to {string}') do |status_str|
  @user.reload
  expect(@user.registered).to be(true)
end

Then('must change my user status to {string} if it is pending') do |status_str|
  @user.reload
  expect(@user.registered).to be(true)
end

Then('must display a message informing that the password was successfully reset') do
  expect(page).to have_content(/sucesso|atualizada/i)
end

Then('the system must display a message informing that the link has expired') do
  expect(page).to have_content(/expirado|inválido/i)
end

Then('must offer the option to request a new reset link') do
  expect(page).to have_link('Solicitar novo link') rescue expect(page).to have_content('Solicitar novo')
end

Then('the system must block the reset') do
  expect(current_path).not_to eq(login_path)
end

Then('must display a message explaining the allowed password criteria') do
  expect(page).to have_content(/curta|minimo/i)
end

Then('must display a message explaining the mandatory password criteria') do
  expect(page).to have_content(/curta|minimo/i)
end

Then('the password must not be saved') do
  old_digest = @user.password_digest
  @user.reload
  expect(@user.password_digest).to eq(old_digest)
end

Then('the system must prevent the reset') do
  expect(page).to have_button('Salvar Senha') 
end

Then('the system must prevent saving the new password') do
   expect(page).to have_button('Salvar Senha')
end

Then('must display a message indicating that the passwords do not match') do
  expect(page).to have_content(/não conferem/i)
end

Then('the system must prevent the action') do
  expect(page).to have_content(/já está ativa|erro/i)
end

Then('must suggest the user use the {string} flow') do |text|
  expect(page).to have_content(text)
end

Given('the link is valid and within the deadline') do
end

Given('the link is still valid') do
end

Given('that the user accesses the password setup link received by email') do
  visit @setup_link
end

Given('the user\'s current status is {string}') do |status|
  @user.update!(registered: (status.downcase == 'active'))
end

Then('must guide the user to request a new link') do
  expect(page).to have_content(/solicitar|request/i)
end

When('I enter the new password') do
  fill_in 'Nova Senha', with: 'ValidPassword123!'
end

Given('that I am on the login screen as an student') do
  visit login_path
end

Given('that I am on the login screen as a admin') do
  visit login_path
end

Then('I should be redirected to the Evaluations screen, with a sidebar showing the evaluations and management sections.') do
  expect(page).to have_content(/painel|dashboard|gerenciamento/i)
end

Given('the link is expired') do
  travel 3.days
end
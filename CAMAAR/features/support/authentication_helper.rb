module AuthenticationHelper
  def login_as_admin
    # For now, mock the admin session
    # When auth is ready, replace with real login
    admin = Administrador.create!(
      nome: "Admin Test",
      usuario: "admin_test",
      email: "admin@test.com",
      password: "password123",
      password_confirmation: "password123"
    )
    
    # Mock session (adjust based on final auth implementation)
    page.set_rack_session(user_id: admin.id, user_type: 'Administrador')
    
    # OR if using page object pattern
    visit login_path
    fill_in 'Usuário', with: 'admin_test'
    fill_in 'Senha', with: 'password123'
    click_button 'Login'
  end
  
  def visit_admin_screen
    visit '/admin/dashboard'  # Adjust based on actual route
  end
end

World(AuthenticationHelper)
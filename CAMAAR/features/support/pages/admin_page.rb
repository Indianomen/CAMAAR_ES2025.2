module Pages
  class AdminPage
    include Capybara::DSL
    
    def visit_page
      visit '/admin/dashboard'
      self
    end
    
    def click_management
      click_link 'Gerenciamento'
      self
    end
    
    def has_sidebar_menu?
      has_css?('.sidebar-menu')
    end
    
    def has_management_option?
      has_link?('Gerenciamento')
    end
  end
end
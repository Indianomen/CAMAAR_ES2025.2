class DashboardController < ApplicationController
  def index
    case current_user.role
    when 'admin'
      @templates = Template.all
      @pending_forms = Forms.pending.count
      @submitted_forms = Forms.submitted.count
    when 'professor'
      @my_forms = current_user.forms_as_professor
    when 'student'
      @pending_forms = current_user.forms_as_student.pending
      @submitted_forms = current_user.forms_as_student.submitted
    end
  end
end

require 'rails_helper'

RSpec.describe Admin::FormulariosController, type: :routing do
  it "roteia results como member" do
    expect(get: "/admin/formularios/1/results")
      .to route_to("admin/formularios#results", id: "1")
  end

  it "roteia export_csv como member" do
    expect(get: "/admin/formularios/1/export_csv")
      .to route_to("admin/formularios#export_csv", id: "1")
  end
end

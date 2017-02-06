require 'rails_helper'

RSpec.describe "layouts/application", type: :view do

  before do
    allow_any_instance_of(ActionController::TestRequest).to receive(:original_url).and_return('')
  end

  it "can render" do
    render
  end
end

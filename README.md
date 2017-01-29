This repository reproduces an error in the rails-bootstrap-navbar gem.

# Problem
navbar_item can not receive a link without throwing an error in the test environment. It does not matter if the link is generated with the '[input destination here]_path' helper or if it is hard coded.
Notice that navbar_header can receive a 'brand_link' without any trouble.

### My navbar code
```ruby
# app/views/layouts/application.html.erb

  <%= navbar do %>
    <%= navbar_header brand: 'Home', brand_link: root_path %>
    <%= navbar_collapse do %>
      <%= navbar_group do %>
        <%= navbar_item "Root", root_path %>
      <% end %>
    <% end %>
  <% end %>
```

Problem arises during a view spec.
When rendering takes place, the following is printed in terminal

```shell
Failure/Error: <%= navbar_item "Root", root_path %>

     ActionView::Template::Error:
       bad URI(is not URI?): http://test.hostNo route matches {:action=>"application", :controller=>"layouts"}
     # ./app/views/layouts/application.html.erb:17:in `block (3 levels) in _app_views_layouts_application_html_erb__4503369544053172873_70210535674700'
     # ./app/views/layouts/application.html.erb:16:in `block (2 levels) in _app_views_layouts_application_html_erb__4503369544053172873_70210535674700'
     # ./app/views/layouts/application.html.erb:15:in `block in _app_views_layouts_application_html_erb__4503369544053172873_70210535674700'
     # ./app/views/layouts/application.html.erb:13:in `_app_views_layouts_application_html_erb__4503369544053172873_70210535674700'
     # ./spec/views/layouts/application.html.erb_spec.rb:5:in `block (2 levels) in <top (required)>'
     # ------------------
     # --- Caused by: ---
     # URI::InvalidURIError:
     #   bad URI(is not URI?): http://test.hostNo route matches {:action=>"application", :controller=>"layouts"}
     #   ./app/views/layouts/application.html.erb:17:in `block (3 levels) in _app_views_layouts_application_html_erb__4503369544053172873_70210535674700'
```

# Tracing it to this gem
To trace the problem to this gem, i did two things.

1. Replaced 'root_path' with hard coded path to rule out the '[input destination here]_path' helper
```ruby
# app/views/layouts/application.html.erb

  <%= navbar do %>
    <%= navbar_header brand: 'Home', brand_link: root_path %>
    <%= navbar_collapse do %>
      <%= navbar_group do %>
        <%= navbar_item "Root", "/test" %>
      <% end %>
    <% end %>
  <% end %>
```
This failed, with the following stack trace
```shell
Failure/Error: <%= navbar_item "Root", '/test' %>

     ActionView::Template::Error:
       bad URI(is not URI?): http://test.hostNo route matches {:action=>"application", :controller=>"layouts"}
     # ./app/views/layouts/application.html.erb:17:in `block (3 levels) in _app_views_layouts_application_html_erb__2238483034105279321_70189671204360'
     # ./app/views/layouts/application.html.erb:16:in `block (2 levels) in _app_views_layouts_application_html_erb__2238483034105279321_70189671204360'
     # ./app/views/layouts/application.html.erb:15:in `block in _app_views_layouts_application_html_erb__2238483034105279321_70189671204360'
     # ./app/views/layouts/application.html.erb:13:in `_app_views_layouts_application_html_erb__2238483034105279321_70189671204360'
     # ./spec/views/layouts/application.html.erb_spec.rb:5:in `block (2 levels) in <top (required)>'
     # ------------------
     # --- Caused by: ---
     # URI::InvalidURIError:
     #   bad URI(is not URI?): http://test.hostNo route matches {:action=>"application", :controller=>"layouts"}
     #   ./app/views/layouts/application.html.erb:17:in `block (3 levels) in _app_views_layouts_application_html_erb__2238483034105279321_70189671204360'
```

2. Removed the URL from the 'navbar_item' and placed it by itself.
```ruby
# app/views/layouts/application.html.erb

  <%= navbar do %>
    <%= navbar_header brand: 'Home', brand_link: root_path %>
    <%= navbar_collapse do %>
      <%= navbar_group do %>
        <%= navbar_item "Root" %>
      <% end %>
    <% end %>
  <% end %>

  <%= root_path %>
```
This worked without any errors.

# The test
```ruby
# spec/views/layouts/application.html.erb_spec.rb

require 'rails_helper'

RSpec.describe "layouts/application", type: :view do
  it "can render" do
    render
  end
end
```

# Environment information

__Tested on two different Operating Systems__
- OS-1: OS X 10.11.5
- OS-2: macOS 10.12

__Ruby and gem versions:__
- Ruby: ruby 2.3.3p222 (2016-11-21 revision 56859) [x86_64-darwin15]
- Using rails 5.0.1
- Using bootstrap-sass 3.3.7
- Using rails_bootstrap_navbar 2.0.1
- Using rspec 3.5.0

# NeoComponents

A reusable UI component library for Blackboard LMS. Provides ViewComponent helpers, ERB partials, Tailwind CSS styles, SVG icons, and Stimulus.js controllers.

## Installation

Add to your `Gemfile`:

```ruby
gem 'neo_components', github: 'openvitae-tech/neo_components'
```

Then run:

```bash
bundle install
```

### Asset setup

The gem ships several CSS files. Require them in your `application.css`:

```css
*= require icons
*= require tooltip
*= require custom
*= require course_progress
*= require carousel
```

### Tailwind content scanning

Add the gem's view paths to your `tailwind.config.js` so Tailwind scans component templates:

```js
content: [
  // ...your existing paths
  "./path/to/gems/neo_components/app/views/**/*.html.erb",
  "./path/to/gems/neo_components/app/helpers/**/*.rb",
]
```

### JavaScript

Stimulus controllers are registered automatically via importmap. No additional setup required.

## Usage

All helpers are automatically included into `ActionView::Base` by the engine. Use them directly in any view or helper.

### Icons

```erb
<%= icon 'chevron-right', css: 'w-4 h-4 text-primary' %>
```

### Button

```erb
<%= button_component text: 'Save', size: 'sm', type: 'outline',
                     icon_name: 'check', icon_position: 'right' %>
```

### Chip

```erb
<%= chip_component(text: 'Category', colorscheme: 'primary', icon_name: 'check') %>
```

### Accordion

```erb
<%= accordion_component header: 'Section Title' do %>
  Content goes here
<% end %>
```

### Carousel

```erb
<%= carousel_component cards: card_html_array, loop: true %>
```

### Breadcrumbs

```erb
<%= breadcrumbs_component links: [['Home', root_path], ['Current Page', nil]] %>
```

### Modal

```erb
<%= modal_component %>
<%= modal_box_component variant: :success %>
```

### Progress bar

```erb
<%= progressbar_component percentage: 75 %>
```

### Profile icon

```erb
<%= profile_icon_component name: 'John Doe' %>
```

### Menu

```erb
<%= menu_component items: menu_items %>
```

### Cards

```erb
<%= course_card_component course: @course, enrollment: @enrollment %>
<%= long_course_card_component course: @course %>
<%= program_card_component program: @program, enrolled_program_ids: enrolled_ids %>
<%= long_program_card_component program: @program, enrolled_program_ids: enrolled_ids %>
```

`enrolled_program_ids` should be a `Set` of program IDs the current user is enrolled in, computed once before iterating:

```ruby
enrolled_program_ids = current_user.program_ids.to_set
```

### Inputs

```erb
<%= input_text_component name: :email, placeholder: 'Email',
                          icon_name: 'at-symbol', icon_position: 'left' %>

<%= input_checkbox_component name: :agree, label: 'I agree' %>

<%= input_radio_component name: :role, value: 'admin', label: 'Admin' %>

<%= dropdown_component name: :status, options: [['Active', 'active'], ['Inactive', 'inactive']] %>

<%= textarea_component name: :description, placeholder: 'Enter description' %>

<%= file_selector_component name: :attachment %>

<%= date_select_component name: :date %>
```

## UI Showcase

The gem ships a built-in showcase to preview all components. Mount the engine in your `routes.rb`:

```ruby
mount NeoComponents::Engine => '/neo_components'
```

Then visit `/neo_components/ui` to browse all available components.

To protect the showcase behind authentication, configure a filter in an initializer:

```ruby
NeoComponents.authentication_filter = :authenticate_admin!
```

## Local Development

To work on this gem alongside a host app, see the [host app README](https://github.com/openvitae-tech/blackboard-lms) for instructions on pointing Bundler to your local checkout.

## License

MIT

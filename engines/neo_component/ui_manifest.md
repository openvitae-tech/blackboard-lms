# NeoComponent UI Manifest

Reference for all current NeoComponent helpers in `engines/neo_component/app/helpers/view_component/`.
This is the primary reference for AI agents when building views. Old/deprecated helpers are excluded.

---

## Button

### `button_component`
```ruby
button_component(
  text: '',
  type: 'solid',          # solid | outline
  size: 'md',             # sm | md | lg
  colorscheme: 'primary', # primary | secondary | danger
  icon_name: '',
  icon_position: 'left',  # left | right
  tooltip_text: '',
  tooltip_position: 'bottom', # top | left | bottom | right
  disabled: false,
  hide_label_in_mobile: false,
  html_options: {}
)
```

---

## Icon

### `icon`
```ruby
icon(
  icon_name,              # String — name of the icon file (without extension)
  css: nil,               # CSS classes on the SVG element
  span_css: nil,          # CSS classes on the wrapper span
  stroke_width: nil
)
```

---

## Typography

### `h1_component`
```ruby
h1_component(text: '', html_options: {})
```

### `h2_component`
```ruby
h2_component(text: '', html_options: {})
```

### `h3_component`
```ruby
h3_component(text: '', html_options: {})
```

### `text_component`
```ruby
text_component(
  text: '',
  tag: 'span',            # Any HTML tag — span | p | div etc.
  html_options: {}
)
```

### `link_component`
```ruby
link_component(
  text:,
  url: '#',
  target: '_self',        # _self | _blank
  html_options: {}
)
```

---

## Input

### `input_text_component`
```ruby
input_text_component(
  form: nil,
  name: nil,
  label: nil,
  type: 'text',           # text | password | email | number etc.
  placeholder: 'Placeholder',
  value: '',
  subtext: nil,
  error: nil,
  icon_name: nil,
  icon_position: 'right', # left | right
  disabled: false,
  size: 'md',             # md | lg
  html_options: {}
)
```

### `input_radio_component`
```ruby
input_radio_component(
  form: nil,
  name: nil,
  label: nil,
  value: nil,
  disabled: false,
  error: nil,
  label_position: 'right', # left | right
  html_options: {}
)
```

### `input_checkbox_component`
```ruby
input_checkbox_component(
  form: nil,
  name: nil,
  label: nil,
  value: nil,
  disabled: false,
  error: nil,
  label_position: 'right', # left | right
  html_options: {}
)
```

### `textarea_component`
```ruby
textarea_component(
  name:,
  placeholder:,
  form: nil,
  label: nil,
  value: nil,
  rows: 1,
  size: 'md',             # md | lg
  support_text: nil,
  error: nil,
  disabled: false,
  html_options: {}
)
```

### `dropdown_component`
```ruby
dropdown_component(
  form: nil,
  name: nil,
  label: nil,
  options: [],            # Array of [label, value] pairs or ActiveRecord collection
  value: nil,
  size: 'md',             # md | lg
  support_text: nil,
  error: nil,
  disabled: false,
  html_options: {},
  prompt: nil
)
```

### `date_picker_component`
```ruby
date_picker_component(
  form: nil,
  name: nil,
  label: nil,
  value: nil,
  placeholder: nil,
  size: 'md',             # md | lg
  support_text: nil,
  error: nil,
  disabled: false,
  html_options: {}
)
```

### `file_selector_component`
```ruby
file_selector_component(
  type:,                  # image | document | video
  form: nil,
  name: nil,
  label: nil,
  support_text: nil,
  support_text_two: nil,
  error: nil,
  disabled: false,
  html_options: {}
)
```

### `input_mobile_component`
```ruby
input_mobile_component(
  form: nil,
  name: nil,
  label: nil,
  placeholder: 'Enter your mobile number',
  country_code: '',
  value: '',
  subtext: nil,
  error: nil,
  icon_name: nil,
  icon_position: 'right', # left | right
  disabled: false,
  size: 'md',             # md | lg
  html_options: {}
)
```

---

## Chip

### `chip_component`
```ruby
chip_component(
  text: '',
  icon_name: nil,
  close: false,
  colorscheme: 'primary'  # primary | primary_lite | danger | input
)
```

---

## Card

### `course_card_component`
```ruby
course_card_component(
  title:,
  banner_url:,
  duration:,
  modules_count:,
  enroll_count:,
  categories: [],
  rating: nil,
  progress: nil,
  badge: nil,              # nil or Hash with :text, optional :bg_color, :text_color
  description: nil,
  highlights: []
)
```

### `long_course_card_component`
```ruby
long_course_card_component(
  title:,
  banner_url:,
  duration:,
  modules_count:,
  enroll_count:,
  categories: [],
  rating: nil,
  progress: nil,
  badge: nil,              # nil or Hash with :text, optional :bg_color, :text_color
  description: nil,
  highlights: []
)
```

### `program_card_component`
```ruby
program_card_component(program:, enrolled_program_ids:)
```

### `long_program_card_component`
```ruby
long_program_card_component(program:, enrolled_program_ids:)
```

### `certificate_card_component`
```ruby
certificate_card_component(certificate:, thumbnail_url: nil)
```

---

## Navigation

### `breadcrumbs_component`
```ruby
breadcrumbs_component(links: [])
# links: Array of { label:, url: } hashes. Last item is current page (no link rendered).
```

### `menu_component`
```ruby
menu_component(
  menu_items:,            # Array of MenuItem structs
  position: 'right',      # left | right | center
  html_options: {}
)
```

**`MenuItem` struct:**
```ruby
MenuItem = Struct.new(:label, :url, :type, :options, :extra_classes)
```

### `paginator_component`
```ruby
paginator_component(collection:, path:)
```

---

## Modal

### `modal_box_component`
```ruby
modal_box_component(
  title: nil,
  variant: nil,
  modal_footer: nil,
  html_options: {},
  &block                  # Modal body content
)
```

---

## Notification

### `notification_bar`
```ruby
notification_bar(
  text: nil,
  text_color: 'text-letter-color',
  bg_color: 'bg-white',
  icon_color: 'bg-letter-color'
)
```

---

## Progress

### `progressbar_component`
```ruby
progressbar_component(numerator:, denominator:)
```

---

## Profile

### `profile_icon_component`
```ruby
profile_icon_component(
  letter:,
  size: 'md'              # sm | md | lg
)
```

---

## Carousel

### `carousel_component`
```ruby
carousel_component(
  cards:,
  loop: false,
  enable_in_small_devices: true
)
```

### `course_carousal_component`
```ruby
course_carousal_component(courses:, title:, count:, load_path:)
```

---

## Accordion

### `accordion_component`
```ruby
accordion_component(
  header:,
  icon_position: 'right', # left | right
  open: false,
  wrapper_class: '',
  &block                  # Accordion body content
)
```

---

## Section

### `doc_section_component`
```ruby
doc_section_component(title: '', &block)
```

---

## Course Select

### `course_select_component`
```ruby
course_select_component(
  search_context:,
  submit_path:,
  courses: [],
  tags: [],
  cancel_link: nil,
  show_duration: false
)
```

---

## Member List

### `member_list_component`
```ruby
member_list_component(team:, members:, all_members: false, term: '')
```

---

## Typography CSS Classes

For body text and labels, use these CSS classes directly on HTML elements or via `text_component`.
Defined in `typography.tailwind.css`. Font is **Poppins** for headings/main text, **Roboto** for general/secondary text.

### Headings (Poppins, semibold)

| Class | Mobile | Desktop |
|-------|--------|---------|
| `heading-3xl` | text-2xl semibold | text-3xl semibold |
| `heading-2xl` | text-xl semibold | text-2xl semibold |
| `heading-xl` | text-lg semibold | text-xl semibold |

### Main Text (Poppins)

| Class | Mobile | Desktop | Weight |
|-------|--------|---------|--------|
| `main-text-lg-semibold` | text-base | text-lg | semibold |
| `main-text-lg-medium` | text-base | text-lg | medium |
| `main-text-lg-normal` | text-base | text-lg | normal |
| `main-text-md-semibold` | text-sm | text-base | semibold |
| `main-text-md-medium` | text-sm | text-base | medium |
| `main-text-md-normal` | text-sm | text-base | normal |
| `main-text-sm-medium` | text-xs | text-sm | medium |
| `main-text-sm-normal` | text-xs | text-sm | normal |

### General Text (Roboto)

| Class | Mobile | Desktop | Weight |
|-------|--------|---------|--------|
| `general-text-lg-normal` | text-sm | text-base | normal |
| `general-text-md-medium` | text-xs | text-sm | medium |
| `general-text-md-normal` | text-xs | text-sm | normal |
| `general-text-sm-medium` | text-xs | text-xs | medium |
| `general-text-sm-normal` | text-xs | text-xs | normal |

> **When to use what:**
> Use `h1/h2/h3_component` for structural page headings.
> Use typography CSS classes directly on HTML elements for body text, labels, and descriptions — do not wrap them in `text_component`.

---

## Deprecated Components

These helpers are old and should be replaced whenever encountered in existing views.
Do not use them in new code.

| Deprecated | Replace with |
|------------|-------------|
| `button` | `button_component` |
| `input_field` | `input_text_component` |
| `input_checkbox` | `input_checkbox_component` |
| `input_radio` | `input_radio_component` |
| `input_dropdown` | `dropdown_component` |
| `input_mobile` | `input_mobile_component` |
| `date_select_component` | `date_picker_component` |
| `input_textarea_component` | `textarea_component` |
| `menu_component_old` | `menu_component` |
| `heading_component` | `h1_component` / `h2_component` / `h3_component` |
| `link_text_component` | `link_component` |

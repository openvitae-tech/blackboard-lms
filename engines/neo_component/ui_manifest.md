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

### `multi_select_component`
```ruby
multi_select_component(
  form: nil,
  name: nil,
  label: nil,
  options: [],            # Array of [label, value] pairs
  value: [],              # Array of selected values
  placeholder: nil,
  size: 'md',             # md | lg
  support_text: nil,
  error: nil,
  disabled: false,
  html_options: {}
)
```
# Selected values render as removable chips (chip_component, colorscheme: 'input').
# Dropdown lists only unselected options. Managed by the multi-select Stimulus controller.
# Form submission sends selected values as an array param via hidden inputs.

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
  multiple: false,        # true enables multi-file selection with a removable file list below the drop zone
  accept: nil,            # overrides the default accepted MIME/extension list for the given type
  html_options: {}
)
```

# When multiple: true, selected files appear as a removable list below the drop zone.
# Icons: play-circle for video/audio files, document-text for all other types.
# The drop zone remains visible so the user can keep adding files.
# When using file_field_tag (no form:), suffix the name with [] (e.g. "docs[]") so
# Rails receives an array param on submission.

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
  colorscheme: 'primary'  # primary | primary_lite | danger | input | secondary | gold
)
```

---

## Card

### `course_card_component`
```ruby
course_card_component(
  title:,
  banner_url:,
  modules_count:,
  duration: nil,           # omit to hide the duration badge
  enroll_count: nil,       # omit to hide the enrolment row
  modules_label: 'Lesson', # override label, e.g. 'Document' for Classroom Kit cards
  categories: [],
  rating: nil,
  progress: nil,
  badge: nil,              # nil or Hash with :label, optional :bg_color, :text_color
  description: nil,
  highlights: [],
  type_tag: nil            # nil or Hash with :label, :bg_color — renders a full-width coloured footer strip
                           #   text colour is always text-grey-300 (hardcoded in template)
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
  badge: nil,              # nil or Hash with :label, optional :bg_color, :text_color
  description: nil,
  highlights: [],
  checkbox: false          # false to hide; or a Hash of check_box_tag options (truthy non-Hash raises ArgumentError)
                           #   Hash keys: :name (field name), :value, :checked (Boolean), :id,
                           #   plus any other HTML attributes (e.g. data-*, class overrides).
                           #   The checkbox is rendered absolute top-right (top-4 right-4) and
                           #   its click event is stopped from bubbling so it does not trigger
                           #   a parent link/card click handler.
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

### `content_type_card_component`
```ruby
content_type_card_component(
  title:,                 # Card heading
  description:,           # Short body text
  icon_name:,             # Icon name (see icon helper)
  radio_value:,           # Value submitted when this card is selected
  radio_name:,            # Radio group name (shared across cards in the same group)
  highlights: [],         # Array of strings — rendered as a bulleted list with plain dot markers
  caption: nil,           # Optional footer note (shown below a divider line)
  selected: false,        # Pre-select this card
  disabled: false         # Muted, non-interactive state
)
```

The entire card is a `<label>` wrapping a hidden `<input type="radio">` — clicking anywhere selects it.

**Visual states:**
- **Default** — white background, `border-line-colour`
- **Hover** — `border-primary`
- **Selected** — `border-primary` + `ring-2 ring-primary`; icon background unchanged (`bg-secondary-light`), radio dot appears
- **Disabled** — `opacity-40`, `pointer-events-none`, non-interactive

**Example — three content-type options, first pre-selected:**
```ruby
content_type_card_component(
  title: 'Video Course',
  description: 'AI-generated video lessons with narration.',
  icon_name: 'play-circle',
  radio_name: 'course[content_type]',
  radio_value: 'video',
  highlights: ['HD video generation', 'Auto narration', 'Scene editor'],
  caption: 'Recommended for most courses',
  selected: true
)

content_type_card_component(
  title: 'Text Course',
  description: 'Written lessons without video content.',
  icon_name: 'document-text',
  radio_name: 'course[content_type]',
  radio_value: 'text',
  highlights: ['Fast to create', 'Markdown support']
)

content_type_card_component(
  title: 'Live Session',
  description: 'Instructor-led sessions scheduled in real time.',
  icon_name: 'camera',
  radio_name: 'course[content_type]',
  radio_value: 'live',
  highlights: ['Calendar integration', 'Recording support'],
  disabled: true
)
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
MenuItem = Struct.new(:label, :url, :type, :options, :extra_classes, :icon)
# icon: optional icon name string (e.g. 'trash', 'arrow-down-tray') — renders a 16px icon before the label
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
progressbar_component(
  numerator:,
  denominator:,
  color: :primary,    # :primary | :secondary | :secondary_dark | :danger — bar fill color
  full_width: false,  # true stretches to w-full; default is w-[52px] md:w-[120px]
  thin: false,        # true renders a 3px bar (no border); default is 6-8px with border
  animated: false     # true applies a flowing blue→cyan→teal→green gradient; width still reflects fill %
)
```

**Variants**
```ruby
# Standard
progressbar_component(numerator: 30, denominator: 100)

# Full width
progressbar_component(numerator: 30, denominator: 100, full_width: true)

# Thin (3 px, no border) — use inside cards or compact layouts
progressbar_component(numerator: 30, denominator: 100, full_width: true, thin: true)

# Thin + animated gradient — use while generation is in progress
progressbar_component(numerator: 30, denominator: 100, full_width: true, thin: true, animated: true)

# Thin + secondary_dark (green) — use for verification progress
progressbar_component(numerator: 3, denominator: 15, full_width: true, thin: true, color: :secondary_dark)
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

## Wizard Steps

### `wizard_steps_component`
```ruby
wizard_steps_component(
  steps:,        # Array of { icon_name: String, label: String }
  current_step:  # Integer, 0-indexed
)
```
Renders a multi-step progress header. Steps before `current_step` are styled as completed, the step at `current_step` is active, and remaining steps are upcoming. Circles are connected by horizontal lines.

**Example — 3-step wizard, second step active:**
```ruby
wizard_steps_component(
  steps: [
    { icon_name: 'document-text', label: 'Upload doc' },
    { icon_name: 'camera',        label: 'Configure Video' },
    { icon_name: 'numbered-list', label: 'Course Structure' }
  ],
  current_step: 1   # 0-indexed — step 1 is active, step 0 is completed
)
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

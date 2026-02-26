require "administrate/base_dashboard"

class WebsiteDetailDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    about: Field::Text,
    address_1: Field::String,
    address_2: Field::String,
    email: Field::String,
    facebook: Field::String,
    instagram: Field::String,
    linkedin: Field::String,
    name: Field::String,
    phone_1: Field::String,
    phone_2: Field::String,
    social_media_1: Field::String,
    social_media_2: Field::String,
    twitter: Field::String,
    youtube: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    about
    address_1
    address_2
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    about
    address_1
    address_2
    email
    facebook
    instagram
    linkedin
    name
    phone_1
    phone_2
    social_media_1
    social_media_2
    twitter
    youtube
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    about
    address_1
    address_2
    email
    facebook
    instagram
    linkedin
    name
    phone_1
    phone_2
    social_media_1
    social_media_2
    twitter
    youtube
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how website details are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(website_detail)
  #   "WebsiteDetail ##{website_detail.id}"
  # end
end

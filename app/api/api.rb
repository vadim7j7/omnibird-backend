# frozen_string_literal: true

require 'grape-swagger'

class Api < Grape::API
  CURRENT_VERSION = 'v1'

  # Settings
  format 'json'
  prefix :api
  version CURRENT_VERSION

  # Include concerns
  # include Handler....

  # Add middlewares
  # use Middlewares::...

  # Importing helpers and some modules
  # ...

  # Init some helpers
  helpers do
    # Skip....
  end

  # Call callbacks
  before do
    # Skip...
  end

  # Mounting endpoints
  # mount(Endpoints::InitPage)
  # ....

  desc 'Root Api Endpoint'
  get '/' do
    { name: 'OmniBird Backend Api',
      version: CURRENT_VERSION }
  end

  # Init Swagger documentation
  add_swagger_documentation(
    doc_version: '1.0.0',
    info: {
      title: 'OmniBird Api',
      description: 'Private/Public api'
    },
    security_definitions: {
      api_key: {
        type: 'apiKey',
        name: 'Authorization',
        in: 'header'
      }
    },
    security: [ { api_key: [] } ]
  )
end

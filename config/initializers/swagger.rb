# frozen_string_literal: true

GrapeSwaggerRails.options.url     = '/api/v1/swagger_doc'
GrapeSwaggerRails.options.app_url = ENV.fetch('API_FULL_URI')

GrapeSwaggerRails.options.api_auth     = Constants::JWT_TOKEN_SCHEME
GrapeSwaggerRails.options.api_key_name = 'Authorization'
GrapeSwaggerRails.options.api_key_type = 'header'

GrapeSwaggerRails.options.hide_url_input = true

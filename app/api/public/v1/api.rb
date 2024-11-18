# frozen_string_literal: true

module Public
  module V1
    class Api < Grape::API
      CURRENT_VERSION = 'v1'

      # Settings
      format 'json'
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

      namespace :public do
        # Mounting endpoints
        mount(Public::V1::Endpoints::Tracking)
      end
    end
  end
end

# frozen_string_literal: true

module Internal
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

      namespace :internal do
        # Mounting endpoints
        mount(Endpoints::Auth)
        mount(Endpoints::ActionRules)
        mount(Endpoints::Contacts)
        mount(Endpoints::Sequences)
        mount(Endpoints::Integrations)

        desc 'Root Api Endpoint' do
          summary('Api Info')
          success(Entities::RootInfoEntity)
        end
        get '/' do
          data = { name: 'OmniBird Backend Api', version: CURRENT_VERSION }

          present(data, with: Entities::RootInfoEntity)
        end
      end
    end
  end
end

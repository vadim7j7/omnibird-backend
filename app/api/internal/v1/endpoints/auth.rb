# frozen_string_literal: true

module Internal
  module V1
    module Endpoints
      class Auth < Grape::API
        namespace :auth do
          desc 'Check access for current user and current account' do
            summary('Current user and Current account')
            failure(Entities::Constants::FAILURE_READ_DELETE)
          end
          get '/' do
            authenticate!
            load_account!

            status(:no_content)
          end

          namespace :oauth do
            desc 'Get list of oAuth providers' do
              summary('List of oAuth providers')
              success(Entities::Auth::OauthProvidersEntity)
              failure(Entities::Constants::FAILURE_PUBLIC)
            end
            get '/' do; end

            route_param :provider do
              desc 'Issue an URL for oAuth2' do
                summary('oAuth URL')
                success(Entities::Integrations::AuthUrlEntity)
                failure(Entities::Constants::FAILURE_CREATE_UPDATE)
              end
              params do
                requires(:provider, type: String, values: Connection.providers.keys)
              end
              post '/' do; end
            end
          end
        end
      end
    end
  end
end

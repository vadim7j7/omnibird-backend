# frozen_string_literal: true

module Internal
  module V1
    module Endpoints
      class Integrations < Grape::API
        namespace :integrations do
          desc 'Get list of integrations' do
            summary('List of integrations')
            success(Entities::Integrations::ItemsEntity)
            failure(Entities::Constants::FAILURE_READ_DELETE)
          end
          get '/' do; end

          route_param :id do
            desc 'Delete an integration by id' do
              summary('Delete an integration')
              success(code: 204)
              failure(Entities::Constants::FAILURE_READ_DELETE)
            end
            delete '/' do
              status(:no_content)
            end
          end

          route_param :provider do
            desc 'Issue an integration URL for oAuth2' do
              summary('oAuth integration url')
              success(Entities::Integrations::AuthUrlEntity)
              failure(Entities::Constants::FAILURE_CREATE_UPDATE)
            end
            params do
              requires(:provider, type: String, values: Connection.providers.keys)
            end
            post '/' do; end
          end

          route_param :code do
            desc 'Connect an integration by code' do
              summary('Connect by code')
              success(Entities::Integrations::ItemEntity)
              failure(Entities::Constants::FAILURE_READ_DELETE)
            end
            params do
              requires(:code, type: String)
            end
            patch '/' do; end
          end
        end
      end
    end
  end
end

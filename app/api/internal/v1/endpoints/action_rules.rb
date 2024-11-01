# frozen_string_literal: true

module Internal
  module V1
    module Endpoints
      class ActionRules < Grape::API
        namespace :action_rules do
          desc 'Get list of action rules' do
            summary('List of action rules')
            success(Entities::ActionRules::ItemsEntity)
            failure(Entities::Constants::FAILURE_READ_DELETE)
          end
          get '/' do; end

          desc 'Create an action rules' do
            summary('Create a new action rules')
            success(Entities::ActionRules::ItemEntity)
            failure(Entities::Constants::FAILURE_CREATE_UPDATE)
          end
          post '/' do; end

          route_param :id do
            desc 'Delete an action rules' do
              summary('Delete an action rules')
              success(code: 204)
              failure(Entities::Constants::FAILURE_READ_DELETE)
            end
            delete '/' do
              status(:no_content)
            end
          end
        end
      end
    end
  end
end

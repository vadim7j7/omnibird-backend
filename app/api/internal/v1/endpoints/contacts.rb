# frozen_string_literal: true

module Internal
  module V1
    module Endpoints
      class Contacts < Grape::API
        namespace :contacts do
          desc 'Get list of contacts' do
            summary('List of contacts')
            success(Entities::Contacts::ItemsEntity)
            failure(Entities::Constants::FAILURE_READ_DELETE)
          end
          get '/' do; end

          desc 'Create a contact' do
            summary('Create a new contact')
            success(Entities::Contacts::ItemEntity)
            failure(Entities::Constants::FAILURE_CREATE_UPDATE)
          end
          post '/' do; end

          route_param :id do
            desc 'Get a contact by id' do
              summary('Get a contact')
              success(Entities::Contacts::ItemEntity)
              failure(Entities::Constants::FAILURE_READ_DELETE)
            end
            get '/' do; end

            desc 'Update a contact by id' do
              summary('Update a contact')
              success(Entities::Contacts::ItemEntity)
              failure(Entities::Constants::FAILURE_CREATE_UPDATE)
            end
            patch '/' do; end

            desc 'Delete a contact by id' do
              summary('Delete a contact')
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

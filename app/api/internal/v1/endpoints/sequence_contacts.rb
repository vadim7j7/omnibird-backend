# frozen_string_literal: true

module Internal
  module V1
    module Endpoints
      class SequenceContacts < Grape::API
        namespace :sequence_contacts do
          desc 'Get list of contacts from sequence' do
            summary('List of contacts from a sequence')
            success(Entities::Contacts::ItemsEntity)
            failure(Entities::Constants::FAILURE_READ_DELETE)
          end
          get '/' do; end

          desc 'Add or create a contact to a sequence' do
            summary('Add a contact to a sequence')
            success(Entities::Contacts::ItemEntity)
            failure(Entities::Constants::FAILURE_CREATE_UPDATE)
          end
          post '/' do; end

          route_param :record_id do
            desc 'Delete a contact by id from sequence' do
              summary('Delete a contact from a sequence')
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

# frozen_string_literal: true

module Internal
  module V1
    module Endpoints
      class Sequences < Grape::API
        helpers ::Helpers::SharedParams::Main
        helpers ::Helpers::SharedParams::SequenceHelper

        namespace :sequences do
          params do
            use(:pagination)
          end
          desc 'Get list of sequences' do
            summary('List of sequences')
            success(Entities::Sequences::ItemsEntity)
            failure(Entities::Constants::FAILURE_READ_DELETE)
          end
          get '/' do; end

          desc 'Create a sequence' do
            summary('Create a new sequence')
            success(Entities::Sequences::ItemPreviewEntity)
            failure(Entities::Constants::FAILURE_CREATE_UPDATE)
          end
          params { use(:sequence_create_params) }
          post '/' do; end

          route_param :id do
            desc 'Get a sequence by id' do
              summary('Get a sequence')
              success(Entities::Sequences::ItemEntity)
              failure(Entities::Constants::FAILURE_READ_DELETE)
            end
            get '/' do; end

            desc 'Update a sequence by id' do
              summary('Update a sequence')
              success(Entities::Sequences::ItemEntity)
              failure(Entities::Constants::FAILURE_CREATE_UPDATE)
            end
            patch '/' do; end

            desc 'Delete a sequence by id' do
              summary('Delete a sequence')
              success(code: 204)
              failure(Entities::Constants::FAILURE_READ_DELETE)
            end
            delete '/' do
              status(:no_content)
            end

            mount(SequenceContacts)
          end
        end
      end
    end
  end
end

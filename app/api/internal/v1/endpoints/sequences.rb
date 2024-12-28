# frozen_string_literal: true

module Internal
  module V1
    module Endpoints
      class Sequences < Grape::API
        helpers ::Helpers::SharedParams::Main
        helpers ::Helpers::SharedParams::SequenceHelper

        before do
          authenticate!
          load_account!
        end

        namespace :sequences do
          desc 'Get list of sequences' do
            summary('List of sequences')
            success(Entities::Sequences::ItemsEntity)
            failure(Entities::Constants::FAILURE_READ_DELETE)
          end
          params do
            use(:pagination)
          end
          get '/' do
            resource = Sequence.by_user_and_account(user: current_user).all

            present({ items: resource }, with: Entities::Sequences::ItemsEntity)
          end

          desc 'Create a sequence' do
            summary('Create a new sequence')
            success(Entities::Sequences::ItemPreviewEntity)
            failure(Entities::Constants::FAILURE_CREATE_UPDATE)
          end
          params { use(:sequence_create_params) }
          post '/' do
            sequence         = Sequence.new(declared_params(include_missing: true)[:sequence])
            sequence.user    = current_user
            sequence.account = current_account
            sequence.save!

            present(sequence, with: Entities::Sequences::ItemPreviewEntity)
          end

          params do
            requires(:id, type: Integer, desc: 'ID of a sequence')
          end
          route_param :id do
            before { @sequence = Sequence.find_by!(id: params[:id]) }

            desc 'Get a sequence by id' do
              summary('Get a sequence')
              success(Entities::Sequences::ItemEntity)
              failure(Entities::Constants::FAILURE_READ_DELETE)
            end
            get '/' do
              present(@sequence, with: Entities::Sequences::ItemEntity)
            end

            desc 'Update a sequence by id' do
              summary('Update a sequence')
              success(Entities::Sequences::ItemEntity)
              failure(Entities::Constants::FAILURE_CREATE_UPDATE)
            end
            params { use(:sequence_update_params) }
            patch '/' do
              @sequence.update!(declared_params[:sequence])

              present(@sequence, with: Entities::Sequences::ItemEntity)
            end

            desc 'Delete a sequence by id' do
              summary('Delete a sequence')
              success(code: 204)
              failure(Entities::Constants::FAILURE_READ_DELETE)
            end
            delete '/' do
              @sequence.destroy!

              status(:no_content)
            end
          end
        end
      end
    end
  end
end

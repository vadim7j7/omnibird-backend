# frozen_string_literal: true

module Internal
  module V1
    module Endpoints
      class SequenceContacts < Grape::API
        before do
          authenticate!
          load_account!
        end

        namespace :sequences do
          params do
            requires(:sequence_id, type: Integer, desc: 'ID of a sequence')
          end
          route_param :sequence_id do
            namespace :contacts do
              before { @sequence = Sequence.find_by!(id: params[:sequence_id]) }

              desc 'Get list of contacts from sequence' do
                summary('List of contacts from a sequence')
                success(Entities::Contacts::SequenceContactsEntity)
                failure(Entities::Constants::FAILURE_READ_DELETE)
              end
              get '/' do
                resource =
                  @sequence
                  .contact_sequences
                  .includes(:contact)
                  .all

                present({ contacts: resource }, with: Entities::Contacts::SequenceContactsEntity)
              end

              desc 'Add or create a contact to a sequence' do
                summary('Add a contact to a sequence')
                success(Entities::Contacts::SequenceContactEntity)
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
  end
end

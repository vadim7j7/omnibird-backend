# frozen_string_literal: true

module Internal
  module V1
    module Endpoints
      class SequenceContacts < Grape::API
        helpers ::Helpers::SharedParams::Main
        helpers ::Helpers::SharedParams::ContactHelper

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
              params do
                use(:pagination)
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
              params { use(:contact_sequence_params) }
              post '/' do
                attrs = declared_params(include_missing: true)[:contact_sequence]

                @contact_sequence            = ContactSequence.new(attrs)
                @contact_sequence.sequence   = @sequence
                @contact_sequence.connection = @sequence.connection
                @contact_sequence.save!

                present(@contact_sequence, with: Entities::Contacts::SequenceContactEntity)
              end

              params do
                requires(:contact_id, type: Integer, desc: 'Contact ID')
              end
              route_param :contact_id do
                before { @contact_sequence = ContactSequence.find_by!(contact_id: params[:contact_id]) }

                desc 'Delete a contact by id from sequence (it will be just archived!)' do
                  summary('Delete a contact from a sequence')
                  success(code: 204)
                  failure(Entities::Constants::FAILURE_READ_DELETE)
                end
                delete '/' do
                  @contact_sequence.update!(archived_at: Time.current)

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

# frozen_string_literal: true

module Internal
  module V1
    module Endpoints
      class Contacts < Grape::API
        helpers ::Helpers::SharedParams::ContactHelper

        before do
          authenticate!
          load_account!
        end

        namespace :contacts do
          desc 'Get list of contacts' do
            summary('List of contacts')
            success(Entities::Contacts::ItemsEntity)
            failure(Entities::Constants::FAILURE_READ_DELETE)
          end
          params do
            use(:pagination)
          end
          get '/' do
            resource = Contact.by_user_and_account(user: current_user).all

            present({ items: resource }, with: Entities::Contacts::ItemsEntity)
          end

          desc 'Create a contact' do
            summary('Create a new contact')
            success(Entities::Contacts::ItemEntity)
            failure(Entities::Constants::FAILURE_CREATE_UPDATE)
          end
          params { use(:contact_params) }
          post '/' do
            contact         = Contact.new(declared_params(include_missing: true)[:contact])
            contact.user    = current_user
            contact.account = current_account
            contact.save!

            present(contact, with: Entities::Contacts::ItemEntity)
          end

          params do
            requires(:id, type: Integer, desc: 'ID of a contact')
          end
          route_param :id do
            before { @contact = Contact.find_by!(id: params[:id]) }

            desc 'Get a contact by id' do
              summary('Get a contact')
              success(Entities::Contacts::ItemEntity)
              failure(Entities::Constants::FAILURE_READ_DELETE)
            end
            get '/' do
              present(@contact, with: Entities::Contacts::ItemEntity)
            end

            desc 'Update a contact by id' do
              summary('Update a contact')
              success(Entities::Contacts::ItemEntity)
              failure(Entities::Constants::FAILURE_CREATE_UPDATE)
            end
            params { use(:contact_params) }
            patch '/' do
              @contact.update!(declared_params[:contact])

              present(@contact, with: Entities::Contacts::ItemEntity)
            end

            desc 'Delete a contact by id' do
              summary('Delete a contact')
              success(code: 204)
              failure(Entities::Constants::FAILURE_READ_DELETE)
            end
            delete '/' do
              @contact.destroy!

              status(:no_content)
            end
          end
        end
      end
    end
  end
end

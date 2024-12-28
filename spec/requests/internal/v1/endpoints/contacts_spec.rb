# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Internal::V1::Endpoints::Contacts, type: :request) do
  let(:user) { create(:user_in_individual_account) }
  let(:account) { user.accounts.first }
  let(:contact) { create(:contact, account:, user:) }
  let(:another_account) { create(:account) }

  describe '#GET /contacts' do
    describe 'when a user has contacts of his own and from the account' do
      let(:user) { create(:user_in_company_account) }
      let(:account) { user.accounts.first }
      let(:another_user) { create(:user) }

      before do
        create(:account_user, user: another_user, account:)
        create_list(:contact, 2, user:, account:)
        create_list(:contact, 2, user: another_user, account:)
      end

      it 'has 4 contacts' do
        api_get('/contacts', account:, user:)

        expect(json[:items].count).to be(4)
      end
    end

    describe 'when a user is signed in' do
      it 'returns :ok status' do
        api_get('/contacts', account:, user:)

        expect(response).to have_http_status :ok
      end
    end

    describe 'when a user is not signed in' do
      it 'returns :unauthorized status' do
        api_get("/contacts/#{contact.id}", account:)

        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe '#POST /contacts' do
    let(:connection) { create(:google_email_sender, user:, account:) }

    let(:contact_valid_params) do
      { email: Faker::Internet.email,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name }
    end

    let(:contact_invalid_params) { contact_valid_params.merge(email: '') }

    context 'when a user is signed in' do
      describe 'with valid params' do
        before { api_post('/contacts', account:, user:, params: { contact: contact_valid_params }) }

        it 'creates a new contact' do
          expect(user.contacts.last.email).to eq(contact_valid_params[:email])
          expect(account.contacts.last.email).to eq(contact_valid_params[:email])
        end
      end

      context 'when params are invalid' do
        describe 'with blank email in params' do
          before { api_post('/contacts', account:, user:, params: { contact: contact_invalid_params }) }

          it 'returns an error' do
            expect(response).to have_http_status :unprocessable_entity
            expect(json[:message]).to eq("Validation failed: Email can't be blank")
            expect(json[:errors]).to eq({ email: ["can't be blank"] })
          end
        end
      end
    end

    context 'when a user is not signed in' do
      before { api_post('/contacts', params: { contact: contact_valid_params }) }

      it { expect(response).to have_http_status :unauthorized }
    end

    context 'when a user has no access to an account' do
      before { api_post('/contacts', account: another_account, user:, params: { contact: contact_valid_params }) }

      it { expect(response).to have_http_status :forbidden }
    end
  end

  describe '#GET /contacts/:id' do
    describe 'when a user is signed in' do
      it 'returns :ok status' do
        api_get("/contacts/#{contact.id}", account:, user:)

        expect(response).to have_http_status :ok
      end

      it 'returns :not_found status' do
        api_get("/contacts/#{rand(9999...99999)}", account:, user:)

        expect(response).to have_http_status :not_found
      end
    end

    describe 'when a user is not signed in' do
      it 'returns :unauthorized status' do
        api_get("/contacts/#{contact.id}", account:)

        expect(response).to have_http_status :unauthorized
      end
    end

    describe 'when a user has no access to the contact' do
      pending "Not implemented yet #{__FILE__}"
    end
  end

  describe '#PATCH /contacts/:id' do
    let(:contact_valid_params) do
      { email: Faker::Internet.email }
    end

    let(:contact_invalid_params) do
      { email: '' }
    end

    context 'when a user is signed in' do
      describe 'with valid params' do
        it 'returns :ok status' do
          api_patch("/contacts/#{contact.id}", account:, user:, params: { contact: contact_valid_params })

          expect(response).to have_http_status :ok
          expect(json[:email]).to eq(contact_valid_params[:email])
        end

        it 'returns :not_found status' do
          api_patch("/contacts/#{rand(9999...99999)}", account:, user:, params: {})

          expect(response).to have_http_status :not_found
        end
      end

      describe 'with invalid params' do
        it 'returns :unprocessable_content status' do
          api_patch("/contacts/#{contact.id}", account:, user:, params: { contact: contact_invalid_params })

          expect(response).to have_http_status :unprocessable_content
          expect(json[:errors][:email]).to include("can't be blank")
        end
      end
    end

    describe 'when a user is not signed in' do
      it 'returns :unauthorized status' do
        api_patch("/contacts/#{contact.id}", account:)

        expect(response).to have_http_status :unauthorized
      end
    end

    describe 'when a user has no access to the contact' do
      pending "Not implemented yet #{__FILE__}"
    end
  end

  describe '#DELETE /contacts/:id' do
    let(:contact) { create(:contact, account:, user:) }

    describe 'when a user is signed in' do
      it 'returns :no_content status' do
        api_delete("/contacts/#{contact.id}", account:, user:)

        expect(response).to have_http_status :no_content
      end
    end

    describe 'when a user is not signed in' do
      it 'returns :unauthorized status' do
        api_delete("/contacts/#{contact.id}", account:)

        expect(response).to have_http_status :unauthorized
      end
    end

    describe 'when a user has no access to the contact' do
      pending "Not implemented yet #{__FILE__}"
    end
  end
end

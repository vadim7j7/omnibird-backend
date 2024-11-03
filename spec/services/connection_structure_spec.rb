# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Service Module Structure') do
  let(:services_directory) { Rails.root.join('app/services/connections') }
  let(:excluded_directories) { %w[helpers smtp] }

  # Get all subdirectories inside services/connections (e.g., google, microsoft, etc.)
  let(:service_modules) do
    Dir.children(services_directory).select do |f|
      excluded_directories.exclude?(f) &&
        File.directory?(File.join(services_directory, f))
    end
  end

  # Shared example to reuse the checking logic for different categories
  shared_examples 'a service module with required files' do |category_name, files|
    describe "#{category_name} Service Module" do
      # Define the base required files for every service module
      let(:base_required_files) do
        %w[auth_base_service.rb oauth_url_service.rb credentials_service.rb refresh_profile_service.rb]
      end

      it 'checks required files for each service module' do
        service_modules.each do |service_name|
          required_files = base_required_files + files
          service_dir = services_directory.join(service_name)

          required_files.each do |required_file|
            file_path = service_dir.join(required_file)
            expect(File).to exist(file_path), "Expected #{file_path} to exist, but it doesn't."
          end
        end
      end
    end
  end

  # The following context blocks use lambdas to evaluate the let(:base_required_files) within the correct scope
  context 'Offline Service Module' do
    it_behaves_like(
      'a service module with required files',
      'Offline',
      %w[refresh_credentials_service.rb]
    )
  end

  context 'Email Service Module' do
    it_behaves_like(
      'a service module with required files',
      'Email',
      %w[send_email_service.rb email_details_service.rb replies_service.rb]
    )
  end
end

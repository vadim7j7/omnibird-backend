# frozen_string_literal: true

Rails.application.routes.draw do
  mount(Api => '/')
  mount(GrapeSwaggerRails::Engine => '/swagger')

  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
end

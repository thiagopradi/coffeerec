class Admin::BaseController < ApplicationController
  layout "admin"

  http_basic_authenticate_with(
    name: Rails.application.credentials.dig(:admin, :username) || "admin",
    password: Rails.application.credentials.dig(:admin, :password) || "coffee123"
  )
end

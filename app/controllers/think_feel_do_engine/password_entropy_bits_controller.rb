module ThinkFeelDoEngine
  # Calculate the bits of entropy in a password.
  class PasswordEntropyBitsController < ApplicationController
    def show
      validator = PasswordValidator
                  .new(
                    password: params[:password],
                    password_token: params[:reset_password_token])
      render json: { bits: validator.entropy_value }
    end
  end
end

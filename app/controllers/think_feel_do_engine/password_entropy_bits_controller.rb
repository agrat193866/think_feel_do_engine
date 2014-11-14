module ThinkFeelDoEngine
  # Calculate the bits of entropy in a password.
  class PasswordEntropyBitsController < ApplicationController
    def show
      bits = StrongPassword::StrengthChecker.new(params[:password])
             .calculate_entropy(use_dictionary: true)

      render json: { bits: bits }
    end
  end
end

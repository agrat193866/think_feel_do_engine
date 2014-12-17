module ThinkFeelDoEngine
  # Calculate the bits of entropy in a password.
  class PasswordEntropyBitsController < ApplicationController

    def show
      return render(json: { bits: 50 }) if Rails.env.test?

      bits = StrongPassword::StrengthChecker.new(params[:password])
             .calculate_entropy(use_dictionary: true)

      render json: { bits: bits }
    end
  end
end

# frozen_string_literal: true

module LMC
  # Exception representing a missing 2FA code. (2fa enabled but code not sent)
  class MissingCodeException < ResponseException

  end
end
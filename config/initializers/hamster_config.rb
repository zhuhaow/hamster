module Hamster
  class Application
    config.x.cookie_path = Rails.root.join('data/cookies')
    config.x.credential_path = Rails.root.join('data/credentials')
    config.x.google.client_secrets_path = Rails.root.join('data/google/client_secrets.json')
    config.x.google.token_store_path = Rails.root.join('data/google/token.yaml')

    config.after_initialize do
      # setting up folders
      [config.x.cookie_path, config.x.credential_path].each do |path|
        FileUtils.mkdir_p path
      end
    end
  end
end

require 'googleauth'
require 'googleauth/stores/file_token_store'

class GoogleAuthentication
  CLIENT_SECRET_PATH = Rails.configuration.x.google.client_secrets_path
  TOKEN_PATH = Rails.configuration.x.google.token_store_path
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

  def initialize(scope = 'https://www.googleapis.com/auth/drive')
    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRET_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    @authorizer = Google::Auth::UserAuthorizer.new(client_id, scope,
                                                   token_store)
  end

  def setup(user_id = 1)
    url = @authorizer.get_authorization_url(base_url: OOB_URI)
    puts "Open #{url} in your browser and enter the resulting code:"
    code = gets
    @authorizer.get_and_store_credentials_from_code(user_id: user_id,
                                                    code: code,
                                                    base_url: OOB_URI)
  end

  def get_credential(userid = 1)
    @authorizer.get_credentials(userid)
  end
end

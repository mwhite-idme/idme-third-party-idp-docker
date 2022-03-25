class KeycloakController < ApplicationController

  def initialize

    @keycloak_client_id         = "ruby-demo"
    @keycloak_client_secret     = "2e2dc325-32a3-4e28-bf1c-008e27e4dfea"
    @keycloak_redirect_uri      = "http://myapp.idme.test:3000/keycloak-callback"
    @keycloak_authorization_url = "http://keycloak.idme.test:8080/auth/realms/oidc_demo/protocol/openid-connect/auth"
    @keycloak_token_url         = "http://keycloak.idme.test:8080/auth/realms/oidc_demo/protocol/openid-connect/token"
    @keycloak_attributes_url    = "http://keycloak.idme.test:8080/auth/realms/oidc_demo/protocol/openid-connect/userinfo"


    @oauth_client = OAuth2::Client.new(@keycloak_client_id, @keycloak_client_secret, :authorize_url => @keycloak_authorization_url, :token_url => @keycloak_token_url)
  end

  # LOGIN 
    def login
    redirect_to @oauth_client.auth_code.authorize_url(:redirect_uri => @keycloak_redirect_uri), allow_other_host: true
    # MUST set allow_other_host: true, otherwise you will receive an unsafe redirect error
  end

# The OAuth callback
  def oauth_callback
      
    # Make a call to exchange the authorization_code for an access_token
    auth_code = @oauth_client.auth_code.get_token(params[:code], :redirect_uri => @keycloak_redirect_uri)

    @token = auth_code.to_hash[:access_token]

    uri = URI.parse("#{@keycloak_attributes_url}")
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{@token}"
    
      req_options = {
      use_ssl: uri.scheme == "https",
    }
    
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

    #simple rendering User Attributes JSON
    render json: (response.body)

    # # Index.html.erb (sanity check)
    # render :index

    # # Simple Hello Message (Sanity Check)
    # render json: {message: "Hello"}

  end

  # LOGOUT of current session (Work in Progress-15Mar22)
  def logout

    HTTP.post("http://keycloak.idme.test/auth/realms/oidc_demo/protocol/openid-connect/logout")

    # Reset Rails session
    reset_session

    redirect_to root_url
  end



end



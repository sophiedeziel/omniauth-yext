require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Yext < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, "yext"

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :site => "https://www.yext.com",
        :authorize_url => "https://www.yext.com/oauth2/authorize",
        :token_url => "https://api.yext.com/oauth2/accesstoken",
        :me_url => "https://api.yext.com/v2/accounts/me",
      }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid{ raw_info['response']['accountId'] }

      info do
        deep_symbolize raw_info['response']
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get(me_url).parsed
      end

      def build_access_token
        verifier = request.params["code"]
        redirect_uri = callback_url.gsub(query_string, '')
        client.auth_code.get_token(verifier, { redirect_uri: redirect_uri }.merge(token_params.to_hash(:symbolize_keys => true)), deep_symbolize(options.auth_token_params))
      end

      private

      def me_url
        "#{client.options[:me_url]}?access_token=#{access_token.token}&v=20170524"
      end
    end
  end
end

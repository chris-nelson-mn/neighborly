class UserInitializer
  attr_reader :authorization, :email, :omniauth_data

  def initialize(omniauth_data, user)
    @omniauth_data = omniauth_data
    @user          = user
  end

  def provider_name
    OauthProvider.find(authorization_data[:oauth_provider_id]).name
  end

  def authorization_data
    omniauth_data[:authorizations_attributes].first
  end

  def omniauth_urls_data
    omniauth_data.select do |key, _value|
      %i(twitter_url
         linkedin_url
         facebook_url
         remote_uploaded_image_url).include? key
    end
  end

  def setup
    return false unless can_setup?

    if user
      attach_authorization
    else
      @user = User.create(omniauth_data)
    end
  end

  def attach_authorization
    user.uploaded_image? and omniauth_data.delete(:remote_uploaded_image_url)

    user.update_attributes(omniauth_urls_data)
    user.authorizations.
      find_or_initialize_by(oauth_provider_id: authorization_data[:oauth_provider_id]).
      update_attributes(authorization_data)
  end

  def can_setup?
    authorization_exists? || already_signed_in? || (!empty_email? && !data_matches_with_user?)
  end

  def authorization_exists?
    @authorization ||= Authorization.find_by(
      authorization_data.slice(:oauth_provider_id, :uid)
    )
    !!@authorization
  end

  def already_signed_in?
    !!@user
  end

  def data_matches_with_user?
    User.exists?(email: @omniauth_data[:email])
  end

  def empty_email?
    @omniauth_data[:email].blank?
  end

  def user
    @user || @authorization.try(:user)
  end
end

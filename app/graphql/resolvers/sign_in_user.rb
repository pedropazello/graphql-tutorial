class Resolvers::SignInUser < GraphQL::Function
  argument :email, !Types::AuthProviderEmailInput

  type do
    name 'SigninPayload'

    field :token, types.String
    field :user, Types::UserType
  end

  def call(_obj, args, ctx)
    input = args[:email]

    return if input.blank?

    user = User.find_by(email: input[:email])

    return if user.blank?
    return if !user.authenticate(input[:password])

    byteslice = Rails.application.secrets.secret_key_base.byteslice(0..31)
    crypt = ActiveSupport::MessageEncryptor.new(byteslice)
    token = crypt.encrypt_and_sign("user-id:#{user.id}")
  
    ctx[:session][:token] = token

    OpenStruct.new({
      user: user,
      token: token
    })
  end
end
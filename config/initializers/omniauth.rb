Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV["GOOGLE_CLIENT_ID"],
           ENV["GOOGLE_CLIENT_SECRET"],
           {
             scope: "email,profile",
             prompt: "select_account",
             image_aspect_ratio: "square",
             image_size: 50,
             callback_path: "/auth/google_oauth2/callback"
           }
end

# CSRF Protection
OmniAuth.config.allowed_request_methods = [ :post, :get ]

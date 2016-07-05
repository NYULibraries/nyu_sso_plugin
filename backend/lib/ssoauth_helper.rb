 module SsoauthHelper
   include BCrypt
   include JSONModel

    def create_user_from_omniauth(username)
      user_json=JSONModel(:user).from_hash(:username => username,
                                 :name => username)
      User.create_from_json(user_json,{})
    end

   def add_user_to_auth_db(username, auth_token)

     pwhash = Password.create(auth_token)

     DB.open do |db|
       DB.attempt {
         db[:auth_db].insert(:username => username,
                             :pwhash => pwhash,
                             :create_time => Time.now,
                             :system_mtime => Time.now)
       }.and_if_constraint_fails {
         db[:auth_db].
             filter(:username => username).
             update(:username => username,
                    :pwhash => pwhash,
                    :system_mtime => Time.now)
       }
     end

   end
  end

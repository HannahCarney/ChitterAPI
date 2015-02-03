require 'bcrypt'

class User


  include DataMapper::Resource
  
  property :id,    Serial
  property :username,  String, :unique => true, :required => true
  property :email,    String, :required => true, :format => :email_address
  property :password_digest, Text


  attr_reader :password, :username
  attr_accessor :password_confirmation
 
  
  validates_uniqueness_of :email
  validates_uniqueness_of :username
  validates_confirmation_of :password
  validates_length_of :username, :min => 5
  validates_length_of :password, :min => 5
 

    def password=(password)
      @password = password
      self.password_digest = BCrypt::Password.create(password)
    end

    def self.authenticate(username, password)
      user = first(:username => username)
      if user && BCrypt::Password.new(user.password_digest) == password
        user
      else
        nil
      end
    end


end
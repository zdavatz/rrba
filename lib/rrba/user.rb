#!/usr/bin/env ruby
# User -- rrba -- 01.11.2004 -- hwyss@ywesee.com

module RRBA
	class User
		attr_reader :name, :email, :short_name, :unique_id, :public_key
		def initialize(unique_id)
			@unique_id = unique_id or raise "Invalid ID #{unique_id}"
		end
		def authenticate(challenge, signature)
			# enable lazy initializing 
			# (for subclasses that can be persisted)
			public_key.sysverify(challenge, signature)
		end
		def email=(email)
			email = email.to_s.strip
			raise "Invalid Email #{email}" if(email.empty?)
			@email = email
		end
		def name=(name)
			name = name.to_s.strip
			raise "Invalid Username #{name}" if(name.empty?)
			@name = name
		end
		def new_session
			raise NotImplementedError, 
				"no predefined behavior for RRBA::User#new_session"
		end
		def public_key=(key)
			@public_key = key.public_key
		end
		def short_name=(short_name)
			short_name = short_name.to_s.strip
			raise "Invalid Short Name #{short_name}" if(short_name.empty?)
			@short_name = short_name
		end
	end
end

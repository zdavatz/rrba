#!/usr/bin/env ruby
# User -- rrba -- 01.11.2004 -- hwyss@ywesee.com

module RRBA
	class User
		attr_accessor :name, :email, :short_name
		attr_reader :unique_id, :public_key
		def initialize(unique_id)
			@unique_id = unique_id or raise "Invalid ID #{unique_id}"
		end
		def authenticate(challenge, signature)
			# enable lazy initializing 
			# (for subclasses that can be persisted)
			public_key.sysverify(challenge, signature)
		end
		def new_session
			raise NotImplementedError, 
				"no predefined behavior for RRBA::User#new_session"
		end
		def public_key=(key)
			@public_key = key.public_key
		end
	end
end

#!/usr/bin/env ruby
# User -- rrba -- 01.11.2004 -- hwyss@ywesee.com

require 'openssl'
require 'digest/md5'

module RRBA
	class User
		attr_accessor :name, :email, :public_key
		attr_reader :unique_id
		def initialize(unique_id)
			@unique_id = unique_id
		end
		def authenticate(&block)
			challenge = Digest::MD5.hexdigest(rand(2**32).to_s)[0,20]
			signature = block.call(challenge)
			@public_key.sysverify(challenge, signature)
		end
	end
end

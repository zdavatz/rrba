#!/usr/bin/env ruby
# Server -- rrba -- 10.11.2004 -- hwyss@ywesee.com

require 'rrba/user'
require 'rrba/error'
require 'openssl'
require 'digest/md5'

module RRBA
	class Server
		attr_writer :root, :anonymous
		def initialize
			@users = []
		end
		def add_user(user)
			id = user.unique_id
			if(@users.any? { |usr| usr.unique_id == id })
				raise "Duplicate ID #{id}"
			end
			@users.push(user).last
		end
		def authenticate(id=nil, &block)
			challenge = Digest::MD5.hexdigest(rand(2**32).to_s)[0,20]
			signature = block.call(challenge)
			if(@anonymous && signature == :anonymous)
				return @anonymous.new_session
			end
			if(@root && @root.authenticate(challenge, signature))
				return @root.new_session
			end
			begin
				if(id)
					if((user = user(id)) \
						&& user.authenticate(challenge, signature))
						return user.new_session
					end
				else
					@users.each { |user|
						if(user.authenticate(challenge, signature))
							return user.new_session
						end
					}
				end
			rescue RuntimeError
			end
			raise AuthenticationError, 'Authentication failed'
		end
		def user(id)
			@users.select { |user|  
				user.unique_id == id 
			}.first or raise "Unknown User: #{id}"
		end
		def unique_ids
			@users.collect { |user|
				user.unique_id
			}
		end
	end
end

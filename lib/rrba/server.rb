#!/usr/bin/env ruby
# AuthServer -- xmlconv2 -- 10.11.2004 -- hwyss@ywesee.com

require 'rrba/user'
require 'odba'

module RRBA
	class Server
		include ODBA::Persistable
		def initialize(serv)
			@serv = serv
			@users = {}
		end
		def add_user
			id = @serv.id_server.next_id(:user)
			user = RRBA::User.new(id)
			@users.store(id, user)
			@users.odba_store
			user
		end
		def authenticate(&block)
			challenge = Digest::MD5.hexdigest(rand(2**32).to_s)[0,20]
			signature = block.call(challenge)
			@users.each_value { |user|
				if(user.authenticate(signature))
					return user
				end
			}
			nil
		end
		def user(id)
			@users[id]
		end
	end
end

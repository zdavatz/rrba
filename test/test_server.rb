#!/usr/bin/env ruby
# TestAuthServer -- rdpm -- 10.11.2004 -- hwyss@ywesee.com

$: << File.expand_path('../lib', File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'test/unit'
require 'mock'
require 'stub/odba'
require 'rrba/server'

module RRBA
	class TestServer < Test::Unit::TestCase
		def setup
			@services = Mock.new('services')
			@id_server = Mock.new('id_server')
			@server = Server.new(@services)
		end
		def teardown
			@services.__verify
			@id_server.__verify
		end
		def test_add_user
			@services.__next(:id_server) {
				@id_server
			}
			@id_server.__next(:next_id) { |arg| 
				assert_equal(:user, arg)
				345 
			}
			users = @server.instance_variable_get('@users')
			user = @server.add_user
			assert_instance_of(RRBA::User, user)
			assert_equal(345, user.unique_id)
			assert_equal(user, @server.user(345))	
			assert(users.odba_store_called)
		end
		def test_authenticate__failure
			user1 = Mock.new('User1')
			user2 = Mock.new('User2')
			user3 = Mock.new('User3')
			user1.__next(:authenticate) { |sig|
				assert_equal('client-signature', sig)
				false
			}
			user2.__next(:authenticate) { |sig|
				assert_equal('client-signature', sig)
				false
			}
			user3.__next(:authenticate) { |sig|
				assert_equal('client-signature', sig)
				false
			}
			users = {
				1	=> user1,
				2	=> user2,
				3	=> user3,
			}
			@server.instance_variable_set('@users', users)
			user = @server.authenticate { |challenge|
				assert_equal(20, challenge.size)
				'client-signature'
			}
			assert_nil(user)
		end
		def test_authenticate__success
			user1 = Mock.new('User1')
			user2 = Mock.new('User2')
			user3 = Mock.new('User3')
			user1.__next(:authenticate) { |sig|
				assert_equal('client-signature', sig)
				false
			}
			user2.__next(:authenticate) { |sig|
				assert_equal('client-signature', sig)
				true
			}
			user3.__next(:authenticate) { |sig|
				assert_equal('client-signature', sig)
				false
			}
			users = {
				1	=> user1,
				2	=> user2,
				3	=> user3,
			}
			@server.instance_variable_set('@users', users)
			user = @server.authenticate { |challenge|
				assert_equal(20, challenge.size)
				'client-signature'
			}
			assert_equal(user2, user)
		end
	end
end

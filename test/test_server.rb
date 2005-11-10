#!/usr/bin/env ruby
# TestServer -- rdpm -- 10.11.2004 -- hwyss@ywesee.com

$: << File.expand_path('../lib', File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'test/unit'
require 'mock'
require 'fileutils'
require 'rrba/server'

module RRBA
	class TestServer < Test::Unit::TestCase
		def setup
			@server = Server.new
			@datadir = File.expand_path('data', File.dirname(__FILE__))
		end
		def test_add_user
			user = User.new(345)
			users = @server.instance_variable_get('@users')
			@server.add_user(user)
			assert_equal(user, @server.user(345))	
		end
		def test_add_user__duplicate_id
			user = User.new(345)
			users = @server.instance_variable_get('@users')
			@server.add_user(user)
			assert_equal(user, @server.user(345))	
			assert_equal(345, user.unique_id)
			user = User.new(345)
			assert_raises(RuntimeError) { 
				@server.add_user(user)
			}
		end
		def test_authenticate__failure
			user1 = Mock.new('User1')
			user2 = Mock.new('User2')
			user3 = Mock.new('User3')
			user1.__next(:authenticate) { |chal, sig|
				assert_equal(20, chal.size)
				assert_equal('client-signature', sig)
				false
			}
			user2.__next(:authenticate) { |chal, sig|
				assert_equal(20, chal.size)
				assert_equal('client-signature', sig)
				false
			}
			user3.__next(:authenticate) { |chal, sig|
				assert_equal(20, chal.size)
				assert_equal('client-signature', sig)
				false
			}
			users = [
				user1,
				user2,
				user3,
			]
			@server.instance_variable_set('@users', users)
			user = nil
			assert_raises(AuthenticationError) { 
				user = @server.authenticate { |challenge|
					assert_equal(20, challenge.size)
					'client-signature'
				}
			}
			assert_nil(user)
		end
		def test_authenticate__success
			user1 = Mock.new('User1')
			user2 = Mock.new('User2')
			user3 = Mock.new('User3')
			user1.__next(:authenticate) { |challenge, sig|
				assert_equal('client-signature', sig)
				false
			}
			user2.__next(:authenticate) { |challenge, sig|
				assert_equal('client-signature', sig)
				true
			}
			user3.__next(:authenticate) { |challenge, sig|
				assert_equal('client-signature', sig)
				false
			}
			users = [
				user1,
				user2,
				user3,
			]
			session = Mock.new('Session')
			user2.__next(:new_session) { session }
			@server.instance_variable_set('@users', users)
			sess = @server.authenticate { |challenge, sig|
				assert_equal(20, challenge.size)
				'client-signature'
			}
			assert_equal(session, sess)
			user2.__verify
		end
		def test_authenticate__root
			root = Mock.new('Root')
			user2 = Mock.new('User2')
			user3 = Mock.new('User3')
			root.__next(:authenticate) { |challenge, sig|
				assert_equal('client-signature', sig)
				true
			}
			users = [
				user2,
				user3,
			]
			session = Mock.new('Session')
			root.__next(:new_session) { session }
			@server.instance_variable_set('@root', root)
			@server.instance_variable_set('@users', users)
			sess = @server.authenticate { |challenge, sig|
				'client-signature'
			}
			assert_equal(session, sess)
			root.__verify
		end
		def test_authenticate__anonymous
			root = Mock.new('Root')
			user2 = Mock.new('User2')
			user3 = Mock.new('User3')
			anonymous = Mock.new('Anonymous')
			users = [
				user2,
				user3,
			]
			session = Mock.new('Session')
			anonymous.__next(:new_session) { session }
			@server.root = root
			@server.anonymous = anonymous
			@server.instance_variable_set('@users', users)
			sess = @server.authenticate { |challenge, sig|
				:anonymous
			}
			assert_equal(session, sess)
			root.__verify
		end
		def test_authenticate__by_id
			user1 = Mock.new('User1')
			user2 = Mock.new('User2')
			user3 = Mock.new('User3')
			user1.__next(:unique_id) { 'user1' }
			user2.__next(:unique_id) { 'user2' }
			user3.__next(:unique_id) { 'user3' }
			user2.__next(:authenticate) { |challenge, sig|
				assert_equal('client-signature', sig)
				true
			}
			users = [
				user1,
				user2,
				user3,
			]
			session = Mock.new('Session')
			user2.__next(:new_session) { session }
			@server.instance_variable_set('@users', users)
			sess = @server.authenticate('user2') { |challenge, sig|
				assert_equal(20, challenge.size)
				'client-signature'
			}
			assert_equal(session, sess)
			user2.__verify
		end
		def test_unique_ids
			user = Mock.new('user')
			user2 = Mock.new('user2')
			user.__next(:unique_id) { 'rwaltert' }
			user2.__next(:unique_id) { 'hwyss' }
			users = [user, user2]
			@server.instance_variable_set('@users', users)
			assert_equal(["rwaltert", 'hwyss'], @server.unique_ids)
		end
	end
end

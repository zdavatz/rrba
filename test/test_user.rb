#!/usr/bin/env ruby
# TestUser -- rrba -- 01-11-2004 -- hwyss@ywesee.com

$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'test/unit'
require 'rrba/user'

module RRBA
	class TestUser < Test::Unit::TestCase
		def setup
			@user = User.new(1)
		end
		def test_attr_accessors
			assert_respond_to(@user, :name)
			assert_respond_to(@user, :name=)
			assert_respond_to(@user, :email)
			assert_respond_to(@user, :email=)
			assert_respond_to(@user, :public_key)
			assert_respond_to(@user, :public_key=)
		end
		def test_authenticate__failure_wrong_both
			realkey = OpenSSL::PKey::DSA.generate(8)	
			fakekey = OpenSSL::PKey::DSA.generate(8)
			@user.public_key = realkey.public_key
			res = @user.authenticate { |challenge| 
				fakekey.syssign('some other input')
			}
			assert_equal(false, res)
		end
		def test_authenticate__failure_wrong_key
			realkey = OpenSSL::PKey::DSA.generate(8)	
			fakekey = OpenSSL::PKey::DSA.generate(8)
			@user.public_key = realkey.public_key
			res = @user.authenticate { |challenge| 
				fakekey.syssign(challenge)
			}
			assert_equal(false, res)
		end
		def test_authenticate__failure_wrong_challenge
			realkey = OpenSSL::PKey::DSA.generate(8)	
			@user.public_key = realkey.public_key
			res = @user.authenticate { |challenge| 
				realkey.syssign('some other input')
			}
			assert_equal(false, res)
		end
		def test_authenticate__success
			realkey = OpenSSL::PKey::DSA.generate(8)	
			@user.public_key = realkey.public_key
			res = @user.authenticate { |challenge| 
				realkey.syssign(challenge)
			}
			assert_equal(true, res)
		end
	end
end

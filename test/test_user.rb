#!/usr/bin/env ruby
# TestUser -- rrba -- 01-11-2004 -- hwyss@ywesee.com

$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'test/unit'
require 'rrba/user'
require 'fileutils'
require 'openssl'

module RRBA
	class TestUser < Test::Unit::TestCase
		def setup
			@user = User.new(1)
			@datadir = File.expand_path('data', File.dirname(__FILE__))
		end
		def test_attr_accessors
			assert_respond_to(@user, :name)
			assert_respond_to(@user, :name=)
			assert_respond_to(@user, :email)
			assert_respond_to(@user, :email=)
			assert_respond_to(@user, :public_key)
			assert_respond_to(@user, :public_key=)
		end
		def test_authenticate__failure
			realkey = OpenSSL::PKey::DSA.generate(8)	
			fakekey = OpenSSL::PKey::DSA.generate(8)
			@user.public_key = realkey.public_key
			challenge = 'challenge'
			signature = fakekey.syssign(challenge)
			assert_equal(false, @user.authenticate(challenge, signature))
		end
		def test_authenticate__success
			realkey = OpenSSL::PKey::DSA.generate(8)	
			@user.public_key = realkey.public_key
			challenge = 'challenge'
			signature = realkey.syssign(challenge)
			assert_equal(true, @user.authenticate(challenge, signature))
		end
		def test__public_key_writer__public_key
			key = OpenSSL::PKey::DSA.new(8)
			@user.public_key = key.public_key	
			assert_instance_of(OpenSSL::PKey::DSA, @user.public_key)
			assert(@user.public_key.public?)
			assert_equal(false, @user.public_key.private?)
			assert(@user.public_key.sysverify('test', key.syssign('test')), 
				"could not verify signature")
		end
		def test__public_key_writer__private_key
			key = OpenSSL::PKey::DSA.new(8)
			@user.public_key = key
			assert_instance_of(OpenSSL::PKey::DSA, @user.public_key)
			assert(@user.public_key.public?)
			assert_equal(false, @user.public_key.private?, 
				"stored a private key!")
			assert(@user.public_key.sysverify('test', key.syssign('test')), 
				"could not verify signature")
		end
		def test_new_session
			assert_raises(NotImplementedError) { @user.new_session }
		end
	end
end

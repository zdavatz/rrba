#!/usr/bin/env ruby
#  -- rdpm -- 21.01.2005 -- hwyss@ywesee.com

require 'odba'

module ODBA
	module Persistable
		attr_reader :odba_store_called
		def odba_store
			@odba_store_called = true
		end
	end
end

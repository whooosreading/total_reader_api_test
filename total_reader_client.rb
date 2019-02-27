require "./httparty"
require "json"
require "digest/sha1"

class TotalReaderClient

	def self.identify_user(user)
		path = "/users"
		url = "#{ URL_BASE }#{ path }"

		if user.grade_level.to_i <= 2
			grade_level = 3
		else
			grade_level = user.grade_level.to_i
		end

		user_data = {
			refId: self.get_ref_id(user),
			grade: grade_level.to_s
		}
		HTTParty.post(url, body: user_data.to_json,
			headers: self.get_header(path), timeout: TIMEOUT, debug_output: $stdout)
	end

	def self.identify_user_if_needed(user)
		user_check = self.fetch_user(user)
		if user_check["metadata"].to_h["status"] == 400
			self.identify_user(user)
		else
			user_check
		end
	end

	def self.fetch_user(user)
		path = "/users/#{ self.get_ref_id(user) }"
		url = "#{ URL_BASE }#{ path }"
		HTTParty.get(url, headers: self.get_header(path), debug_output: $stdout)
	end

	# Categories should be an array, passage_type a string
	def self.fetch_passages(user, categories, passage_type)
		path = "/passages"
		passage_data = {
			categoryName: categories,
			passageType: passage_type,
			refId: self.get_ref_id(user)
		}
		url = "#{ URL_BASE }#{ path }"
		HTTParty.post(url, body: passage_data.to_json,
			headers: self.get_header(path), timeout: TIMEOUT, debug_output: $stdout)
	end

	def self.fetch_diagnostic_passages(user)
		path = "/passages"
		passage_data = {
			categoryName: [DIAGNOSTIC],
			passageType: "",
			refId: self.get_ref_id(user)
		}
		url = "#{ URL_BASE }#{ path }"
		HTTParty.post(url, body: passage_data.to_json,
			headers: self.get_header(path), timeout: TIMEOUT, debug_output: $stdout)
	end

	def self.fetch_passage(user, passage_id)
		path = "/passages/details/#{ self.get_ref_id(user) }/#{ passage_id }"
		url = "#{ URL_BASE }#{ path }"
		HTTParty.get(url, headers: self.get_header(path), timeout: TIMEOUT, debug_output: $stdout)
	end

	def self.fetch_categories(user)
		path = "/categories/#{ self.get_ref_id(user) }"
		url = "#{ URL_BASE }#{ path }"
		HTTParty.get(url, headers: self.get_header(path), timeout: TIMEOUT, debug_output: $stdout)
	end

	def self.create_assessment(user, passage_id, completions)
		path = "/assessments"
		url = "#{ URL_BASE }#{ path }"

		assessment_data = {
			passageId: passage_id,
			refId: self.get_ref_id(user),
			answers: completions
		}

		# NO TIME OUT!
		HTTParty.post(url, headers: self.get_header(path), body: assessment_data.to_json, debug_output: $stdout)
	end

	def self.requires_diagnostic(data)
		return data["metadata"] && (data["metadata"]["message"] == REQUIRE_DIAGNOSTIC_MESSAGE)
	end


	def self.get_header(path)
		# They expect milliseconds, or at least they use ms in the example
		# I actually think we can pass whatever number we want here
		timestamp = Time.now.to_i * 1000

		request_data = "#{ path }?api_key=#{ API_KEY }&datetime=#{ timestamp }"
		digest_data = OpenSSL::HMAC.digest("sha256", SECRET_KEY, request_data)
		hex_digest_data = Base64.encode64(digest_data)

		headers = {
			"x-hash" => hex_digest_data,
			"x-timestamp" => timestamp.to_s,
			"x-partner" => PARTNER,
			"Content-Type" => "application/json",
			"Accept" => "application/json"
		}
		return headers
	end

	def self.get_ref_id(user)
		seed = Digest::SHA1.hexdigest(self.get_base_ref_id(user)).to_i(16)
		random = Random.new(seed)
		base = "ABCDEF0123456789"
		"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx".gsub("x") do
			base[random.rand(base.length)].downcase
		end
	end

	def self.get_base_ref_id(user)
		# return SAMPLE_USER_ID
		ref_id = "api_test_#{ ENV["ENV"] || "dev" }_#{ user.id }"
		if user.total_reader_ref_id_suffix
			ref_id << "_#{ user.total_reader_ref_id_suffix }"
		end
		if user.demo
			ref_id << "_demo"
		end
		return ref_id
	end

	SAMPLE_USER_ID = "72a645ba-11d2-11e8-b642-0ed5f89f718b"

	REQUIRE_DIAGNOSTIC_MESSAGE = "Take diagnostic passage first"
	DIAGNOSTIC = "diagnostic"

	API_KEY = ENV["API_KEY"]
	SECRET_KEY = ENV["SECRET_KEY"]

	if ENV["ENV"] == "production"
		URL_BASE = "http://api.totalreader.com"
	else
		URL_BASE = "http://api-qa.totalreader.com"
	end

	# Seconds timeout applied to everything but the create_assessment
	TIMEOUT = 5

	PARTNER = "Learn2Earn"
end
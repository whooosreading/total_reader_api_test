require "./user_stub"
require "./total_reader_client"

def validate_env
	errors = []
	if ENV["API_KEY"].to_s.strip.length == 0
		errors << "- Provide api key as API_KEY=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee"
	end
	if ENV["SECRET_KEY"].to_s.strip.length == 0
		errors << "- Provide secret key as SECRET_KEY=abc123abc123abc123abc123abc123abc123"
	end

	if ENV["ENV"] != "production"
		puts "Using default development environment. Specify ENV=production for production."
	end

	if errors.any?
		puts errors.join("\n")
		return false
	end
	return true
end

def start_magenta
	print "\e[32m"
end
def start_grey
	print "\e[37m"
end
def start_green
	print "\e[32m"
end
def end_color
	print "\e[0m"
end

def main(iters)
	return if !validate_env

	puts "\n\n"
	puts "Testing categories #{ iters } times."

	iters.times do |iteration|
		user = UserStub.new
		ref_id = TotalReaderClient.get_ref_id(user)
		start_magenta
		puts "\nIteration #{ iteration }. Ref ID: #{ ref_id }"
		end_color

		puts "\nIdentifying user..."
		start_green
		identify_results = TotalReaderClient.identify_user_if_needed(user)
		start_grey
		puts "Identification results:"
		end_color
		puts identify_results

		sleep(0.5)

		puts "\nFetching categories..."
		start_green
		categories_results = TotalReaderClient.fetch_categories(user)
		start_grey
		puts "Categories results:"
		end_color
		puts categories_results
		
		sleep(1)
	end

	puts "\n\n"
end


main(5)
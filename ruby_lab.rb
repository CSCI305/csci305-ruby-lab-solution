#!/usr/bin/ruby

###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# Isaac Griffith
# isaacgriffith@gmail.com
#
###############################################################

#A hash of hashes containing the bigram counts
$bigrams = Hash.new
$name = "Isaac Griffith"

# Updates the bigram counts for the words in the provided array
def update_bigram_counts(words)
	(0..(words.length - 2)).each do |i|
		key = words[i]
		if $bigrams.has_key? key
			counts = $bigrams[key]
			if counts.has_key? words[i + 1]
				counts[words[i + 1]] += 1
			else
				counts[words[i + 1]] = 1
			end
		else
			counts = {words[i + 1] => 1}
			$bigrams[key] = counts
		end
	end
end

# Finds the word most commonly associated with the given word
def mcw(word)
	if $bigrams.has_key? word
		max = 0
		keys = []
		$bigrams[word].each do |key, count|
			if count > max
				keys = [key]
				max = count
			elsif count == max
				keys << key
			end
		end

		if keys.length > 1
			return keys[Random.rand(keys.length)]
		else
			return keys[0]
		end
	end
	return ""
end

# Constructs the new most probable song title given the start_word
def create_title(start_word)
	count = 1
	next_word = start_word
	title = ""
	while not title.include? next_word
	# while count <= 20
		title += next_word + " "
		next_word = mcw(next_word)
		count += 1
	end

	return title.chomp(" ")
end

# Removes stop words from the song title
def remove_stop_words(song)
	title = song
	title.gsub!(/\b(a|an|and|by|for|from|in|of|on|out|the|to|with)\b+/, "")
	return title
end

def cleanup_title(line)
	# trim everything after certain characters
	song = line.sub(/.*>/, "")

	song.sub!(/([\(\[\{\\\/_\-:"`\+=*]|feat\.).*/, "")

	# remove certain characters from titles (global)
	song.gsub!(/[?¿!¡.;&@%#|]/, "")

	return song
end

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "

	begin
		IO.foreach(file_name) do |line|
			song = cleanup_title(line)

			if not song.nil? and song =~ /^[\d\w\s']+$/
				song = song.downcase
				song.gsub!(/ {2}/, " ")
				song = remove_stop_words(song)
				words = song.split(" ");

				update_bigram_counts(words)
			end
		end

		puts "Finished. Bigram model built.\n\n"
	rescue
		STDERR.puts "Could not open file"
		exit 4
	end
end

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	process_file(ARGV[0])

	word = ""
	while not word.eql? "q" do
		puts ""
		print "Enter a word [Enter 'q' to quit]: "
		word = STDIN.gets().chomp
		puts ""

		puts "#{create_title(word)}" unless word == "q"
	end
end

if __FILE__==$0
	main_loop()
end

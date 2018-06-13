word_array = []
word_list = []
word = "nowordlistfile"
if File.exist? "../word_list.txt"
  puts "File exists"
  # This file knowingly has only 1 word per line
  File.open("../word_list.txt").each do |line|
    word_list.push(line) if (5 <= line.length && line.length <= 12)
  end
  word = word_list.sample.chomp.strip
end

word_array = word.upcase.split("")
puts "set_word: word array ="
p word_array

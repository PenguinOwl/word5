#! /bin/crystal

LETTERS = ('a'..'z').to_a

words = File.read("src/sgb-words.txt").strip.split('\n').sort

current_words = words.clone
info = [] of Char

puts "#{words.size} loaded, ready to search"

commonality_table = {} of Char => Float32

words.each do |word|
  word.chars.each do |char|
    if commonality_table[char]?
      commonality_table[char] += 1
    else
      commonality_table[char] = 1
    end
  end
end

lowest = commonality_table.values.sort.first

commonality_table.each do |char, val|
  commonality_table[char] = val / lowest
end

def commonality(table, word)
  chars = word.chars
  return chars.map{|e| table[e]}.sum / word.size
end

loop do
  puts "#{current_words.size} in filter"
  puts
  print "word5> "
  input = (gets || "").strip.split(' ')
  if command = input[0]?
    case command
    when "reset", "r"
      current_words = words.clone
      info.clear
      puts "Reset word list"
    when "exclude", "no", "e"
      precount = current_words.size
      if input[2]? == "at" || input[2]? == "in"
        if num = input[3]?
          index = num.to_i { 0 }
          index -= 1
          reject = input[1][0]
          current_words.reject!{|e| e[index]? == reject}
          current_words.reject!{|e| !e.includes? reject}
          info << reject
        end
      else
        input[1..-1].join("").chars.each do |reject|
          current_words.reject!{|e| e.includes? reject}
          info << reject
        end
      end
      puts "Rejected #{precount - current_words.size} words"
    when "include", "yes", "i"
      precount = current_words.size
      if input[2]? == "at" || input[2]? == "in"
        if num = input[3]?
          index = num.to_i { 0 }
          index -= 1
          reject = input[1][0]
          current_words.reject!{|e| e[index]? != reject}
          info << reject
        end
      else
        input[1..-1].join("").chars.each do |reject|
          current_words.reject!{|e| !e.includes? reject}
          info << reject
        end
      end
      puts "Rejected #{precount - current_words.size} words"
    when "out"
      if count = input[1]?
        puts current_words.first(count.to_i).join(", ")
      else
        puts current_words.join(", ")
      end
    when "rand"
      puts current_words.shuffle.first
    when "exit"
      exit
    when "nodouble"
      precount = current_words.size
      current_words.reject!{|e| e.chars.size != e.chars.uniq.size}
      puts "Rejected #{precount - current_words.size} words"
    when "g", "guess", "noinfo"
      info_words = words.clone
      info_words.reject!{|e| e.chars.size != e.chars.uniq.size}
      extra = LETTERS - current_words.join("").chars.uniq
      info = extra + info
      info.uniq!
      info.each do |reject|
        info_words.reject!{|e| e.includes? reject}
      end
      info_words.sort_by!{|e| commonality(commonality_table, e)}
      unless info_words.size == 0
        puts info_words.last
      else
        if current_words.size > 1
          needed_letters = LETTERS - info
          best_word = words.max_by{|e| (e.chars.uniq & needed_letters).size}
          if (best_word.chars.uniq & needed_letters).size > 0
            puts best_word
            next
          end
        end
        if current_words.size != 0
          puts current_words.sort_by!{|e| commonality(commonality_table, e)}.reverse.last
        else
          puts "Could not find a solution"
        end
      end
    end
  end
end

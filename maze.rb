#!/usr/local/bin/ruby

# ########################################
# CMSC 330 - Project 1
# Name: Chris Binkley
# UID: 110663829
# ########################################
# I pledge on my honor that I have not given or 
# received any unauthorized assistance on this assignment.
# ########################################

#-----------------------------------------------------------
# FUNCTION DECLARATIONS
#-----------------------------------------------------------

# parsing a standard maze file
def parse(file)
  simple = "" # what will print if all lines are valid
  invalidlines = "" # what will print if any lines are invalid
  invalid = false # true if any incorrectly formatted lines are found

  # reformatting the maze header
  line = file.gets # first line
  if line =~ /^maze: ([\d]+) ([\d]+):([\d]+) -> ([\d]+):([\d]+)$/
    values = $1 + " " + $2 + " " + $3 + " " + $4 + " " + $5 + "\n"
    simple += values
  else
    invalid = true
    invalidlines += line
  end

  # read additional lines
  while line = file.gets do
    if line =~ /^[0-9]+,[0-9]+: [udlr]+ (([0-9]+)(\.)([0-9]+),*)+$/
      # cell with open doors
      line.gsub!(/,/," ")
      line.gsub!(/:/,"")
      simple += line 
    elsif line =~ /^[0-9]+,[0-9]+:(\s)*$/
      # cell with no open doors
      line.gsub!(/,/," ")
      line.gsub!(/:/,"")
      simple += line
    elsif line[0,1] == "\"" # if the line is a path line
      if line =~ /((^: )*:\([\d]+,[\d]+\)(,[udlr])*"(,*))+/ # good path
        # splitting multiple paths in a single line
        paths = line.split(/((^: )*:\([\d]+,[\d]+\)(,[udlr])*"(,*))/)
        numpaths = (paths.length) / 4
        i = 0

        # adding each path (loops only once if only one path is in the line)
        for i in (0...numpaths)
          # reformating the path to simple form
          paths[4*i].sub!(/"/,"")
          paths[4*i].gsub!(/\\\"/,"\"")
          paths[4*i + 1].gsub!(/\(|\)/," ")
          paths[4*i + 1].sub!(/,/," ")
          paths[4*i + 1].gsub!(/"|,|:/,"")

          value = "path " + paths[4*i] + paths[4*i + 1] + "\n"
          simple += value
        end
      else # bad path
        invalid = true
        invalidlines += line
      end
    else #other type of invalid line
      invalid = true
      invalidlines += line
    end
  end

  if invalid
    # if any line was invalid, prints "invalid maze" and invalid lines
    invalidlines = "invalid maze\n" + invalidlines
    puts invalidlines  
  else
    # otherwise, prints the simple maze
    puts simple 
  end
end

# parser that read simple maze files
def read_and_print_simple_file(file)
  line = file.gets

  # read 1st line, must be maze header
  sz, sx, sy, ex, ey = line.split(/\s/)
  puts "header spec: size=#{sz}, start=(#{sx},#{sy}), end=(#{ex},#{ey})"

  # read additional lines
  while line = file.gets do

    # begins with "path", must be path specification
    if line[0...4] == "path"
       p, name, x, y, ds = line.split(/\s/)
       puts "path spec: #{name} starts at (#{x},#{y}) with dirs #{ds}"

    # otherwise must be cell specification (since maze spec must be valid)
    else
       x, y, ds, w = line.split(/\s/,4)
       puts "cell spec: coordinates (#{x},#{y}) with dirs #{ds}"
       ws = w.split(/\s/)
       ws.each {|w| puts "  weight #{w}"}
    end
  end
end

# decides if the maze can be solved or not
def solve(file)
  line = file.gets
  sz, sx, sy, ex, ey = line.split(/\s/) # maze header
  $endx = ex.to_i # global for access in recursive method
  $endy = ey.to_i

  allcells = [] # stores information on each cell in the maze
  i = 0
  while line = file.gets
    if line[0...4] != "path" # cell specifications
      allcells[i] = line.split(/\s/,4) # [posx, posy, dirs, other]
      i += 1
    end
  end
  
  # to avoid checking the same cell twice
  searched = Array.new(allcells.length, false)

  posx = sx.to_i
  posy = sy.to_i

  puts solveRecur(allcells, searched, posx, posy)
end

def solveRecur(allcells, searched, posx, posy)
  # returns the directions that are availible and index in allcells array
  directions, index = find_cell(allcells, posx, posy)

  # tracking cells that have been searched
  if searched[index]
    return false
  else
    searched[index] = true
  end

  # check for end cell
  if posx == $endx and posy == $endy
    return true
  end

  #splits direction string
  dirs = directions.split(//)

  # recuring each direction
  dirs.each{ |char|
    case char
      when "u" then
        if solveRecur(allcells, searched, posx, posy-1)
          return true
        end
      when "d" then
        if solveRecur(allcells, searched, posx, posy+1)
          return true
        end
      when "l" then
        if solveRecur(allcells, searched, posx-1, posy)
          return true
        end
      when "r" then
        if solveRecur(allcells, searched, posx+1, posy)
          return true
        end
    end
  }

  return false
end

# prints the maze as a "picture"
def pretty_print(file)
  line = file.gets
  sz, sx, sy, ex, ey = line.split(/\s/) # maze header

  cells = []
  i = 0
  while line = file.gets do # read additional lines
    if line[0...4] != "path" # cell specifications
      cells[i] = line.split(/\s/,4)
      i += 1
    end
  end

  maze = "+" # empty maze to print, including the top left corner

  i = 0
  while i < sz.to_i
    maze += "-+"
    i += 1
  end
  maze += "\n" # first line (above the y=0 row)

  posx = 0
  posy = 0

  while posy < sz.to_i
    thisRow = "\|"
    nextRow = "+"

    while posx < sz.to_i
      # filling of cell
      if posx.to_s == sx and posy.to_s == sy # start space
        thisRow += "s"
      elsif posx.to_s == ex and posy.to_s == ey # end space
        thisRow += "e"
      else # all other spaces
        thisRow += " "
      end

      str, junk = find_cell(cells, posx, posy)

      # right side of cell
      if str =~ /[r]/ then thisRow += " "
      else thisRow += "\|"
      end

      # bottom-center of cell
      if str =~ /[d]/ then nextRow += " "
      else nextRow += "-"
      end

      # bottom-right of the cell
      nextRow += "+"

      posx += 1
    end

    maze = maze + thisRow + "\n" + nextRow + "\n"
    posx = 0

    posy += 1
  end

  puts maze
end

# takes an array of cells and a coordinate of a cell to find
# returns the directions that are open for that cell
def find_cell(cells, x, y)
  i = 0
  while i < cells.length
    #print "cell[][] type: " + (cells[0][0].class).to_s + " xy type: " + (x.class).to_s
    #print "(out)i: " + i.to_s + ", " + cells[i][0] + ", " + cells[i][1] + ", " + cells[i][2] +"\n"
    
    if cells[i][0] == x.to_s and cells[i][1] == y.to_s
      #print "(in)i: " + i.to_s + ", " + cells[i][0] + ", " + cells[i][1] + ", " + cells[i][2] +"\n"
    
      return cells[i][2], i # open directions
    end
    i += 1
  end
  return "", nil # returns if the cell is unlisted (aka, closed on all sides)
end

# count the number of closed cells
def count_closed(file)

  # get the first number from the maze file
  firstLine = file.readline
  firstLine = firstLine.slice(/[0-9]*/)
  size = firstLine.to_i

  size = size * size # total number of cells

  # reduces size for each line that has two numbers
  # followed by u, d, l, and/or r, then weights
  allLines = file.readlines
  allLines.each{|x|
    if  x =~ /[0-9]+ [0-9]+ [udlr]+ (([0-9]+)(\.)([0-9]+)((\s)*))+/
      # puts x
      size -= 1
    end
  }

  puts size
end

# prints the total number of each direction (that are open)
def directions(file)
  # number of paths that open Up/Down/Left/Right
  sizeU = 0
  sizeD = 0
  sizeL = 0
  sizeR = 0

  # counting how many times each path option occurs
  allLines = file.readlines
  allLines.each{|x|
    if  x =~ /[0-9]+ [0-9]+ [drl]*[u][drl]* (([0-9]+)(\.)([0-9]+)((\s)*))+/
      sizeU += 1
    end

    if  x =~ /[0-9]+ [0-9]+ [rlu]*[d][rlu]* (([0-9]+)(\.)([0-9]+)((\s)*))+/
      sizeD += 1
    end

    if  x =~ /[0-9]+ [0-9]+ [dul]*[r][dul]* (([0-9]+)(\.)([0-9]+)((\s)*))+/
      sizeR += 1
    end

    if  x =~ /[0-9]+ [0-9]+ [dru]*[l][dru]* (([0-9]+)(\.)([0-9]+)((\s)*))+/
      sizeL += 1
    end
  }

  print ("u: " + sizeU.to_s + ", d: " + sizeD.to_s + ", l: " + 
    sizeL.to_s + ", r: " + sizeR.to_s + "\n")
end

# calculates the length of each provided path
# prints them in increasing order
def path_length(file)
  paths = {}
  allLines = file.readlines

  if allLines[0] =~ /\d+ (\d+) (\d+) \d+ \d+/
    startx = $1
    starty = $2
  end

  # stores each path name and its directions
  # example line: path path1 0 1 drdu
  allLines.each{|x|
    if x =~ /path ([^: ]+) [0-9]+ [0-9]+ ([udlr]*)/
      # paths[name] = directions
      paths[$1] = $2
    end
  }

  sortedPaths = {}

  paths.each_key{|key|
    directions = paths[key]
    sum = 0.0 # sum of path weights
    cordx = startx.to_i # getting initial x and y coordinates
    cordy = starty.to_i

    # iterate over each direction (char) in the path
    directions.each_byte { |c|
      char = c.chr
      sum += find_weight(allLines, cordx, cordy, char).to_f
      # moving to the next cell in the path
      case
        when char == "u" then cordy -= 1
        when char == "d" then cordy += 1
        when char == "l" then cordx -= 1
        when char == "r" then cordx += 1
      end
    }

    sortedPaths[sum] = key # sortedPaths: key = path weight, value = path name
  }

  # prints "None" if no paths are available
  # or the paths in increasing cost order
  if paths.empty? 
    puts "None"
  else
    myKeys = sortedPaths.keys
    myKeys.sort!

    # not empty is guarenteed to have one element
    print sortedPaths[myKeys[0]] #+ " \(" + myKeys[0].to_s + "\)"
    i = 1

    # comma before each additional value
    while i < myKeys.length
      print ", " + sortedPaths[myKeys[i]] #+ " \(" + myKeys[i].to_s + "\)"
      i += 1
    end
    print "\n"
  end
end

# returns the weight of specific direction from a spcific cell
def find_weight(file_array, cordx, cordy, dir)
  weight = 0.0

  file_array.each{|x|
    if x =~ /[0-9]+ [0-9]+ ([udlr]*) ([0-9]+\.[0-9]+((\s)*))+/
      open = ($1).to_s # the open directions
      parts = x.split(' ') # isloating the weights of the directions

      # matches the specific cell and opening used from that cell
      if (cordx == (parts[0]).to_i) and (cordy == (parts[1]).to_i)
        # getting the weight of the path taken
        case dir
          when open[0,1] then weight = parts[3]
          when open[1,1] then weight = parts[4]
          when open[2,1] then weight = parts[5]
          when open[3,1] then weight = parts[6]
        end
      end
    end
  }

  return weight
end

#-----------------------------------------------------------
# EXECUTABLE CODE
#-----------------------------------------------------------

#----------------------------------
# check # of command line arguments

if ARGV.length < 2
  fail "usage: maze.rb <command> <filename>" 
end

command = ARGV[0]
file = ARGV[1]
maze_file = open(file)

if file === nil
  fail "no file found"
end

#----------------------------------
# perform command

case command

  when "closed" # count the number of closed cells
    count_closed(maze_file)

  when "open" # counts the number of times a path in each direction is avaliable
    directions(maze_file)

  when "paths" # calculates the length of each provided path
    path_length(maze_file)

  when "parse" # takes a standard maze file and prints a simple maze file
    parse(maze_file)

  when "print" # prints the maze as an "image"
    pretty_print(maze_file)

  when "parse_for_me" # given parse and print of simple maze
    read_and_print_simple_file(maze_file)

  when "solve" # decides if a maze can be solved
    solve(maze_file)
#    print solve(maze_file).to_s + "\n"

  else
    fail "Invalid command"
end


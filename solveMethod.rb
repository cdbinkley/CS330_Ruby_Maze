# decides if the maze can be solved or not
def solve(file)
  line = file.gets
  sz, sx, sy, ex, ey = line.split(/\s/) # maze header

  cells = []
  i = 0
  while line = file.gets do # read additional lines
    if line[0...4] != "path" # cell specifications
      cells[i] = line.split(/\s/,4) # [posx, posy, dirs, weights]
      i += 1
    end
  end

  posx = sx.to_i
  posy = sy.to_i

  # returns the directions that are availible and index in cells array
  directions, cell = find_cell(cells, posx, posy)

  print "directions: " + directions + " cell: " + cell.to_s + "\n"
  print "current cell: " + cells[cell][0] + " " + cells[cell][1] + " " + cells[cell][2] + "\n"
  cells.delete_at(cell) # delete, from the cells array, the cell that was just exited

  # looking at the cell in each direction
  directions.each_byte { |c|
    char = c.chr

    case char
      when "u"
        posy -= 1
        
      when "d" then posy += 1
      when "l" then posx -= 1
      when "r" then posx += 1
    end
  }

  cellsToSearch.each{
    if posx == ex.to_i and posy == ey.to_i
      return true
    else
      puts "stuff_F: " + "\(" + posx.to_s + ", " + posy.to_s + "\)" + "\(" + ex + ", " + ey + "\)\n"
      if search_recur(cells, directions, posx, posy, ex.to_i, ey.to_i)
        return true
      end
    end
  }
  return false
end

def search_recur(cells, dirs, posx, posy, ex, ey)

  directions, cell = find_cell(cells, posx, posy) # returns the directions that are availible and index in cells array

  if cell != nil
    print "directions: " + directions + " cell: " + cell.to_s + "\n"
    print "current cell: " + cells[cell][0] + " " + cells[cell][1] + " " + cells[cell][2] + "\n"
    cells.delete_at(cell) # delete, from the cells array, the cell that was just exited

    # looking at the cell in each direction
    directions.each_byte { |c|
      char = c.chr

      # moving to the next cell in the path
      case char
        when "u" then posy -= 1
        when "d" then posy += 1
        when "l" then posx -= 1
        when "r" then posx += 1
      end
    }

    cellToSearch.each{
      if posx == ex and posy == ey
        truth = true
      else
        puts "stuff_F: " + "\(" + posx.to_s + ", " + posy.to_s + "\)" + "\(" + ex.to_s + ", " + ey.to_s + "\)\n"
        if search_recur(cells, directions, posx, posy, ex, ey)
          return true
        end
      end
    }
  end
end

# ------------------------------------------

if ARGV.length < 2
  fail "usage: maze.rb <command> <filename>" 
end

command = ARGV[0]
file = ARGV[1]
maze_file = open(file)

if file === nil
  fail "no file found"
end

case command
  when "solve" # decides if a maze can be solved
    print solve(maze_file).to_s + "\n"

  else
    fail "Invalid command"
end

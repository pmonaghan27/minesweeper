require "./tile"

class Grid
    attr_reader :game_over

    def initialize(size = 9)
        @grid = Array.new(size) { Array.new(size) { Tile.new(0) } }
        self.place_bombs
        self.populate_grid
        @game_over = [false, ":)"]
    end

    def [](pos)
        row, col = pos
        @grid[row][col]
    end

    def []=(pos, val)
        row, col = pos
        @grid[row][col] = val
    end

    def open_spots
        open_spots = []
        (0...@grid.length).each do |row|
            (0...@grid.length).each do |col|
                pos = [row, col]
                open_spots << pos if self[pos].val == 0
            end
        end
        open_spots
    end

    def place_bombs
        count = @grid.length + 1
        open_spots = self.open_spots

        while count > 0
            rand_idx = rand(0...open_spots.length)
            self[open_spots[rand_idx]].val = -1
            open_spots.delete_at(rand_idx)
            count -= 1
        end
    end

    def get_neighbors(pos)
        row, col = pos
        neighbors = []
        (-1..1).each do |row_offset|
            new_row = row + row_offset
            (-1..1).each do |col_offset|
                new_col = col + col_offset
                new_pos = [new_row, new_col]
                if (new_row >= 0 && new_row < @grid.length) && (new_col >= 0 && new_col < @grid.length) && new_pos != pos
                    neighbors << new_pos
                end
            end
        end
        neighbors
    end

    def count_adjacent_bombs(pos)
        self.get_neighbors(pos).inject(0) { |count, neighbor| self[neighbor].val == -1 ? count + 1 : count }
    end

    def populate_grid
        @grid.each_with_index do |row, row_idx|
            row.each_with_index do |tile, col_idx|
                if tile.val != -1
                    tile.val = self.count_adjacent_bombs([row_idx, col_idx])
                end
            end
        end
    end

    def valid_pos?(pos)
        row, col = pos
        (row >= 0 && row < @grid.length) && (col >= 0 && col < @grid.length)
    end

    def reveal_tiles(pos)
        neighbors = self.get_neighbors(pos)

        # reveal numbered neighbors first
        neighbors.each { |neighbor| self[neighbor].reveal if self[neighbor].val > 0 }

        #filter to just non-revealed blank neighbors (non-revealed so we don't check twice)
        blanks = neighbors.select { |neighbor| self[neighbor].val == 0 && !self[neighbor].revealed }

        #reveal neighboring blanks
        blanks.each { |blank| self[blank].reveal }

        # recursively reveal_tiles on each neighboring blank
        blanks.each { |blank| self.reveal_tiles(blank) }
    end

    def guess(pos)
        if self[pos].val == -1
            @grid.flatten.each { |tile| tile.reveal if tile.val == -1 }
            @game_over = [true, ":("]
        else 
            self[pos].reveal
            self.reveal_tiles(pos) if self[pos].val == 0
            self.won?
        end
    end

    def won?
        won = @grid.flatten.select { |tile| tile.val != -1 }.all? { |tile| tile.revealed }
        @game_over[0] = true if won
    end

    def flag(pos)
        self[pos].toggle_flag
    end

    def render
        print_key = { -1 => "*", 0 => "/" }
        puts "   #{(0..8).to_a.join("  ")}"
        @grid.each_with_index do |row, row_idx|
            print "#{row_idx} "
            row.each do |tile|
                if tile.revealed
                    print_val = print_key[tile.val] || tile.val
                    print " #{print_val} "
                elsif tile.flagged
                    print " @ "
                else
                    print " - "
                end
            end
            puts
        end
    end

    #use for testing:
    # def cheat
    #     print_key = { -1 => "*", 0 => "/" }
    #     puts "   #{(0..8).to_a.join("  ")}"
    #     @grid.each_with_index do |row, row_idx|
    #         print "#{row_idx} "
    #         row.each do |tile|
    #             print_val = print_key[tile.val] || tile.val
    #             print " #{print_val} "
    #         end
    #         puts
    #     end
    # end
end

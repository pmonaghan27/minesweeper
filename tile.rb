class Tile
    attr_accessor :val
    attr_reader :revealed, :flagged

    def initialize(val)
        @val = val
        @revealed = false
        @flagged = false
    end

    def reveal
        @revealed = true
    end

    def toggle_flag
        @flagged = !@flagged
    end
end
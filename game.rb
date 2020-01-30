require "./grid.rb"

class Minesweeper
    def initialize
        @grid = Grid.new
    end

    def print_commands
        puts "On each turn, you can guess, flag or unflag a cell denoted by its coordinates."
        puts "To guess, type 'G #,#'"
        puts "To flag or unflag, type 'F #,#'"
        puts "**all commands are case-sensitive"
        puts ""
    end

    def valid_command(str)
        str == "G" || str == "F"
    end

    def parse_command(input)
        command = input.split(" ")
        if command.length == 1 && command[0] == "HOW"
            command
        elsif command.length == 2
            command[1] = command[1].split(",").map { |char| Integer(char) }
            if self.valid_command(command[0]) && @grid.valid_pos?(command[1])
                command
            else
                raise exception
            end
        else
            raise exception
        end
    end

    def run_command(command)
        arg, pos = command
        if arg == "HOW"
            self.print_commands
        elsif arg == 'F'
            @grid[pos].toggle_flag
        else
            @grid.guess(pos)
        end
    end

    def play_turn
        @grid.render
        @grid.cheat

        command = nil
        until command
            print "Enter a command or type HOW to list commands: "

            begin
                command = parse_command(gets.chomp)
            rescue
                puts "Unrecognized command or invalid coordinates. Try again."
                puts ""

                command = nil
            end
        end

        self.run_command(command)
    end

    def game_over?
        @grid.game_over[0]
    end

    def run
        until self.game_over?
            self.play_turn
        end

        @grid.render
        puts "GAME OVER #{@grid.game_over[1]}"
    end
end

game = Minesweeper.new
game.run

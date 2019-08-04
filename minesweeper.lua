if not cr then cr = {} end

addhook('clientdata', 'cr.minesweeper.hooks.clientdata')
addhook('serveraction', 'cr.minesweeper.hooks.serveraction')
addhook('join', 'cr.minesweeper.hooks.join')
addhook('say', 'cr.minesweeper.hooks.say')
addhook('team', 'cr.minesweeper.hooks.team')
addhook('startround', 'cr.minesweeper.hooks.startround')

cr.minesweeper = {
	player = {};
	
	funcs = {
		generateBoard = function(id, width, height, ammount)
			cr.minesweeper.player[id].board = {}
			cr.minesweeper.player[id].mines = ammount
			for x = 0, width + 1 do
				cr.minesweeper.player[id].board[x] = {}
				for y = 0, height + 1 do
					cr.minesweeper.player[id].board[x][y] = {mine = false, opened = false, flagged = false, border = false}
					if x == 0 or y == 0 or x == width + 1 or y == height + 1 then
						cr.minesweeper.player[id].board[x][y].border = true
					end
				end
			end
			for i = 1, ammount do
				local x, y
				repeat
					x, y = math.random(1, width), math.random(1, height)
				until cr.minesweeper.player[id].board[x][y].mine == false
				cr.minesweeper.player[id].board[x][y].mine = true
			end
		end;
		
		drawBoard = function(id)
			for x = 1, #cr.minesweeper.player[id].board - 1 do
				for y = 1, #cr.minesweeper.player[id].board[1] - 1 do
					if cr.minesweeper.player[id].lose then
						if cr.minesweeper.player[id].board[x][y].mine and cr.minesweeper.player[id].board[x][y].flagged == false then
							cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/openedm.bmp', 5 + x * 10, 69 + y * 10, 2, id)
						elseif cr.minesweeper.player[id].board[x][y].mine == false and cr.minesweeper.player[id].board[x][y].flagged then
							cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/flaggedc.bmp', 5 + x * 10, 69 + y * 10, 2, id)
						elseif cr.minesweeper.player[id].board[x][y].mine and cr.minesweeper.player[id].board[x][y].flagged then
							cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/flagged.bmp', 5 + x * 10, 69 + y * 10, 2, id)
						elseif cr.minesweeper.player[id].board[x][y].opened then
							cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/opened'.. cr.minesweeper.funcs.getMines(id, x, y) ..'.bmp', 5 + x * 10, 69 + y * 10, 2, id)
						else
							cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/closed.bmp', 5 + x * 10, 69 + y * 10, 2, id)
						end
					else
						if cr.minesweeper.player[id].board[x][y].flagged then
							cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/flagged.bmp', 5 + x * 10, 69 + y * 10, 2, id)
						elseif cr.minesweeper.player[id].board[x][y].opened then
							cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/opened'.. cr.minesweeper.funcs.getMines(id, x, y) ..'.bmp', 5 + x * 10, 69 + y * 10, 2, id)
						else
							cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/closed.bmp', 5 + x * 10, 69 + y * 10, 2, id)
						end
					end
				end
			end
		end;
		
		getMines = function(id, x, y)
			local mines = 0
			local board = cr.minesweeper.player[id].board
			if board[x - 1][y].mine then
				mines = mines + 1
			end
			if board[x + 1][y].mine then
				mines = mines + 1
			end
			if board[x][y - 1].mine then
				mines = mines + 1
			end
			if board[x][y + 1].mine then
				mines = mines + 1
			end
			if board[x + 1][y - 1].mine then
				mines = mines + 1
			end
			if board[x + 1][y + 1].mine then
				mines = mines + 1
			end
			if board[x - 1][y + 1].mine then
				mines = mines + 1
			end
			if board[x - 1][y - 1].mine then
				mines = mines + 1
			end
			return mines
		end;
		
		clearNode = function(id, x, y)
			freeimage(cr.minesweeper.player[id].board[x][y].image)
			cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/opened0.bmp', 5 + x * 10, 69 + y * 10, 2, id)
			cr.minesweeper.player[id].board[x][y].opened = true
			if cr.minesweeper.player[id].board[x + 1][y].mine == false and cr.minesweeper.player[id].board[x + 1][y].border == false and cr.minesweeper.player[id].board[x + 1][y].opened == false and cr.minesweeper.player[id].board[x + 1][y].flagged == false then
				if cr.minesweeper.funcs.getMines(id, x + 1, y) == 0 then
					cr.minesweeper.funcs.clearNode(id, x + 1, y)
					cr.minesweeper.player[id].board[x + 1][y].opened = true
				else
					freeimage(cr.minesweeper.player[id].board[x + 1][y].image)
					cr.minesweeper.player[id].board[x + 1][y].image = image('gfx/minesweeper/opened'.. cr.minesweeper.funcs.getMines(id, x + 1, y) ..'.bmp', 5 + (x + 1) * 10, 69 + y * 10, 2, id)
					cr.minesweeper.player[id].board[x + 1][y].opened = true
				end
			end
			if cr.minesweeper.player[id].board[x - 1][y].mine == false and cr.minesweeper.player[id].board[x - 1][y].border == false and cr.minesweeper.player[id].board[x - 1][y].opened == false and cr.minesweeper.player[id].board[x - 1][y].flagged == false then
				if cr.minesweeper.funcs.getMines(id, x - 1, y) == 0 then
					cr.minesweeper.funcs.clearNode(id, x - 1, y)
					cr.minesweeper.player[id].board[x - 1][y].opened = true
				else
					freeimage(cr.minesweeper.player[id].board[x - 1][y].image)
					cr.minesweeper.player[id].board[x - 1][y].image = image('gfx/minesweeper/opened'.. cr.minesweeper.funcs.getMines(id, x - 1, y) ..'.bmp', 5 + (x - 1) * 10, 69 + y * 10, 2, id)
					cr.minesweeper.player[id].board[x - 1][y].opened = true
				end
			end
			if cr.minesweeper.player[id].board[x][y + 1].mine == false and cr.minesweeper.player[id].board[x][y + 1].border == false and cr.minesweeper.player[id].board[x][y + 1].opened == false and cr.minesweeper.player[id].board[x][y + 1].flagged == false then
				if cr.minesweeper.funcs.getMines(id, x, y + 1) == 0 then
					cr.minesweeper.funcs.clearNode(id, x, y + 1)
					cr.minesweeper.player[id].board[x][y + 1].opened = true
				else
					freeimage(cr.minesweeper.player[id].board[x][y + 1].image)
					cr.minesweeper.player[id].board[x][y + 1].image = image('gfx/minesweeper/opened'.. cr.minesweeper.funcs.getMines(id, x, y + 1) ..'.bmp', 5 + x * 10, 69 + (y + 1) * 10, 2, id)
					cr.minesweeper.player[id].board[x][y + 1].opened = true
				end
			end
			if cr.minesweeper.player[id].board[x][y - 1].mine == false and cr.minesweeper.player[id].board[x][y - 1].border == false and cr.minesweeper.player[id].board[x][y - 1].opened == false and cr.minesweeper.player[id].board[x][y - 1].flagged == false then
				if cr.minesweeper.funcs.getMines(id, x, y - 1) == 0 then
					cr.minesweeper.funcs.clearNode(id, x, y - 1)
					cr.minesweeper.player[id].board[x][y - 1].opened = true
				else
					freeimage(cr.minesweeper.player[id].board[x][y - 1].image)
					cr.minesweeper.player[id].board[x][y - 1].image = image('gfx/minesweeper/opened'.. cr.minesweeper.funcs.getMines(id, x, y - 1) ..'.bmp', 5 + x * 10, 69 + (y - 1) * 10, 2, id)
					cr.minesweeper.player[id].board[x][y - 1].opened = true
				end
			end
			if cr.minesweeper.player[id].board[x + 1][y - 1].mine == false and cr.minesweeper.player[id].board[x + 1][y - 1].border == false and cr.minesweeper.player[id].board[x + 1][y - 1].opened == false and cr.minesweeper.player[id].board[x + 1][y - 1].flagged == false then
				if cr.minesweeper.funcs.getMines(id, x + 1, y - 1) == 0 then
					cr.minesweeper.funcs.clearNode(id, x + 1, y - 1)
					cr.minesweeper.player[id].board[x + 1][y - 1].opened = true
				else
					freeimage(cr.minesweeper.player[id].board[x + 1][y - 1].image)
					cr.minesweeper.player[id].board[x + 1][y - 1].image = image('gfx/minesweeper/opened'.. cr.minesweeper.funcs.getMines(id, x + 1, y - 1) ..'.bmp', 5 + (x + 1) * 10, 69 + (y - 1) * 10, 2, id)
					cr.minesweeper.player[id].board[x + 1][y - 1].opened = true
				end
			end
			if cr.minesweeper.player[id].board[x - 1][y - 1].mine == false and cr.minesweeper.player[id].board[x - 1][y - 1].border == false and cr.minesweeper.player[id].board[x - 1][y - 1].opened == false and cr.minesweeper.player[id].board[x - 1][y - 1].flagged == false then
				if cr.minesweeper.funcs.getMines(id, x - 1, y - 1) == 0 then
					cr.minesweeper.funcs.clearNode(id, x - 1, y - 1)
					cr.minesweeper.player[id].board[x - 1][y - 1].opened = true
				else
					freeimage(cr.minesweeper.player[id].board[x - 1][y - 1].image)
					cr.minesweeper.player[id].board[x - 1][y - 1].image = image('gfx/minesweeper/opened'.. cr.minesweeper.funcs.getMines(id, x - 1, y - 1) ..'.bmp', 5 + (x - 1) * 10, 69 + (y - 1) * 10, 2, id)
					cr.minesweeper.player[id].board[x - 1][y - 1].opened = true
				end
			end
			if cr.minesweeper.player[id].board[x + 1][y + 1].mine == false and cr.minesweeper.player[id].board[x + 1][y + 1].border == false and cr.minesweeper.player[id].board[x + 1][y + 1].opened == false and cr.minesweeper.player[id].board[x + 1][y + 1].flagged == false then
				if cr.minesweeper.funcs.getMines(id, x + 1, y + 1) == 0 then
					cr.minesweeper.funcs.clearNode(id, x + 1, y + 1)
					cr.minesweeper.player[id].board[x + 1][y + 1].opened = true
				else
					freeimage(cr.minesweeper.player[id].board[x + 1][y + 1].image)
					cr.minesweeper.player[id].board[x + 1][y + 1].image = image('gfx/minesweeper/opened'.. cr.minesweeper.funcs.getMines(id, x + 1, y + 1) ..'.bmp', 5 + (x + 1) * 10, 69 + (y + 1) * 10, 2, id)
					cr.minesweeper.player[id].board[x + 1][y + 1].opened = true
				end
			end
			if cr.minesweeper.player[id].board[x - 1][y + 1].mine == false and cr.minesweeper.player[id].board[x - 1][y + 1].border == false and cr.minesweeper.player[id].board[x - 1][y + 1].opened == false and cr.minesweeper.player[id].board[x - 1][y + 1].flagged == false then
				if cr.minesweeper.funcs.getMines(id, x - 1, y + 1) == 0 then
					cr.minesweeper.funcs.clearNode(id, x - 1, y + 1)
					cr.minesweeper.player[id].board[x - 1][y + 1].opened = true
				else
					freeimage(cr.minesweeper.player[id].board[x - 1][y + 1].image)
					cr.minesweeper.player[id].board[x - 1][y + 1].image = image('gfx/minesweeper/opened'.. cr.minesweeper.funcs.getMines(id, x - 1, y + 1) ..'.bmp', 5 + (x - 1) * 10, 69 + (y + 1) * 10, 2, id)
					cr.minesweeper.player[id].board[x - 1][y + 1].opened = true
				end
			end
		end;
		
		updateStatus = function(id, text)
			parse('hudtxt2 '.. id ..' 30 "'.. text ..'" 10 54 0')
		end;
	};
	 
	hooks = {
		serveraction = function(id, action)
			if action == 1 then
				if cr.minesweeper.player[id].game and cr.minesweeper.player[id].lose == false then
					cr.minesweeper.player[id].sendingReason = 0
					reqcld(id, 0)
				end
			elseif action == 2 then
				if cr.minesweeper.player[id].game and cr.minesweeper.player[id].lose == false then
					cr.minesweeper.player[id].sendingReason = 1
					reqcld(id, 0)
				end
			end
		end;
		
		join = function(id)
			cr.minesweeper.player[id] = {
				sendingReason = 0;
				game = false;
				lose = false;
				mines = 0;
			}
		end;
		
		clientdata = function(id, mode, data1, data2)
			local x, y = math.floor(data1 / 10), math.floor((data2 - 64) / 10)
			if cr.minesweeper.player[id].sendingReason == 0 then
				if x >= 1 and y >= 1 and x <= #cr.minesweeper.player[id].board - 1 and y <= #cr.minesweeper.player[id].board[1] - 1 then
					if cr.minesweeper.player[id].board[x][y].mine == false and cr.minesweeper.player[id].board[x][y].border == false and cr.minesweeper.player[id].board[x][y].flagged == false then
						if cr.minesweeper.funcs.getMines(id, x, y) == 0 then
							cr.minesweeper.funcs.clearNode(id, x, y)
						else
							freeimage(cr.minesweeper.player[id].board[x][y].image)
							cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/opened'.. cr.minesweeper.funcs.getMines(id, x, y) ..'.bmp', 5 + x * 10, 69 + y * 10, 2, id)
							cr.minesweeper.player[id].board[x][y].opened = true
						end
						local win = true
						for x = 1, #cr.minesweeper.player[id].board - 1 do
							for y = 1, #cr.minesweeper.player[id].board[1] - 1 do
								if cr.minesweeper.player[id].board[x][y].mine == false and cr.minesweeper.player[id].board[x][y].opened == false then
									win = false
								end
							end
						end
						if win then
							cr.minesweeper.funcs.updateStatus(id, string.char(169) ..'000255000You won! Type !minesweeperend to end the game.')
							cr.minesweeper.player[id].lose = true
							for x = 1, #cr.minesweeper.player[id].board - 1 do
								for y = 1, #cr.minesweeper.player[id].board[1] - 1 do
									if cr.minesweeper.player[id].board[x][y].mine and cr.minesweeper.player[id].board[x][y].flagged == false then
										freeimage(cr.minesweeper.player[id].board[x][y].image)
										cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/flagged.bmp', 5 + x * 10, 69 + y * 10, 2, id)
										cr.minesweeper.player[id].board[x][y].flagged = true
									end
								end
							end
						end
					elseif cr.minesweeper.player[id].board[x][y].mine and cr.minesweeper.player[id].board[x][y].flagged == false then
						cr.minesweeper.player[id].lose = true
						cr.minesweeper.funcs.updateStatus(id, string.char(169) ..'255000000You lose! Type !minesweeperend to end the game.')
						for xx = 1, #cr.minesweeper.player[id].board - 1 do
							for yy = 1, #cr.minesweeper.player[id].board[1] - 1 do
								if cr.minesweeper.player[id].board[xx][yy].mine and cr.minesweeper.player[id].board[xx][yy].flagged == false then
									freeimage(cr.minesweeper.player[id].board[xx][yy].image)
									cr.minesweeper.player[id].board[xx][yy].image = image('gfx/minesweeper/openedm.bmp', 5 + xx * 10, 69 + yy * 10, 2, id)
									cr.minesweeper.player[id].board[xx][yy].opened = true
								elseif cr.minesweeper.player[id].board[xx][yy].mine == false and cr.minesweeper.player[id].board[xx][yy].flagged then
									freeimage(cr.minesweeper.player[id].board[xx][yy].image)
									cr.minesweeper.player[id].board[xx][yy].image = image('gfx/minesweeper/flaggedc.bmp', 5 + xx * 10, 69 + yy * 10, 2, id)
								end
							end
						end
					end
				end
			else
				if x >= 1 and y >= 1 and x <= #cr.minesweeper.player[id].board - 1 and y <= #cr.minesweeper.player[id].board[1] - 1 then
					if cr.minesweeper.player[id].board[x][y].border == false and cr.minesweeper.player[id].board[x][y].opened == false then
						if cr.minesweeper.player[id].board[x][y].flagged == false then
							freeimage(cr.minesweeper.player[id].board[x][y].image)
							cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/flagged.bmp', 5 + x * 10, 69 + y * 10, 2, id)
							cr.minesweeper.player[id].board[x][y].flagged = true
						else
							freeimage(cr.minesweeper.player[id].board[x][y].image)
							cr.minesweeper.player[id].board[x][y].image = image('gfx/minesweeper/closed.bmp', 5 + x * 10, 69 + y * 10, 2, id)
							cr.minesweeper.player[id].board[x][y].flagged = false
						end
					end
				end
			end
		end;
		
		say = function(id, text)
			local cmd = {}
			for word in string.gmatch(text, '[^%s]+') do
				cmd[#cmd + 1] = word
			end
			
			if cmd[1] == '!minesweeper' then
				if cmd[2] == 'start' then
					if player(id, 'team') == 0 then
						if not cr.minesweeper.player[id].game then
							w = tonumber(cmd[3]) or false
							h = tonumber(cmd[4]) or false
							a = tonumber(cmd[5]) or false
							if not (w or h or a) then msg2(id, 'Incorrect input. !minesweeperstart <width> <height> <mines>.') return 1 end
							if w < 5 or w > 30 then msg2(id, 'Incorrect width, it can only be a number in between of 5 and 30!') return 1 end
							if h < 5 or h > 30 then msg2(id, 'Incorrect height, it can only be a number in between of 5 and 30!') return 1 end
							if a < 10 or a > (w * h) - 10 then msg2(id, 'Incorrect ammount of mines, it can be minimum 10 and up to width*height-10!') return 1 end
							cr.minesweeper.player[id].game = true
							cr.minesweeper.funcs.generateBoard(id, w, h, a)
							cr.minesweeper.funcs.drawBoard(id)
							cr.minesweeper.funcs.updateStatus(id, 'Playing minesweeper...')
						else
							msg2(id, 'You have already started the minesweeper! Type !minesweeperend to end the game.')
						end
					else
						msg2(id, 'You have to be a spectator to play the minesweeper.')
					end
				elseif cmd[2] == 'end' then
					if cr.minesweeper.player[id].game then
						for x = 1, #cr.minesweeper.player[id].board - 1 do
							for y = 1, #cr.minesweeper.player[id].board[1] - 1 do
								freeimage(cr.minesweeper.player[id].board[x][y].image)
							end
						end
						cr.minesweeper.player[id].game = false
						cr.minesweeper.player[id].lose = false
						cr.minesweeper.funcs.updateStatus(id, '')
					else
						msg2(id, 'You haven\'t started the minesweeper yet!')
					end
				elseif cmd[2] == 'restart' then
					if cr.minesweeper.player[id].board then
						for x = 1, #cr.minesweeper.player[id].board - 1 do
							for y = 1, #cr.minesweeper.player[id].board[1] - 1 do
								freeimage(cr.minesweeper.player[id].board[x][y].image)
							end
						end
						cr.minesweeper.player[id].lose = false
						cr.minesweeper.funcs.generateBoard(id, #cr.minesweeper.player[id].board - 1, #cr.minesweeper.player[id].board[1] - 1, cr.minesweeper.player[id].mines)
						cr.minesweeper.funcs.drawBoard(id)
						cr.minesweeper.funcs.updateStatus(id, 'Playing minesweeper...')
					else
						msg2(id, 'You have to play minesweeper at least once to use this command!')
					end
				end
			end
		end;
		
		team = function(id, team)
			if cr.minesweeper.player[id].game then 
				msg2(id, 'It\'s impossible to change the team while you playing the minesweeper!')
				msg2(id, 'Type !minesweeperend if you want to end the game.')
				return 1
			end
		end;
		
		startround = function(mode)
			for k, v in pairs(player(0, 'table')) do
				if cr.minesweeper.player[v].game then 
					cr.minesweeper.funcs.drawBoard(v)
				end
			end
		end;
	};
}
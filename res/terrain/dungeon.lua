local arg = table.pack(...)
local cols={}
local xLen = (arg[1]-1) or 1
local yLen = (arg[2]-1) or 1

-- Heres where the generation happens (above is boilerplate)
for a=0,xLen,1 do
	cols[a] = {}
	for b=0,yLen,1 do
		cols[a][b] = -1;
	end
end

local roomID = 1;

function getRoomID()
	roomID = roomID+1
	return (roomID-1)
end

function placeRoom()
	local x = (math.random(1,xLen/2) * 2) - 1
	local y = (math.random(1,yLen/2) * 2) - 1
	local w = (math.random(2,6) * 2)
	local h = (math.random(2,6) * 2)
	for a=x,x+w,1 do
		for b=y,y+h,1 do
			if ( a > xLen or b > yLen or cols[a][b] ~= -1 ) then
				return
			end
		end
	end
	local rid = getRoomID()
	for a=x,x+w,1 do
		for b=y,y+h,1 do
			cols[a][b] = rid;
		end
	end
end

for i=0,200,1 do
	placeRoom()
end

function canBranch(x, y, dir)
	if (dir == 1) then
		return ((y + 2 <= yLen) and (cols[x][y+1] == -1) and (cols[x][y+2] == -1))
	elseif (dir == 2) then
		return ((x + 2 <= xLen) and (cols[x+1][y] == -1) and (cols[x+2][y] == -1))
	elseif (dir == 3) then
		return ((y - 2 >= 0) and (cols[x][y-1] == -1) and (cols[x][y-2] == -1))
	elseif (dir == 4) then
		return ((x - 2 >= 0) and (cols[x-1][y] == -1) and (cols[x-2][y] == -1))
	else
		print "Lua Error: perfectmaze.lua->canBranch()"
	end
end

function branch(x, y, id)
	id = id or getRoomID()
	while(canBranch(x,y,1) or canBranch(x,y,2) or canBranch(x,y,3) or canBranch(x,y,4)) do
		local dir = math.random(1,4)
		if (canBranch(x,y,dir)) then
			if (dir == 1) then
				cols[x][y+1] = id
				cols[x][y+2] = id
				branch(x, y+2, id)
			elseif (dir == 2) then
				cols[x+1][y] = id
				cols[x+2][y] = id
				branch(x+2, y, id)
			elseif (dir == 3) then
				cols[x][y-1] = id
				cols[x][y-2] = id
				branch(x, y-2, id)
			elseif (dir == 4) then
				cols[x-1][y] = id
				cols[x-2][y] = id
				branch(x-2, y, id)
			else
				print "Lua Error: perfectmaze.lua->branch()"
			end
		end
	end
end

branch((math.random((xLen-1)/2)*2)+1, (math.random((yLen-1)/2)*2)+1)

for a=1,xLen,2 do
	for b=1,yLen,2 do
		if (cols[a][b] == -1) then
			branch(a, b)
		end
	end
end

function isAdj(id, x, y)
	return ((x > 0 and cols[x-1][y] == id) or (y > 0 and cols[x][y - 1] == id) or (x < xLen and cols[x+1][y] == id) or (y < xLen and cols[x][y+1] == id))
end

--Greater than or equal to id
function isAdjGorE(id, x, y, nId)
	nId = nId or (id-1)
	return (((x > 0 )and( cols[x-1][y] >= id )and( cols[x-1][y] ~= nId) )or( (y > 0 )and( cols[x][y - 1] >= id )and( cols[x][y-1] ~= nId) )or( (x < xLen )and( cols[x+1][y] >= id )and( cols[x+1][y] ~= nId) )or( (y < yLen )and( cols[x][y+1] >= id )and( cols[x][y+1] ~= nId)))
end

function merge(id)
	local conx = {}
	local cony = {}
	local cond = {}
	local conNum = 0
	for a=0,xLen,1 do
		for b=0,yLen,1 do
			if (isAdj(id,a,b) and isAdjGorE(0,a,b,id)) then
				conx[conNum] = a
				cony[conNum] = b
				cond[conNum] = false;
				conNum = conNum + 1
			end
		end
	end
	for i=0,math.min(conNum-1,math.random(0, math.max(2,(conNum*0.05) + 2))),1 do
		local n = math.random(0,conNum-1)
		while (cond[n]) do
			n = math.random(0,conNum-1)
		end
		cols[conx[n]][cony[n]] = id1
	end
end

function floodFillPos(x, y, id)
	if ((cols[x][y] >= 0) and (cols[x][y] ~= id)) then
		cols[x][y] = id
		floodFillPos(x+1, y, id)
		floodFillPos(x-1, y, id)
		floodFillPos(x, y+1, id)
		floodFillPos(x, y-1, id)
	end
end

function floodFill(id)
id = id or 1
	for a=0,xLen,1 do
		for b=0,yLen,1 do
			if (cols[a][b] == id) then
				floodFillPos(a,b,id)
			end
		end
	end
end

function getID(min, max)
	for a=0,xLen,1 do
		for b=0,yLen,1 do
			if ((cols[a][b] >= min) and ((not max) or (cols[a][b] <= max))) then
				return cols[a][b]
			end
		end
	end
	return min-1
end

local nextID = getID(1)
while (nextID >= 1) do
	print ("merging " .. nextID)
	merge(nextID)
	floodFill(0)
	nextID = getID(1)
end

for a=0,xLen,1 do
	for b=0,yLen,1 do
		if (cols[a][b] == -1) then
			cols[a][b] = 0;
		elseif (cols[a][b] > 0) then
			cols[a][b] = 1;
		end
	end
end
-- and everything after this is boilerplate

local retS = "["
for a=0,xLen,1 do
	retS = retS .. "["
	for b=0,yLen,1 do
		retS = retS .. cols[a][b]
		if b ~= yLen then
			retS = retS .. ","
		end
	end
	retS = retS .. "]"
	if a ~= xLen then
		retS = retS .. ","
	end
end
retS = retS .. "]"

return retS
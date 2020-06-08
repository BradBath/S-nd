local width,height=976/4,976/4
local particleSize=4
local sim
local debug=false
local paused=false
local particleTypes
local size=50
local particleCount=0
local currentType=1
local setColor,points,line,circle=love.graphics.setColor,love.graphics.points,love.graphics.line,love.graphics.circle
local isMouseDown,floor=love.mouse.isDown,math.floor
function love.load()
    love.graphics.setDefaultFilter("nearest","nearest",0)
    sim=require'Resources.scripts.simulation'.new(width,height,particleSize)
    particleTypes=sim.particleTypes
    love.mouse.setVisible(false)
    success = love.window.setMode(width*particleSize, height*particleSize)
end

local selectedTextY=10
function love.draw() 
    local mx,my=love.mouse.getPosition()
    love.graphics.setPointSize(particleSize)
    sim:draw()
    love.graphics.setColor(.5,.5,0.5)
    if(debug)then
        love.graphics.print("FPS: "..love.timer.getFPS(),5,10)
        love.graphics.print("Particles: "..particleCount,5,24)
    end
    love.graphics.print("Selected particle type: "..particleTypes[currentType][1],5,selectedTextY)
    line(mx-8,my, mx-3, my)
	line(mx+8,my, mx+3, my)
	line(mx, my-8, mx, my-3)
    line(mx, my+8, mx, my+3)
	circle("line",mx,my,size,200)
end

function love.update(dt) 
    if(paused)then
        return
    end
    local cx,cy=love.mouse.getPosition()
    --Drawing.
    if isMouseDown(1) then
        --Draw filled circle of pixels.
        for y = floor(-size/sim.particleSize), floor(size/sim.particleSize)+1 do
			for x= floor(-size/sim.particleSize), floor(size/sim.particleSize)+1 do
				if((x*x+y*y)<(size*size)/(sim.particleSize*sim.particleSize))then
					local oX=floor(cx/sim.particleSize)
                    local oY=floor(cy/sim.particleSize)
                    local i=sim:calculate_index(oX+x,oY+y)
                    local type,success=sim:get_index(oX+x,oY+y)
                    if(type==0 and success)then
                        sim:set_index(oX+x,oY+y,currentType)  
                        particleCount=particleCount+1
                    end
				end
			end
        end
    elseif isMouseDown(2) then

        for y = floor(-size/sim.particleSize), floor(size/sim.particleSize)+1 do
			for x= floor(-size/sim.particleSize), floor(size/sim.particleSize)+1 do
				if((x*x+y*y)<(size*size)/(sim.particleSize*sim.particleSize))then
					local oX=floor(cx/sim.particleSize)
                    local oY=floor(cy/sim.particleSize)
                    local i=sim:calculate_index(oX+x,oY+y)
                    local type,success=sim:get_index(oX+x,oY+y)
                    if(type~=0 and success)then
                        sim:set_index(oX+x,oY+y,0)  
                        particleCount=particleCount-1
                    end
				end
			end
		end
    end
    size= size < 1 and 1 or size
    sim:update(dt)
end


function love.wheelmoved(x, y)
	size=size+y
end

function love.keypressed(key)
    if(key=='lalt')then
        debug=not debug
        selectedTextY = debug and 38 or 10
    end
    if(key=='p')then
        paused=not paused
    end
    if(key=="[")then
		size=size/2
	elseif(key=="]")then
		size=size*2
    end
    
    if(particleTypes[tonumber(key)])then
        currentType=tonumber(key)
    end
end
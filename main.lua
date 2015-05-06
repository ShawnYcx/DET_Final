-- housekeeping stuff

display.setStatusBar(display.HiddenStatusBar)

local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- set up forward references

local spawnEnemy
local gameTitle
local hitPlanet
local planet
local levelUpdate
local levelText
local level = 1
local ScoreText
local score = 0
local speedBump = 0
local picIndex



-- preload audio

local sndKill = audio.loadSound("boing-1.wav")
local sndBlast = audio.loadSound("blast.mp3")
local sndLose = audio.loadSound("wahwahwah.mp3")


-- create play screen
local function createPlayScreen()
	local background = display.newImage("background.png")
	background.y = 130
	background.alpha = 0
	
	planet = display.newImage("pineapple.png")
	planet.x = centerX
	planet.y = display.contentHeight + 60
	planet.alpha = 0
	
	transition.to( background, { time=2000, alpha=1,  y=centerY, x=centerX } ) 
	
	local function showTitle()
		gameTitle = display.newImage("gametitle.png")
		gameTitle.alpha = 0
		gameTitle:scale(4, 4)
		transition.to( gameTitle, {time=500, alpha=1, xScale=1, yScale=1} )
		startGame()
	end
	transition.to( planet, { time=2000, alpha=1, y=centerY, onComplete=showTitle } ) 

	scoreText = display.newText( "Score: 0", 0, 0, "Helvetica", 22 )
	scoreText.x = centerX
	scoreText.y = 10
	scoreText.alpha = 0
end	

function levelUpdate()
	-- Level text update?
	level = level + 1
	levelText = display.newText("LEVEL " .. level, 0, 0, "Helvetica", 22)
	levelText.x = centerX
	levelText.y = centerY
	levelText.alpha = 0
	local function levelR()
		transition.to(levelText, { time= 2500, alpha=0})
	end
	transition.to(levelText, { time= 1000, alpha=1, onComplete=levelR })	

end

-- game functions

function spawnEnemy()
	local enemypics = {"Patrick.png","Squidward.png","Spongebob.png","MrKrab.png"}
	picIndex = enemypics[math.random (#enemypics)]
	print(picIndex)
	local enemy = display.newImage(picIndex)
	enemy:addEventListener ( "tap", shipSmash )

	-- Return either 1 or 2 
	-- if 1 then the obj comes from the left else from the right
	if math.random(2) == 1 then
		enemy.x = math.random(-100, -10)
	else 
		enemy.x = math.random(display.contentWidth + 10, display.contentWidth + 100)
		enemy.xScale = -1
	end
	enemy.y = math.random (display.contentHeight)
	enemy.trans = transition.to ( enemy, { x=centerX, y=centerY, time=math.random(2500-speedBump, 4500-speedBump), onComplete=hitPlanet } )

end


function startGame()
	local text2 = display.newText("Stop Spongebob and friends from going home!", 0, 0, "Helvetica", 18)
	text2.x = centerX
	text2.y = display.contentHeight - 50
	text2:setTextColor(255, 254, 185)
	local text = display.newText("Tap here to start.", 0, 0, "Helvetica", 18)
	text.x = centerX
	text.y = display.contentHeight - 30
	text:setTextColor(255, 254, 185)

	local function goAway(event)
		levelText = display.newText("LEVEL 1", 0, 0, "Helvetica", 22)
		levelText.x = centerX
		levelText.y = centerY
		levelText.alpha = 0
		local function levelR()
			transition.to(levelText, { time= 2500, alpha=0})
		end
		transition.to(levelText, { time= 1000, alpha=1, onComplete=levelR })

		display.remove(event.target)
		text = nil
		display.remove(gameTitle)
		display.remove(text2)
		spawnEnemy()
		scoreText.alpha = 1
		scoreText.text = "Score: 0"
		score = 0
		planet.numHits = 10
		planet.alpha = 1
		speedBump = 0
		
	end
	text:addEventListener("tap", goAway)
end


local function planetDamage()
	planet.numHits = planet.numHits - 2
	planet.alpha = planet.numHits / 10
	if planet.numHits < 2 then
		planet.alpha = 0
		timer.performWithDelay ( 1000, startGame )
		audio.play ( sndLose )
	else
		local function goAway(obj)
			planet.xScale = 1
			planet.yScale = 1
			planet.alpha = planet.numHits / 10

		end
		transition.to ( planet, { time=200, xScale=1.2, yScale=1.2, alpha=1, onComplete=goAway} )	
	end
end


function hitPlanet(obj)
	display.remove(obj)
	planetDamage()
	audio.play(sndBlast)
	if score > 100 then
		score = score - 56
		scoreText.text = "Score: " .. score
	end
	if planet.numHits > 1 then
		spawnEnemy()
	end
end


function shipSmash(event)
	local obj = event.target
	display.remove( obj )
	-- Awesome
	if picIndex == "Patrick.png" then
		audio.play(sndKill)
	end
	if picIndex == "Spongebob.png" then
		audio.play(sndKill)
	end
	if picIndex == "MrKrab.png" then
		audio.play(sndKill)
	end
	if picIndex == "squidward.png" then
		audio.play(sndKill)
	end
	transition.cancel ( event.target.trans )
	score = score + 28

	-- Enemy Speed change?
	speedBump = speedBump + 50

	scoreText.text = "Score: " .. score
	
	spawnEnemy()
	return true
end

timer.performWithDelay(15000, levelUpdate, 5)
createPlayScreen()



--[[
	---------------------------------------------------------
                    RCT Randomizer
    
    RCT Randomizer is a lua-app playing a random voicefile
    from /Apps/StartVoices when model is selected or transmitter
    is powered on. Includes a test-switch possibility.
    
    Works in DC/DS-14/16/24 with firmware 4.22 and up
	---------------------------------------------------------
	Localization-file has to be as /Apps/Lang/RCT-Wind.jsn
    
    Requires a folder /Apps/StartVoices to be added with some
    audio-files in it, example:
    
    HelloWorld-file: /Apps/StartVoices/HelloWorld.wav
    
	---------------------------------------------------------
	RCT Randomizer is part of RC-Thoughts Jeti Tools.
	---------------------------------------------------------
	Released under MIT-license by Tero @ RC-Thoughts.com 2018
	---------------------------------------------------------
--]]
--------------------------------------------------------------------------------
-- Locals for application
local audioFiles, playDone, lastPlay, folder, testSw = {}, false, "", "Apps/StartVoices"
--------------------------------------------------------------------------------
-- Read and set translations
local function setLanguage()
    local lng=system.getLocale()
    local file = io.readall("Apps/Lang/RCT-VRan.jsn")
    local obj = json.decode(file)
    if(obj) then
        trans32 = obj[lng] or obj[obj.default]
    end
end
--------------------------------------------------------------------------------
function voiceDir()
    for name, filetype in dir(""..folder.."") do
        if(filetype == "file") then
            local fullName = string.format("/%s/%s", folder, name)
            table.insert(audioFiles, fullName)
        end
    end
end
--------------------------------------------------------------------------------
local function randomPlay()
    math.randomseed(math.random(system.getTimeCounter()))
    system.pLoad("lastPlay", "")
    repeat
        audioFile = (audioFiles[math.random(#audioFiles)])
    until audioFile ~= lastPlay
    system.playFile(audioFile,AUDIO_QUEUE)
    system.pSave("lastPlay", audioFile)
end
----------------------------------------------------------------------
-- Actions when settings changed
local function testSwChanged(value)
    local pSave = system.pSave
	testSw = value
	pSave("testSw", value)
end
--------------------------------------------------------------------------------
-- Draw the main form (Application interface)
local function initForm()
    local form, addRow, addLabel = form, form.addRow ,form.addLabel
    local addLink, addInputbox = form.addLink, form.addInputbox 
    
    addRow(1)
    addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
    
    addRow(2)
    addLabel({label=trans32.testSw, width=220})
    addInputbox(testSw, true, testSwChanged)
    
    addRow(1)
    addLabel({label="Powered by RC-Thoughts.com - v."..randomizerVersion.." ", font=FONT_MINI, alignRight=true})
    collectgarbage()
end
--------------------------------------------------------------------------------
local function loop()
    testFile = system.getInputsVal(testSw)
    if(testFile == 1 and not playDone) then  
        randomPlay()
        playDone = true
    end
    if(testFile ~= 1) then
        playDone = false
    end
    collectgarbage()
end
--------------------------------------------------------------------------------
local function init()
    local pLoad, registerForm = system.pLoad, system.registerForm
	testSw = pLoad("testSw")
    lastPlay = pLoad("lastPlay", "")
    registerForm(1, MENU_APPS, trans32.appName, initForm)
    voiceDir()
    randomPlay()
    collectgarbage()
end
--------------------------------------------------------------------------------
randomizerVersion = "1.1"
setLanguage()
collectgarbage()
return {init=init, loop=loop, author="RC-Thoughts", version=randomizerVersion, name=trans32.appName}
--[[
For help on MidiHID configurations or to share configurations with other MidiHID users,
visit http://http://code.google.com/p/midihid/.

The "base", "string", "table" and "math" Lua libraries are available. MidiHID provides
an extra "midi" library with the following functions:
	midi.message(message, [data1], [data2])
	midi.noteon(key, [velocity])
	midi.noteoff(key, [velocity])
	midi.controlchange(control, value)
	midi.pitchwheelchange(value)
These functions do not return anything and all their arguments are numerical values
between 0-127 (except for "message" which must be between 0-15).
Arguments in brackets are optional.

To print a message to the log area, use the log() function.
]]

-- Declare button name constants

RED_PAD_ANALOG = "_0025"
YELLOW_PAD_ANALOG = "_0024"
BLUE_PAD_ANALOG = "_0027"
GREEN_PAD_ANALOG = "_0026"

RED_PAD_DIGITAL = "Button_3"
YELLOW_PAD_DIGITAL = "Button_4"
BLUE_PAD_DIGITAL = "Button_1"
GREEN_PAD_DIGITAL = "Button_2"

-- For some reason, only the yellow and blue cymbals trigger the Hatswitch
HI_HAT_DIGITAL = "Hatswitch"
CYMBAL_DIGITAL = "Button_12"
TOM_DIGITAL = "Button_11"

BASS_PEDAL = "Button_5"
HI_HAT_PEDAL = "Button_6"

function _connect()
	log("<CONNECT>")
	cymbals_on = false
	hi_hat_open = false
	velocity = 0
end

function set_velocity(name, value, min, max)
	if name == RED_PAD_ANALOG or name == YELLOW_PAD_ANALOG or name == BLUE_PAD_ANALOG or name == GREEN_PAD_ANALOG then
		--velocity = (100 - (value * 100 / max)) + 50
		velocity = max - value
		if velocity < 50 then
			velocity = 50
		end
	elseif name == BASS_PEDAL then
		if value == 1 then
			velocity = 100
		else
			velocity = 0
		end
  --don't know if hi hat pedal is also velocity sensitive, but not a big deal because it
  --just keeps time when you use it in the simpler cases
  elseif name == HI_HAT_PEDAL then
    if value == 1 then
      velocity = 100
    else
      velocity = 0
    end
	end
end

function set_cymbals(name, value)
	if name == CYMBAL_DIGITAL then 
		cymbals_on = true
	elseif name == TOM_DIGITAL then
		cymbals_on = false
	end
end

function set_hi_hat(name, value)
	if name == HI_HAT_PEDAL then
		if value == 1 then
			hi_hat_open = true
		else
			hi_hat_open = false
		end
	end
end

function set_note_on(name, value)
	if name == CYMBAL_DIGITAL or name == TOM_DIGITAL or BASS_PEDAL then
		if value == 0 then
			note_on = false
		else
			note_on = true
		end
	end
end

function send_note(name, value)
	local note_num = 0
	if name == RED_PAD_DIGITAL or name == YELLOW_PAD_DIGITAL or name == BLUE_PAD_DIGITAL or name == GREEN_PAD_DIGITAL or name == BASS_PEDAL then
		if name == RED_PAD_DIGITAL then
			note_num = 38 -- snare
		elseif name == YELLOW_PAD_DIGITAL then
			if cymbals_on then
				if hi_hat_open then
					note_num = 42 -- closed hi-hat
				else
					note_num = 46 -- open hi-hat
				end
			else
				note_num = 50 -- high tom 1
			end
		elseif name == BLUE_PAD_DIGITAL then
			if cymbals_on then
				note_num = 51 -- ride
			else
				note_num = 47 -- mid tom 1
			end
		elseif name == GREEN_PAD_DIGITAL then
			if cymbals_on then
				note_num = 49 -- crash
			else
				note_num = 43 -- low tom 1
			end
		elseif name == BASS_PEDAL then
			note_num = 36 -- bass drum
    elseif name == HI_HAT_PEDAL then
      note_num = 42 -- hi hat hit with foot pedal, ie closed hi hat
		end
		
	     if note_on then
			--log("Sending note " .. note_num .. ": " .. velocity .. " (" .. value .. ")")
			midi.noteon(note_num, velocity)
		else
	     	--log("Turning off " .. note_num)
			midi.noteoff(note_num, 0)
		end
	end	
end

function _event(name, value, min, max)
	--log("[" .. name .. "] = " .. value .. " (" .. min .. " | " .. max .. ")")
	--midi.controlchange(1, (value - min) / (max - min) * 127)
	
	-- Since the events seem to always come in the same order, save some state to determine which drum pad was actually hit
	-- This is because a cymbal hit corresponds to two simultaneous button presses
	-- The events seem to be: Velocity-sensitive (analog) input, cymbal switch (buttons 12/11), digital input
	set_velocity(name, value, min, max)
	set_cymbals(name, value)
	set_hi_hat(name, value)
	set_note_on(name, value)
	send_note(name, value)
end

function _disconnect()
	log("<DISCONNECT>")
end

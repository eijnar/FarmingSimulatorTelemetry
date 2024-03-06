FSTelemetry = {}

local FSContext = {
	UpdateInterval = {
		Target = 16.66, --Restrict to 60 FPS. 16.66 = 1000ms / 60 frames
		Current = 0.0
	},
	MaxDepthImplements = 10,
	Telemetry = {}
};

function FSTelemetry:loadMap(name)
	FSTelemetry:ClearGameTelemetry();
	FSTelemetry:ClearVehicleTelemetry();
	FSTelemetry:ProcessGameEdition();
end;

function FSTelemetry:update(dt)
	FSContext.UpdateInterval.Current = FSContext.UpdateInterval.Current + dt;
	if FSContext.UpdateInterval.Current >= FSContext.UpdateInterval.Target then
		FSContext.UpdateInterval.Current = 0;

		FSContext.Telemetry.IsDrivingVehicle = FSTelemetry:IsDrivingVehicle();
		if FSContext.Telemetry.IsDrivingVehicle then
			FSTelemetry:ProcessVehicleData();
		else
			FSTelemetry:ClearVehicleTelemetry();
		end;

		FSTelemetry:ProcessGameData();
		FSTelemetry:WriteTelemetry();
	end;
end;

function FSTelemetry:ClearGameTelemetry()
	FSContext.Telemetry.Money = 0.0;
	FSContext.Telemetry.TemperatureMin = 0.0;
	FSContext.Telemetry.TemperatureMax = 0.0;
	FSContext.Telemetry.TemperatureTrend = 0;
	FSContext.Telemetry.DayTimeMinutes = 0;
	FSContext.Telemetry.WeatherCurrent = 0;
	FSContext.Telemetry.WeatherNext = 0;
	FSContext.Telemetry.Day = 0;
	FSContext.Telemetry.GameEdition = 0;
end

function FSTelemetry:ClearVehicleTelemetry()
	FSContext.Telemetry.VehicleName = "";
	FSContext.Telemetry.FuelType = 0;  --0 Undefined | 1 Diesel | 2 Eletric | 3 Methane
	FSContext.Telemetry.FuelMax = 0.0;
	FSContext.Telemetry.Fuel = 0.0;
	FSContext.Telemetry.RPMMin = 0;
	FSContext.Telemetry.RPMMax = 0;
	FSContext.Telemetry.RPM = 0;
	FSContext.Telemetry.IsDrivingVehicle = false;
	FSContext.Telemetry.IsAiActive = false;
	FSContext.Telemetry.Wear = 0.0;
	FSContext.Telemetry.OperationTimeMinutes = 0;
	FSContext.Telemetry.Speed = 0.0;
	FSContext.Telemetry.IsEngineStarted = false;
	FSContext.Telemetry.Gear = 0;
	FSContext.Telemetry.IsLightOn = false;
	FSContext.Telemetry.IsLightHighOn = false;
	FSContext.Telemetry.IsLightTurnRightEnabled = false;
	FSContext.Telemetry.IsLightTurnRightOn = false;
	FSContext.Telemetry.IsLightTurnLeftEnabled = false;
	FSContext.Telemetry.IsLightTurnLeftOn = false;
	FSContext.Telemetry.IsLightHazardOn = false;
	FSContext.Telemetry.IsLightBeaconOn = false;
	FSContext.Telemetry.IsWipersOn = false;
	FSContext.Telemetry.IsCruiseControlOn = false;
	FSContext.Telemetry.CruiseControlMaxSpeed = 0;
	FSContext.Telemetry.CruiseControlSpeed = 0;
	FSContext.Telemetry.IsHandBrakeOn = false;
	FSContext.Telemetry.IsReverseDriving = false;
	FSContext.Telemetry.IsMotorFanEnabled = false;
	FSContext.Telemetry.MotorTemperature = 0.0;
	FSContext.Telemetry.VehiclePrice = 0.0;
	FSContext.Telemetry.VehicleSellPrice = 0.0;
	FSContext.Telemetry.IsHonkOn = false;
	FSContext.Telemetry.AngleRotation = 0.0;
	FSContext.Telemetry.Mass = 0.0;
	FSContext.Telemetry.TotalMass = 0.0;
	FSContext.Telemetry.IsOnField = false;
	FSContext.Telemetry.DefMax = 0.0;
	FSContext.Telemetry.Def = 0.0;
	FSContext.Telemetry.AirMax = 0.0;
	FSContext.Telemetry.Air = 0.0;
	FSTelemetry:ClearAttachedImplements();
end

function FSTelemetry:ClearAttachedImplements()
	FSContext.Telemetry.AttachedImplementsPosition = {};
	FSContext.Telemetry.AttachedImplementsLowered = {};
	FSContext.Telemetry.AttachedImplementsSelected = {};
	FSContext.Telemetry.AttachedImplementsTurnedOn = {};
	FSContext.Telemetry.AttachedImplementsUnfolded = {};
	FSContext.Telemetry.AttachedImplementsisFoldable = {};
	FSContext.Telemetry.AttachedImplementsWear = {};
end

function FSTelemetry:IsDrivingVehicle()
	local vehicle = g_currentMission.controlledVehicle;
	local hasVehicle = vehicle ~= nil;
	return hasVehicle and vehicle.spec_motorized ~= nil;
end

function FSTelemetry:ProcessVehicleData()
	local mission = g_currentMission;
	local vehicle = mission.controlledVehicle;
	local motor = vehicle:getMotor();
	local specMotorized = vehicle.spec_motorized;
	local specDrivable = vehicle.spec_drivable;
	local specLights = vehicle.spec_lights;
	local specWipers = vehicle.spec_wipers;
	local specHonk = vehicle.spec_honk;
	local specWearable = vehicle.spec_wearable;
		
	FSTelemetry:ProcessPrice(vehicle);
	FSTelemetry:ProcessMotorFanEnabled(specMotorized);
	FSTelemetry:ProcessMotorTemperature(specMotorized);
	FSTelemetry:ProcessSpeed(vehicle, specMotorized);
	FSTelemetry:ProcessGear(motor);
	FSTelemetry:ProcessRPM(motor);
	FSTelemetry:ProcessReverseDriving(vehicle, specMotorized);
	FSTelemetry:ProcessEngineStarted(specMotorized);
	FSTelemetry:ProcessVehicleName(mission);
	FSTelemetry:ProcessAiActive(vehicle);
	FSTelemetry:ProcessWear(specWearable);
	FSTelemetry:ProcessOperationTime(vehicle);
	FSTelemetry:ProcessFuel(vehicle, specMotorized);
	FSTelemetry:ProcessCruiseControl(specDrivable);
	FSTelemetry:ProcessHandBrake(specDrivable);
	FSTelemetry:ProcessTurnLightsHazard(specLights);
	FSTelemetry:ProcessLightBeacon(specLights);
	FSTelemetry:ProcessLight(specLights);
	FSTelemetry:ProcessWiper(specWipers, mission);
	FSTelemetry:ProcessHonk(specHonk);

	FSTelemetry:ClearAttachedImplements();
	FSTelemetry:ProcessAttachedImplements(vehicle, false, 0, 0);

	FSTelemetry:ProcessAngleRotation(vehicle);
	FSTelemetry:ProcessMass(vehicle);
	FSTelemetry:ProcessOnField(vehicle);
	FSTelemetry:ProcessDef(vehicle);
	FSTelemetry:ProcessAir(vehicle);
end

function FSTelemetry:ProcessAttachedImplements(vehicle, invertX, x, depth)
    local attachedImplements = vehicle:getAttachedImplements()
    if not attachedImplements then
        return
    end

    for _, implement in pairs(attachedImplements) do
        local object = implement.object
        if object and object.schemaOverlay then
			local isFoldable = object.spec_foldable ~= nil
            local wear = object.getDamageAmount and object:getDamageAmount() or 0.0
            local selected = object:getIsSelected()
            local turnedOn = object.getIsTurnedOn and object:getIsTurnedOn()
            local lowered = object.getIsLowered and object:getIsLowered(true)
            local unfolded = isFoldable and object.getIsUnfolded and object:getIsUnfolded() or false
            
            local jointDesc = vehicle.schemaOverlay.attacherJoints[implement.jointDescIndex]
            if jointDesc then
                local invertX = invertX ~= jointDesc.invertX
                local baseX = invertX and x - 1 + (1 - jointDesc.x) or x + jointDesc.x
                baseX = math.ceil(baseX)

                FSContext.Telemetry.AttachedImplementsPosition[baseX] = baseX
                FSContext.Telemetry.AttachedImplementsLowered[baseX] = lowered
                FSContext.Telemetry.AttachedImplementsSelected[baseX] = selected
                FSContext.Telemetry.AttachedImplementsTurnedOn[baseX] = turnedOn
                FSContext.Telemetry.AttachedImplementsUnfolded[baseX] = unfolded
				FSContext.Telemetry.AttachedImplementsisFoldable[baseX] = isFoldable
                FSContext.Telemetry.AttachedImplementsWear[baseX] = wear

                if FSContext.MaxDepthImplements > depth then
                    FSTelemetry:ProcessAttachedImplements(object, invertX, baseX, depth + 1)
                end
            end
        end
    end
end


function FSTelemetry:ProcessMotorFanEnabled(motorized)
	if motorized ~= nil and motorized.motorFan ~= nil then
		FSContext.Telemetry.IsMotorFanEnabled = motorized.motorFan.enabled;
	else
		FSContext.Telemetry.IsMotorFanEnabled = false;
	end;
end

function FSTelemetry:ProcessMotorTemperature(motorized)
	if motorized ~= nil and motorized.motorTemperature ~= nil then
		FSContext.Telemetry.MotorTemperature = motorized.motorTemperature.value;
	else
		FSContext.Telemetry.MotorTemperature = 0;
	end;
end

function FSTelemetry:ProcessSpeed(vehicle, motorized)
	if motorized ~= nil and vehicle.getLastSpeed ~= nil then
		FSContext.Telemetry.Speed = math.max(0.0, vehicle:getLastSpeed() * motorized.speedDisplayScale)
	else
		FSContext.Telemetry.Speed = 0;
	end;
end

function FSTelemetry:ProcessRPM(motor)
	if motor ~= nil then
		if motor.getMinRpm ~= nil then
			FSContext.Telemetry.RPMMin = math.ceil(motor:getMinRpm());
		else
			FSContext.Telemetry.RPMMin = 0;
		end	

		if motor.getMaxRpm ~= nil then
			FSContext.Telemetry.RPMMax = math.ceil(motor:getMaxRpm());
		else
			FSContext.Telemetry.RPMMax = 0;
		end

		if motor.getLastRealMotorRpm ~= nil then
			FSContext.Telemetry.RPM = math.ceil(motor:getLastRealMotorRpm());
		else
			FSContext.Telemetry.RPM = 0;
		end
	end;
end

function FSTelemetry:ProcessPrice(vehicle)
	if vehicle ~= nil then
		if vehicle.getPrice ~= nil then
			FSContext.Telemetry.VehiclePrice = vehicle:getPrice();
		else
			FSContext.Telemetry.VehiclePrice = 0.0;
		end

		if vehicle.getSellPrice ~= nil then
			FSContext.Telemetry.VehicleSellPrice = vehicle:getSellPrice();
		else
			FSContext.Telemetry.VehicleSellPrice = 0.0;
		end
	end;
end

function FSTelemetry:ProcessGear(motor)
	if motor ~= nil then
		FSContext.Telemetry.Gear = motor.gear;
	end;
end

function FSTelemetry:ProcessReverseDriving(vehicle, motorized)
	local reverserDirection = vehicle.getReverserDirection == nil and 1 or vehicle:getReverserDirection();
	FSContext.Telemetry.IsReverseDriving = vehicle:getLastSpeed() > motorized.reverseDriveThreshold and vehicle.movingDirection ~= reverserDirection;
end

function FSTelemetry:ProcessEngineStarted(motorized)
	FSContext.Telemetry.IsEngineStarted = motorized ~= nil and motorized.isMotorStarted;
end

function FSTelemetry:ProcessVehicleName(mission)
	FSContext.Telemetry.VehicleName = mission.currentVehicleName;
end

function FSTelemetry:ProcessAiActive(vehicle)
	FSContext.Telemetry.IsAiActive = vehicle.getIsAIActive ~= nil and vehicle:getIsAIActive();
end

function FSTelemetry:ProcessWear(wearable)
	if wearable ~= nil and wearable.damage ~= nil then
		FSContext.Telemetry.Wear = wearable.damage;
	else
		FSContext.Telemetry.Wear = 0.0;
	end;
end

function FSTelemetry:ProcessOperationTime(vehicle)
	if vehicle.operatingTime ~= nil then
		FSContext.Telemetry.OperationTimeMinutes = math.floor(vehicle.operatingTime / (1000 * 60));
	else
		FSContext.Telemetry.OperationTimeMinutes = 0;
	end;
end

function FSTelemetry:ProcessFuel(vehicle, motorized)
	FSContext.Telemetry.FuelType = 0;
	FSContext.Telemetry.FuelMax = 0;
	FSContext.Telemetry.Fuel = 0;

	if motorized == nil then
		return;
	end

	for _, consumer in pairs(motorized.consumersByFillTypeName) do		
		if consumer.fillType == FillType.DIESEL then
			FSContext.Telemetry.FuelType = 1;
		elseif consumer.fillType == FillType.ELECTRICCHARGE then
			FSContext.Telemetry.FuelType = 2;
		elseif consumer.fillType == FillType.METHANE then
			FSContext.Telemetry.FuelType = 3;
		end

		if FSContext.Telemetry.FuelType > 0 then
			if vehicle.getFillUnitCapacity ~= nil then
				FSContext.Telemetry.FuelMax = vehicle:getFillUnitCapacity(consumer.fillUnitIndex);
			end;
			if vehicle.getFillUnitFillLevel ~= nil then
				FSContext.Telemetry.Fuel = vehicle:getFillUnitFillLevel(consumer.fillUnitIndex);
			end;
			return;
		end
	end
end

function FSTelemetry:ProcessCruiseControl(drivable)
	if drivable ~= nil then
		--Drivable.CRUISECONTROL_STATE_OFF
		--Drivable.CRUISECONTROL_STATE_ACTIVE
		--Drivable.CRUISECONTROL_STATE_FULL
		FSContext.Telemetry.IsCruiseControlOn = drivable.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_OFF;
		FSContext.Telemetry.CruiseControlSpeed = drivable.cruiseControl.speed;
		FSContext.Telemetry.CruiseControlMaxSpeed = drivable.cruiseControl.maxSpeed;
	else
		FSContext.Telemetry.IsCruiseControlOn = false;
		FSContext.Telemetry.CruiseControlSpeed = 0;
		FSContext.Telemetry.CruiseControlMaxSpeed = 0;
	end
end

--Aparently, it does'nt work
function FSTelemetry:ProcessHandBrake(drivable)
	if drivable ~= nil then
		FSContext.Telemetry.IsHandBrakeOn = drivable.doHandbrake;
	else
		FSContext.Telemetry.IsHandBrakeOn = false;
	end
end

function FSTelemetry:ProcessTurnLightsHazard(lights)
	if lights ~= nil and lights.turnLightState ~= nil then
		local state = lights.turnLightState;
		FSContext.Telemetry.IsLightTurnRightEnabled = state == Lights.TURNLIGHT_RIGHT;
		FSContext.Telemetry.IsLightTurnLeftEnabled = state == Lights.TURNLIGHT_LEFT;
		FSContext.Telemetry.IsLightHazardOn = state == Lights.TURNLIGHT_HAZARD;

		local alpha = MathUtil.clamp((math.cos(7 * getShaderTimeSec()) + 0.2), 0, 1)
		FSContext.Telemetry.IsLightTurnRightOn = (FSContext.Telemetry.IsLightTurnRightEnabled or FSContext.Telemetry.IsLightHazardOn) and alpha > 0.5;
		FSContext.Telemetry.IsLightTurnLeftOn = (FSContext.Telemetry.IsLightTurnLeftEnabled or FSContext.Telemetry.IsLightHazardOn) and alpha > 0.5;
	else
		FSContext.Telemetry.IsLightTurnRightEnabled = false;
		FSContext.Telemetry.IsLightTurnRightOn = false;
		FSContext.Telemetry.IsLightTurnLeftEnabled = false;
		FSContext.Telemetry.IsLightTurnLeftOn = false;
		FSContext.Telemetry.IsLightHazardOn = false;
	end;
end

function FSTelemetry:ProcessLightBeacon(lights)
	if lights ~= nil and lights.getBeaconLightsVisibility ~= nil then
		FSContext.Telemetry.IsLightBeaconOn = lights:getBeaconLightsVisibility();
	else
		FSContext.Telemetry.IsLightBeaconOn = false;
	end;
end

function FSTelemetry:ProcessLight(lights)
	if lights ~= nil and lights.lightsTypesMask ~= nil then
		--0 - LIGHT				
		--1 - TURN LIGHT
		--2 - FRONTAL LIGHT
		--3 - HIGH LIGHT

		FSContext.Telemetry.IsLightOn = bitAND(lights.lightsTypesMask, 2^0) ~= 0;
		FSContext.Telemetry.IsLightHighOn = bitAND(lights.lightsTypesMask, 2^3) ~= 0;
	else
		FSContext.Telemetry.IsLightOn = false;
		FSContext.Telemetry.IsLightHighOn = false;
	end;
end

function FSTelemetry:ProcessWiper(wipers, mission)
	FSContext.Telemetry.IsWipersOn = false;
	if wipers ~= nil and wipers.hasWipers then
		local rainScale = (mission.environment ~= nil and mission.environment.weather ~= nil and mission.environment.weather.getRainFallScale ~= nil) and mission.environment.weather:getRainFallScale() or 0;
		if rainScale > 0 then
			for _, wiper in pairs(wipers.wipers) do
				for stateIndex,state in ipairs(wiper.states) do
					if rainScale <= state.maxRainValue then
						FSContext.Telemetry.IsWipersOn = true;
						return
					end
				end
			end
		end
	end;
end

function FSTelemetry:ProcessHonk(honk)
	FSContext.Telemetry.IsHonkOn = false;
	if honk ~= nil and honk.isPlaying ~= nil then
		FSContext.Telemetry.IsHonkOn = honk.isPlaying;
	end;
end

function FSTelemetry:ProcessAngleRotation(vehicle)
	local x,y,z = localDirectionToWorld(vehicle.rootNode, 0, 0, 1);
	local length = MathUtil.vector2Length(x,z);
	local dX = x/length
	local dZ = z/length
	local direction = 180 - math.deg(math.atan2(dX,dZ))
	--local rX, rY, rZ = getRotation(vehicle.rootNode)
	--print(math.deg(rY % (2*math.pi)));
	--local posX, posY, posZ, rotY = g_currentMission.player:getPositionData();
	--print(math.deg(-rotY % (2*math.pi)));

	--local posX, posY, posZ = getTranslation(vehicle.rootNode)
	--print("posX: " .. posX .. "posZ: " .. posZ);

	FSContext.Telemetry.AngleRotation = direction;
end

function FSTelemetry:ProcessMass(vehicle)
	if vehicle.getTotalMass ~= nil then
		FSContext.Telemetry.Mass = vehicle:getTotalMass(true);
		FSContext.Telemetry.TotalMass = vehicle:getTotalMass(false);
	else
		FSContext.Telemetry.Mass = 0.0;
		FSContext.Telemetry.TotalMass = 0.0;
	end
end

function FSTelemetry:ProcessOnField(vehicle)
	FSContext.Telemetry.IsOnField = vehicle.getIsOnField ~= nil and vehicle:getIsOnField();
end

function FSTelemetry:ProcessDef(vehicle)
	if vehicle.getConsumerFillUnitIndex ~= nil then
		local fillUnitIndex = vehicle:getConsumerFillUnitIndex(FillType.DEF);
		if fillUnitIndex ~= nil then
			FSContext.Telemetry.Def = vehicle:getFillUnitFillLevel(fillUnitIndex);
			FSContext.Telemetry.DefMax = vehicle:getFillUnitCapacity(fillUnitIndex);
			return;
		end
	end
	FSContext.Telemetry.DefMax = 0.0;
	FSContext.Telemetry.Def = 0.0;
end

function FSTelemetry:ProcessAir(vehicle)
	if vehicle.getConsumerFillUnitIndex ~= nil then
		local fillUnitIndex = vehicle:getConsumerFillUnitIndex(FillType.AIR);
		if fillUnitIndex ~= nil then
			FSContext.Telemetry.Air = vehicle.getFillUnitFillLevel ~= nil and vehicle:getFillUnitFillLevel(fillUnitIndex) or 0.0;
			FSContext.Telemetry.AirMax = vehicle.getFillUnitFillLevel ~= nil and vehicle:getFillUnitCapacity(fillUnitIndex) or 0.0;
			return;
		end
	end
	FSContext.Telemetry.AirMax = 0.0;
	FSContext.Telemetry.Air = 0.0;
end

function FSTelemetry:ProcessGameData()
	if g_currentMission.player ~= nil then
        local farm = g_farmManager:getFarmById(g_currentMission.player.farmId)
		if farm ~= nil then
			FSContext.Telemetry.Money = farm.money;
			--g_currentMission.mission.missionInfo.money
		end
    end

	if g_currentMission.environment ~= nil then
		local environment = g_currentMission.environment;
		if environment.weather ~= nil then
			local minTemp, maxTemp = environment.weather:getCurrentMinMaxTemperatures();
			FSContext.Telemetry.TemperatureMin = minTemp;
			FSContext.Telemetry.TemperatureMax = maxTemp;
			FSContext.Telemetry.TemperatureTrend = environment.weather:getCurrentTemperatureTrend();
		end

		FSContext.Telemetry.DayTimeMinutes = math.floor(environment.dayTime / (1000 * 60));

		local sixHours = 6 * 60 * 60 * 1000;
		local dayPlus6h, timePlus6h = environment:getDayAndDayTime(environment.dayTime + sixHours, environment.currentDay);
		FSContext.Telemetry.WeatherCurrent = environment.weather:getWeatherTypeAtTime(environment.currentDay, environment.dayTime);
		FSContext.Telemetry.WeatherNext = environment.weather:getWeatherTypeAtTime(dayPlus6h, timePlus6h);

		FSContext.Telemetry.Day = environment.currentDay;
	end
end

function FSTelemetry:ProcessGameEdition()
	FSContext.Telemetry.GameEdition = 19;
	if g_minModDescVersion == 60 then
		FSContext.Telemetry.GameEdition = 22;
	end
end

-- Process telemetry for output

function FSTelemetry:BuildBodyText()
    local text = "{"
    local isFirstPair = true
    for key, value in pairs(FSContext.Telemetry) do
        if not isFirstPair then
            text = text .. ", "
        end
        text = text .. FSTelemetry:AddKeyValue(key, value)
        isFirstPair = false
    end
    return text .. "}"
end

function FSTelemetry:AddKeyValue(key, value)
    local valueStr = ""
    local valueType = type(value)

    if valueType == "boolean" or valueType == "number" then
        valueStr = tostring(value)
    elseif valueType == "string" then
        valueStr = '"' .. value .. '"'
    elseif valueType == "table" then
        valueStr = "{"
        local isFirst = true
        for id, val in pairs(value) do
            if not isFirst then
                valueStr = valueStr .. ", "
            end
            valueStr = valueStr .. '"' .. id .. '":'

            if type(val) == "boolean" or type(val) == "number" then
                valueStr = valueStr .. tostring(val)
            elseif type(val) == "string" then
                valueStr = valueStr .. '"' .. val .. '"'
            else
                valueStr = valueStr .. "null"
            end
            
            isFirst = false
        end
        valueStr = valueStr .. "}"
        if isFirst then
            valueStr = "{}"
        end
    else
        valueStr = "null"
    end

    return '"' .. key .. '":' .. valueStr
end

-- Output

function FSTelemetry:WriteTelemetry(content)
	local file = io.open("fstelemetry.sim", "w");
	if file ~= nil then
		file:write(FSTelemetry:BuildBodyText());
		file:close();
		return true;
	end;
	return false;
end

addModEventListener(FSTelemetry)
	
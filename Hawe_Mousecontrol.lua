--
-- Hawe_Mousecontrol
-- 
-- used to set 'control-variables' in cylinderd2
--
--
-- @author:        fruktor (wwww.modding-society.de)
-- @version:    v0.1
-- @date:        08/12/10
-- @history:    v0.1 - inital implementation
--
-- Copyright (C) 
--

Hawe_Mousecontrol = {};

function Hawe_Mousecontrol.prerequisitesPresent(specializations)
    return true;
end;

function Hawe_Mousecontrol:load(savegame)
    self.doJointSearchCylindered = false;
    self.origMouseControlsAxes = self.mouseControlsAxes;
    self.disaMouseControlsAxes = {};
end;    
    

function Hawe_Mousecontrol:delete()
end;

function Hawe_Mousecontrol:mouseEvent(posX, posY, isDown, isUp, button)
end;

function Hawe_Mousecontrol:keyEvent(unicode, sym, modifier, isDown)
end;

function Hawe_Mousecontrol:update(dt)
end;

function Hawe_Mousecontrol:updateTick(dt)

    if self.varTip ~= nil then
        if self.varTip.activeTrailerIdx ~= self.varTip.trailerNr then
            self.mouseControlsAxes = self.disaMouseControlsAxes;
            return;
        else
            self.mouseControlsAxes = self.origMouseControlsAxes;
        end;
    end;

    -- ####
    if self.doJointSearchCylindered then
        if self.attacherVehicle ~= nil then
            for k,v in pairs(self.attacherVehicle.attachedImplements) do
                if v.object == self then
                    local joint = self.attacherVehicle.attacherJoints[v.jointDescIndex];
                    self.vehicleJoint = joint;
                    self.doJointSearchCylindered = false;
                    break;
                end;
            end;
        end;
        self.doJointSearchCylindered = false;
    end;
    
    -- #### update the attacherJoint!     
    if self.vehicleJoint ~= nil then
        setJointFrame(self.vehicleJoint.jointIndex, 1, self.attacherJoint.node);
    end;
    
    -- ### update PowerShaft!
    --[[
    if self.attacherVehiclePowerShaft ~= nil then
        self.doJointSearch = true;
    end;
    ]]--    
end;

function Hawe_Mousecontrol:draw()
end;

function Hawe_Mousecontrol:onAttach()
    self.doJointSearchCylindered = true;
end;

function Hawe_Mousecontrol:onDetach()
    self.vehicleJoint = nil;
    
    local rX, rY, rZ = getRotation( Utils.indexToObject(self.components, "24") );
    
    if rX > Utils.degToRad(3) then
        self.attacherJoint.jointType = Vehicle.JOINTTYPE_TRAILERLOW;
    else
        self.attacherJoint.jointType = Vehicle.JOINTTYPE_TRAILERLOW;
    end;
end;

function Hawe_Mousecontrol:onLeave()
end;

function Hawe_Mousecontrol:onDeactivate()
end;

function Hawe_Mousecontrol:onDeactivateSounds()
end;



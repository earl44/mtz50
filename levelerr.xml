function levelerr.prerequisitesPresent(specializations)
	    return true;
end

function levelerr:load(savegame)
	
	    self.levelerr = {};
	
	    self.levelerr.pickUpDirection = Utils.getNoNil(getXMLInt(self.xmlFile, "vehicle.levelerr.pickUpDirection"), 1.0);
	
	
	    self.levelerr.nodes = {};
	
	    local i=0;
	    while true do
	        local key = string.format("vehicle.levelerr.levelerrNode(%d)", i);
	        if not hasXMLProperty(self.xmlFile, key) then
	            break;
	        end
	
	        local entry = {};
	        --entry.fillUnitIndex = getXMLInt(self.xmlFile, key .. "#fillUnitIndex");
	        entry.node = Utils.indexToObject(self.components, getXMLString(self.xmlFile, key .. "#index"));
	        entry.width = getXMLFloat(self.xmlFile, key .. "#width");
	
	        entry.minDropWidth = Utils.getNoNil(getXMLFloat(self.xmlFile, key .. "#minDropWidth"), entry.width*0.5);
	        entry.maxDropWidth = Utils.getNoNil(getXMLFloat(self.xmlFile, key .. "#maxDropWidth"), entry.width);
	        entry.minDropHeight = Utils.getNoNil(getXMLFloat(self.xmlFile, key .. "#minDropHeight"), 0);
	        entry.maxDropHeight = Utils.getNoNil(getXMLFloat(self.xmlFile, key .. "#maxDropHeight"), 1);
	        entry.minDropDirOffset = Utils.getNoNil(getXMLFloat(self.xmlFile, key .. "#minDropDirOffset"), 0.7);
	        entry.maxDropDirOffset = Utils.getNoNil(getXMLFloat(self.xmlFile, key .. "#maxDropDirOffset"), 0.7);
	
	        entry.lineOffsetPickUp = nil;
	        entry.lineOffsetDrop = nil;
	
	        entry.lastPickUp = 0;
	        entry.lastDrop = 0;
	
	        table.insert(self.levelerr.nodes, entry);
	
	        i=i+1;
	    end
	
	    self.levelerr.fillUnitIndex = getXMLInt(self.xmlFile, "vehicle.levelerr#fillUnitIndex");
	
	    if self.isClient then
	        self.levelerr.effects = EffectManager:loadEffect(self.xmlFile, "vehicle.levelerrEffects", self.components, self);
	        for i,effect in pairs(self.levelerr.effects) do
	            if effect.node ~= nil then
	                effect.speed = Utils.getNoNil(getXMLFloat(self.xmlFile, string.format("vehicle.levelerrEffects.effectNode(%d)#speed", i-1)), 1) * 0.001;
	                effect.maxHeight = Utils.getNoNil(getXMLFloat(self.xmlFile, string.format("vehicle.levelerrEffects.effectNode(%d)#maxHeight", i-1)), 1);
	                effect.scrollPosition = 0;
	                effect.depthTarget = 0;
	            end
	        end
	    end
	
	end


function levelerr:update(dt)
	    if self:getIsActive() then
	        if self.isClient then
	            local fillType = self:getUnitFillType(self.levelerr.fillUnitIndex);
	            local visible = self:getUnitFillLevel(self.levelerr.fillUnitIndex) > 2*TipUtil.getMinValidLiterValue(fillType);
	            if visible and fillType ~= FillUtil.FILLTYPE_UNKNOWN then
	                EffectManager:setFillType(self.levelerr.effects, fillType)
	                EffectManager:startEffects(self.levelerr.effects);
	
	                local fillPercentage =self:getUnitFillLevel(self.levelerr.fillUnitIndex) / self:getUnitCapacity(self.levelerr.fillUnitIndex);
	
	                for _,effect in pairs(self.levelerr.effects) do
	                    if effect.depthTarget ~= nil then
	
	                        if effect.depthTarget < fillPercentage then
	                            effect.depthTarget = math.min(fillPercentage, effect.depthTarget + 0.001*dt);
	                        elseif effect.depthTarget > fillPercentage then
	                            effect.depthTarget = math.max(fillPercentage, effect.depthTarget - 0.001*dt);
	                        end
	
	                        local speed = self.movingDirection * effect.speed * self:getLastSpeed();
	                        effect.scrollPosition = effect.scrollPosition + speed;
	
	                        setShaderParameter(effect.node, "VertxoffsetVertexdeformMotionUVscale", effect.maxHeight, effect.depthTarget, effect.scrollPosition, 6.0, false);
	
	                        setVisibility(effect.node, true);
	                    end
	                end
	            else
	                EffectManager:stopEffects(self.levelerr.effects);
	                for _,effect in pairs(self.levelerr.effects) do
	                    if effect.node ~= nil then
	                        effect.depthTarget = 0;
	                        effect.scrollPosition = 0;
	                        setVisibility(effect.node, false);
	                    end
	                end
	            end
	        end
	    end
	
	    if self:getIsActive() and self.isServer then
	
	        local fillFactor = 1;
	        local emptyFactor = 1;
	
	        for _,levelerrNode in pairs(self.levelerr.nodes) do
	
	            local fillType = self:getUnitFillType(self.levelerr.fillUnitIndex);
	            local fillLevel = self:getUnitFillLevel(self.levelerr.fillUnitIndex);
	
	            if fillType == FillUtil.FILLTYPE_UNKNOWN or fillLevel < TipUtil.getMinValidLiterValue(fillType) + 0.001 then
	                local x0,y0,z0 = localToWorld(levelerrNode.node, -levelerrNode.width, 0, 0.5*levelerrNode.maxDropDirOffset);
	                local x1,y1,z1 = localToWorld(levelerrNode.node,  levelerrNode.width, 0, 0.5*levelerrNode.maxDropDirOffset);
	
	                local newFillType = TipUtil.getFillTypeAtLine(x0,y0,z0, x1,y1,z1, 0.5*levelerrNode.maxDropDirOffset);
	                if newFillType ~= FillUtil.FILLTYPE_UNKNOWN and newFillType ~= fillType then
	                    self:setUnitFillLevel(self.levelerr.fillUnitIndex, 0);
	                    fillType = newFillType;
	                end
	            end
	            local heightType = TipUtil.fillTypeToHeightType[fillType];
	
	
	            if fillType ~= FillUtil.FILLTYPE_UNKNOWN and heightType ~= nil then
	
	                local innerRadius = 0;
	                local outerRadius = TipUtil.getDefaultMaxRadius(fillType);
	
	                -- use occlusion areas only, if they are close to the ground
	                local tipOcclusionAreas = {};
	                -- temporary disabled
	                --for _,area in pairs(self.tipOcclusionAreas) do
	                --    local xs,ys,zs = getWorldTranslation(area.start);
	                --    local xw,yw,zw = getWorldTranslation(area.width);
	                --    local xh,yh,zh = getWorldTranslation(area.height);
	                --
	                --    local x1 = xs + 0.5*(xh - xs);
	                --    local y1 = ys + 0.5*(yh - ys);
	                --    local z1 = zs + 0.5*(zh - zs);
	                --
	                --    local x2 = xw + 0.5*(xh - xs);
	                --    local y2 = yw + 0.5*(yh - ys);
	                --    local z2 = zw + 0.5*(zh - zs);
	                --
	                --    local h1 = TipUtil.getHeightAtWorldPos(x1,y1,z1);
	                --    local h2 = TipUtil.getHeightAtWorldPos(x2,y2,z2);
	                --
	                --    if h1 > y1 - 0.5 and h2 > y2 - 0.5 then
	                --        table.insert(tipOcclusionAreas, area);
	                --    end
	                --end
	
	                local capacity = self:getUnitCapacity(self.levelerr.fillUnitIndex);
	
	                -- pick up at node
	                if self.levelerr.pickUpDirection == self.movingDirection then
	                    local sx,sy,sz = localToWorld(levelerrNode.node, -levelerrNode.width, 0, 0);
	                    local ex,ey,ez = localToWorld(levelerrNode.node,  levelerrNode.width, 0, 0);
	
	                    local fillLevel = self:getUnitFillLevel(self.levelerr.fillUnitIndex);
	                    local delta = -fillFactor * (capacity-fillLevel);
	
	                    levelerrNode.lastPickUp, levelerrNode.lineOffsetPickUp = TipUtil.tipToGroundAroundLine(self, delta, fillType, sx,sy-0.1,sz, ex,ey-0.1,ez, innerRadius, outerRadius, levelerrNode.lineOffsetPickUp, true, nil);
	
	                    if levelerrNode.lastPickUp < 0 then
	                        self:setUnitFillLevel(self.levelerr.fillUnitIndex, fillLevel - levelerrNode.lastPickUp, fillType, nil, nil);
	                    end
	                end
	
	                -- drop at node
	                local fillLevel = self:getUnitFillLevel(self.levelerr.fillUnitIndex);
	                if fillLevel > 0 then
	                    local f = (fillLevel/capacity);
	                    local width = Utils.lerp(levelerrNode.minDropWidth, levelerrNode.maxDropWidth, f);
	
	                    local sx,sy,sz = localToWorld(levelerrNode.node, -width, 0, 0);
	                    local ex,ey,ez = localToWorld(levelerrNode.node,  width, 0, 0);
	
	                    local delta = math.min(fillLevel, emptyFactor * fillLevel);
	                    local yOffset = -0.1 -0.05;
	
	                    levelerrNode.lastDrop1, levelerrNode.lineOffsetDrop1 = TipUtil.tipToGroundAroundLine(self, delta, fillType, sx,sy+yOffset,sz, ex,ey+yOffset,ez, innerRadius, outerRadius, levelerrNode.lineOffsetDrop1, true, tipOcclusionAreas);
	                    if levelerrNode.lastDrop1 > 0 then
	                        self:setUnitFillLevel(self.levelerr.fillUnitIndex, fillLevel - levelerrNode.lastDrop1, fillType, nil, nil);
	                    end
	                end
	
	                -- drop further at front
	                local fillLevel = self:getUnitFillLevel(self.levelerr.fillUnitIndex);
	
	                if fillLevel > 0 then
	                    local f = (fillLevel/capacity);
	                    local width = Utils.lerp(levelerrNode.minDropWidth, levelerrNode.maxDropWidth, f);
	
	                    local yOffset = Utils.lerp(levelerrNode.minDropHeight, levelerrNode.maxDropHeight, f);
	
	                    local delta = math.min(fillLevel, emptyFactor * fillLevel);
	
	                    local sx,sy,sz = localToWorld(levelerrNode.node, -width, 0, 0);
	                    local ex,ey,ez = localToWorld(levelerrNode.node,  width, 0, 0);
	                    local dx,dy,dz = localDirectionToWorld(levelerrNode.node, 0, 0, 1);
	
	                    local backOffset = -outerRadius * self.levelerr.pickUpDirection * 1.5;
	                    local backLen = Utils.lerp(levelerrNode.minDropDirOffset, levelerrNode.maxDropDirOffset, f) - backOffset;
	
	                    local backX,backY,backZ = dx*backOffset,dy*backOffset,dz*backOffset;
	                    dx,dy,dz = dx*backLen,dy*backLen,dz*backLen;
	

	                    addDensityMapHeightOcclusionArea(TipUtil.terrainDetailHeightUpdater, sx+backX,sy+backY,sz+backZ, ex-sx,ey-sy,ez-sz, dx, dy, dz, true);
	                    if width < levelerrNode.width-0.05 then
	                        -- fully block left and right of the inner block area
	                        local sx2,sy2,sz2 = localToWorld(levelerrNode.node, -levelerrNode.width, 0, 0);
	                        local ex2,ey2,ez2 = localToWorld(levelerrNode.node,  levelerrNode.width, 0, 0);
	
	                        addDensityMapHeightOcclusionArea(TipUtil.terrainDetailHeightUpdater, sx2+backX,sy2+backY,sz2+backZ, sx-sx2,sy-sy2,sz-sz2, dx, dy, dz, false);
	                        addDensityMapHeightOcclusionArea(TipUtil.terrainDetailHeightUpdater, ex +backX,ey +backY,ez +backZ, ex2-ex,ey2-ey,ez2-ez, dx, dy, dz, false);
	                    end
	
	
	                    levelerrNode.lastDrop2, levelerrNode.lineOffsetDrop2 = TipUtil.tipToGroundAroundLine(self, delta, fillType, sx,sy+yOffset,sz, ex,ey+yOffset,ez, 0, outerRadius, levelerrNode.lineOffsetDrop2, true, tipOcclusionAreas);
	                    if levelerrNode.lastDrop2 > 0 then
	                        self:setUnitFillLevel(self.levelerr.fillUnitIndex, fillLevel - levelerrNode.lastDrop2, fillType, nil, nil);
	                    end
	
	                end
	
	            end
	
	        end
	
	
	    end
	end
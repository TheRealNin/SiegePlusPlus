
Script.Load("lua/WallMovementMixin.lua")

local networkVars =
{
    wallWalking = "compensated boolean",
    timeLastWallWalkCheck = "private compensated time",
    bellyYaw = "private float",
    timeSlideEnd = "private time",
    startedSliding = "private boolean",
    sliding = "boolean",
    hasBellySlide = "private boolean",
    timeOfLastPhase = "private time",
}
local kNormalWallWalkFeelerSize = 0.25
local kNormalWallWalkRange = 0.3
function Gorge:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kGorgeFov })
    InitMixin(self, WallMovementMixin)
    InitMixin(self, GorgeVariantMixin)

    Alien.OnCreate(self)

    InitMixin(self, DissolveMixin)
    InitMixin(self, BabblerClingMixin)
    InitMixin(self, BabblerOwnerMixin)
    InitMixin(self, TunnelUserMixin)

    InitMixin(self, PredictedProjectileShooterMixin)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end

    self.bellyYaw = 0
    self.timeSlideEnd = 0
    self.startedSliding = false
    self.sliding = false
    self.verticalVelocity = 0
    self.wallWalking = false
    self.wallWalkingNormalGoal = Vector.yAxis

end
function Gorge:OnInitialized()

    Alien.OnInitialized(self)

    -- Note: This needs to be initialized BEFORE calling SetModel() below
    -- as SetModel() will call GetHeadAngles() through SetPlayerPoseParameters()
    -- which will cause a script error if the Gorge is wall walking BEFORE
    -- the Gorge is initialized on the client.
    self.currentWallWalkingAngles = Angles(0.0, 0.0, 0.0)

    self:SetModel(Gorge.kModelName, kGorgeAnimationGraph)

    if Server then

        self.slideLoopSound = Server.CreateEntity(SoundEffect.kMapName)
        self.slideLoopSound:SetAsset(Gorge.kSlideLoopSound)
        self.slideLoopSound:SetParent(self)

    elseif Client then

        self.currentCameraRoll = 0
        self.goalCameraRoll = 0

        self:AddHelpWidget("GUIGorgeHealHelp", 2)
        self:AddHelpWidget("GUIGorgeBellySlideHelp", 2)
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)

    end

    InitMixin(self, IdleMixin)

end

function Gorge:GetIsWallWalking()
    return self.wallWalking
end

function Gorge:GetIsWallWalkingPossible()
    return not self:GetRecentlyJumped() and not self:GetCrouching()
end

local function PredictGoal(self, velocity)

    PROFILE("Gorge:PredictGoal")

    local goal = self.wallWalkingNormalGoal
    if velocity:GetLength() > 1 and not self:GetIsGround() then

        local movementDir = GetNormalizedVector(velocity)
        local trace = Shared.TraceCapsule(self:GetOrigin(), movementDir * 2.5, Gorge.kXExtents, 0, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))

        if trace.fraction < 1 and not trace.entity then
            goal = trace.normal
        end

    end

    return goal

end

-- Update wall-walking from current origin
function Gorge:PreUpdateMove(input, runningPrediction)

    self.prevY = self:GetOrigin().y

    PROFILE("Gorge:PreUpdateMove")

    if self:GetCrouching() then
        self.wallWalking = false
    end

    if self.wallWalking then

        -- Most of the time, it returns a fraction of 0, which means
        -- trace started outside the world (and no normal is returned)
        local goal = self:GetAverageWallWalkingNormal(kNormalWallWalkRange, kNormalWallWalkFeelerSize)
        if goal ~= nil then

            self.wallWalkingNormalGoal = goal
            self.wallWalking = true

        else
            self.wallWalking = false
        end

    end

    if not self:GetIsWallWalking() then
        -- When not wall walking, the goal is always directly up (running on ground).
        self.wallWalkingNormalGoal = Vector.yAxis
    end

    self.currentWallWalkingAngles = self:GetAnglesFromWallNormal(self.wallWalkingNormalGoal or Vector.yAxis) or self.currentWallWalkingAngles

end

function Gorge:DisableRollPitchSmoothing()
    --do not change roll or pitch briefly after jumping to prevent twitchy wall movement
    return self.timeOfLastJump ~= nil and self.timeOfLastJump + .13 > Shared.GetTime()
end

function Gorge:GetPitchSmoothRate()
    if self:DisableRollPitchSmoothing() then
        return 0
    end
    return 1
end

function Gorge:GetHeadAngles()

    if self:GetIsWallWalking() then
        -- When wallwalking, the angle of the body and the angle of the head is very different
        return self:GetViewAngles()
    else
        return self:GetViewAngles()
    end

end

function Gorge:GetAngleSmoothingMode()

    if self:GetIsWallWalking() then
        return "quatlerp"
    else
        return "euler"
    end

end

function Gorge:GetIsUsingBodyYaw()
    return not self:GetIsWallWalking()
end

function Gorge:OnJump( modifiedVelocity )
    self.wallWalking = false
end

function Gorge:OnWorldCollision(normal, impactForce, newVelocity)

    PROFILE("Gorge:OnWorldCollision")

    self.wallWalking = self:GetIsWallWalkingPossible() and normal.y < 0.5

end

function Gorge:OverrideUpdateOnGround(onGround)
    return onGround or self:GetIsWallWalking()
end

function Gorge:ModifyGravityForce(gravityTable)

    if self:GetIsWallWalking() and not self:GetCrouching() then
        gravityTable.gravity = 0

    elseif self:GetIsOnGround() then
        gravityTable.gravity = 0

    end

end

function Gorge:GetPerformsVerticalMove()
    return self:GetIsWallWalking()
end

function Gorge:GetMoveSpeedIs2D()
    return not self:GetIsWallWalking()
end

function Gorge:GetCanStep()
    return not self:GetIsWallWalking()
end

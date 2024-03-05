codeunit 56200 "Secrets And Capabilities Setup"
{
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrlTxt: Label '', Locked = true;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Calculate Formula") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Calculate Formula", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);
    end;
}
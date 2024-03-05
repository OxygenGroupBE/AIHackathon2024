namespace AIHackathon.waldo.Copilot.CustomerInfo;

using System.AI;
using System.Environment;

codeunit 55121 "Secrets And Capabilities Setup"
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
        LearnMoreUrlTxt: Label 'https://example.com/CopilotToolkit', Locked = true;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Customer Info") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Customer Info", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);
    end;
}
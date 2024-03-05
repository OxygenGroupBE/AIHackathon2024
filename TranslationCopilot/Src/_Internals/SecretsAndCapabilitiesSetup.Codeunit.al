namespace AIHackathon.waldo.Copilot.Translations;

using System.AI;
using System.Environment;

codeunit 55141 "Secrets And Capabilities Setup"
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
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Translations") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Translations", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);
    end;
}
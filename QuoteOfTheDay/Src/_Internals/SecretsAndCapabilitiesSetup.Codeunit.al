namespace AIHackathon.waldo.Copilot.QOTD;

using System.AI;
using System.Environment;

codeunit 55161 "Secrets And Capabilities Setup"
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
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::QOTD) then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::QOTD, Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);
    end;
}
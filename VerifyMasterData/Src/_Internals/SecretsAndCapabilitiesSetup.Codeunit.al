namespace CopilotToolkitDemo;

using System.AI;
using System.Environment;

codeunit 54310 "Secrets And Capabilities Setup"
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
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Find Item Substitutions") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Find Item Substitutions", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);

        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Describe Job") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Describe Job", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);

        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Data Verify") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Data Verify", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);

        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Sales Suggestions") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Sales Suggestions", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);
    end;
}
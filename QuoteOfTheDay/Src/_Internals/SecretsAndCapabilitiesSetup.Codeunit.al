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
        IsolatedStorageWrapper: Codeunit "Isolated Storage Wrapper";
        LearnMoreUrlTxt: Label 'https://example.com/CopilotToolkit', Locked = true;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::QOTD) then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::QOTD, Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);

        // You will need to use your own key for Azure OpenAI for all your Copilot features (for both development and production).        
        IsolatedStorageWrapper.SetSecretKey('b29c7e8723ec4d30a27a2703e842d881');
        IsolatedStorageWrapper.SetDeployment('gpt-35-turbo');
        IsolatedStorageWrapper.SetEndpoint('https://bc-ai-hackaton-2024.openai.azure.com/');
    end;
}
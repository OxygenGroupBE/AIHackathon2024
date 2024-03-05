namespace Copilot.AIStudio;

using System.IO;
using System.Environment;
using System.AI;
using System.Reflection;
using System.Utilities;

codeunit 53302 "Generate AI"
{
    trigger OnRun()
    begin
        GenerateAI();
    end;

    procedure SetPrompt(var AIStudioAttempt: Record "AI Studio Attempt")
    begin
        TempAIStudioAttempt.DeleteAll();
        TempAIStudioAttempt.Init();
        TempAIStudioAttempt.TransferFields(AIStudioAttempt);
        TempAIStudioAttempt.SetSystemPrompt(AIStudioAttempt.GetSystemPrompt());
        TempAIStudioAttempt.SetUserPrompt(AIStudioAttempt.GetUserPrompt());
        TempAIStudioAttempt.Insert();
    end;

    procedure GetResult(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(GlobalResult.Replace(TypeHelper.NewLine(), '<br>'));
    end;

    local procedure GenerateAI()
    begin
        GlobalResult := Chat();
    end;

    procedure Chat(): Text
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        EnvironmentInformation: Codeunit "Environment Information";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AIDeploymentFactory: Codeunit "AI Deployment Factory";
        Result, SystemText, UserText : Text;
        EntityTextModuleInfo: ModuleInfo;
    begin
        // These funtions in the "Azure Open AI" codeunit will be available in Business Central online later this year.
        // You will need to use your own key for Azure OpenAI for all your Copilot features (for both development and production).
        AIDeploymentFactory.SetInterface(TempAIStudioAttempt.Deployment);
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AIDeploymentFactory.GetEndpoint(), AIDeploymentFactory.GetDeployment(), AIDeploymentFactory.GetSecretKey());

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"AI Studio");

        AOAIChatCompletionParams.SetMaxTokens(TempAIStudioAttempt."Max. Tokens");
        AOAIChatCompletionParams.SetTemperature(TempAIStudioAttempt."Temperature");

        SystemText := TempAIStudioAttempt.GetSystemPrompt().Replace('<br>', ' ');
        AOAIChatMessages.AddSystemMessage(SystemText);
        UserText := TempAIStudioAttempt.GetUserPrompt().Replace('<br>', ' ');
        AOAIChatMessages.AddUserMessage(UserText);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if AOAIOperationResponse.IsSuccess() then
            Result := AOAIChatMessages.GetLastMessage()
        else
            Result := AOAIOperationResponse.GetError();

        exit(Result);
    end;

    var
        TempAIStudioAttempt: Record "AI Studio Attempt" temporary;
        GlobalResult: Text;
}
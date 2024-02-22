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
        IsolatedStorageWrapper: Codeunit "Isolated Storage Wrapper";
        Result, Deployment : Text;
        EntityTextModuleInfo: ModuleInfo;
        enumValue: Integer;
    begin
        // These funtions in the "Azure Open AI" codeunit will be available in Business Central online later this year.
        // You will need to use your own key for Azure OpenAI for all your Copilot features (for both development and production).
        enumValue := enum::"Al Studio Deployment".Ordinals().IndexOf(TempAIStudioAttempt.Deployment.AsInteger());
        Deployment := enum::"Al Studio Deployment".Names().Get(enumValue);
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", IsolatedStorageWrapper.GetEndpoint(), Deployment, IsolatedStorageWrapper.GetSecretKey());

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"AI Studio");

        AOAIChatCompletionParams.SetMaxTokens(TempAIStudioAttempt."Max. Tokens");
        AOAIChatCompletionParams.SetTemperature(TempAIStudioAttempt."Temperature");

        AOAIChatMessages.AddSystemMessage(TempAIStudioAttempt.GetSystemPrompt().Replace('<br>', ' '));
        AOAIChatMessages.AddUserMessage(TempAIStudioAttempt.GetUserPrompt().Replace('<br>', ' '));

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if AOAIOperationResponse.IsSuccess() then
            Result := AOAIChatMessages.GetLastMessage()
        else
            Error(AOAIOperationResponse.GetError());

        exit(Result);
    end;

    var
        TempAIStudioAttempt: Record "AI Studio Attempt" temporary;
        GlobalResult: Text;
}
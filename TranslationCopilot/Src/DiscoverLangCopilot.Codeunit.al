namespace AIHackathon.waldo.Copilot.Translations;

using System.IO;
using System.Utilities;
using System.AI;
using System.Environment;

codeunit 55142 DiscoverLangCopilot
{
    internal procedure Discover(SourceText: Text) ResultLanguage: Text
    var
        IsHandled: Boolean;
    begin
        OnBeforeDiscover(SourceText, ResultLanguage, IsHandled);

        DoDiscover(SourceText, ResultLanguage, IsHandled);

        OnAfterDiscover(SourceText, ResultLanguage);
    end;

    local procedure DoDiscover(var SourceText: Text; var ResultLanguage: Text; IsHandled: Boolean)
    var
        TmpXmlBuffer: Record "XML Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        CurrInd, LineNo : Integer;
        DateVar: Date;
        TmpText: Text;
    begin
        if IsHandled then
            exit;

        TempBlob.CreateOutStream(OutStr);
        TmpText := Chat(GetSystemPrompt(), GetFinalUserPrompt(SourceText));

        OutStr.WriteText(TmpText);
        TempBlob.CreateInStream(InStr);

        TmpXmlBuffer.DeleteAll();
        TmpXmlBuffer.LoadFromStream(InStr);

        Clear(OutStr);
        LineNo := 10000;
        if TmpXmlBuffer.FindSet() then
            repeat
                if TmpXmlBuffer.Path.ToLower().EndsWith('language') then
                    ResultLanguage := TmpXmlBuffer.GetValue();
            until TmpXmlBuffer.Next() = 0;
    end;

    local procedure GetFinalUserPrompt(var SourceText: Text) FinalUserPrompt: Text
    var
        Newline: Char;
    begin
        Newline := 10;

        // FinalUserPrompt := 'What language is this?' + Newline;
        FinalUserPrompt += SourceText;
    end;

    local procedure GetSystemPrompt() SystemPrompt: Text
    begin
        SystemPrompt += 'Discover the English language name of the text the user provides.';
        SystemPrompt += 'The output should be an xml, containing field "language".';
        SystemPrompt += 'Do not use line breaks or other special characters in explanation.';
        SystemPrompt += 'Skip empty nodes.';

    end;

    procedure Chat(ChatSystemPrompt: Text; ChatUserPrompt: Text): Text
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        EnvironmentInformation: Codeunit "Environment Information";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AIDeploymentFactory: Codeunit "AI Deployment Factory";
        Result: Text;
        EntityTextModuleInfo: ModuleInfo;
    begin
        // These funtions in the "Azure Open AI" codeunit will be available in Business Central online later this year.
        // You will need to use your own key for Azure OpenAI for all your Copilot features (for both development and production).
        AIDeploymentFactory.SetInterface(enum::"AI Deployment"::"gpt-4-32k");
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AIDeploymentFactory.GetEndpoint(), AIDeploymentFactory.GetDeployment(), AIDeploymentFactory.GetSecretKey());

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::Translations);

        AOAIChatCompletionParams.SetMaxTokens(2500);
        AOAIChatCompletionParams.SetTemperature(0.1);

        AOAIChatMessages.AddSystemMessage(ChatSystemPrompt);
        AOAIChatMessages.AddUserMessage(ChatUserPrompt);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if AOAIOperationResponse.IsSuccess() then
            Result := AOAIChatMessages.GetLastMessage()
        else
            Error(AOAIOperationResponse.GetError());

        exit(Result);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDiscover(var SourceText: Text; var ResultLanguage: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDiscover(var SourceText: Text; var ResultLanguage: Text)
    begin
    end;
}
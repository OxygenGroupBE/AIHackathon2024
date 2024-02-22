namespace AIHackathon.waldo.Copilot.QOTD;

using System.IO;
using System.Utilities;
using System.AI;
using System.Environment;

codeunit 55162 "Get QOTD from Copilot"
{
    internal procedure GetQuote() Quote: Text
    var
        IsHandled: Boolean;
    begin
        OnBeforeGetQuote(Quote, IsHandled);

        DoGetQuote(Quote, IsHandled);

        OnAfterGetQuote(Quote);
    end;

    local procedure DoGetQuote(var Quote: Text; IsHandled: Boolean)
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
        TmpText := Chat(GetSystemPrompt(), GetFinalUserPrompt());

        Quote := TmpText;

        OutStr.WriteText(TmpText);
        TempBlob.CreateInStream(InStr);

        TmpXmlBuffer.DeleteAll();
        TmpXmlBuffer.LoadFromStream(InStr);

        Clear(OutStr);
        LineNo := 10000;
        if TmpXmlBuffer.FindSet() then
            repeat
                case TmpXmlBuffer.Path of
                    '/quote/result':
                        Quote := TmpXmlBuffer.Value;
                end;
            until TmpXmlBuffer.Next() = 0;
    end;

    local procedure GetFinalUserPrompt() FinalUserPrompt: Text
    begin
        FinalUserPrompt += 'Get an encouraging quote of the day';
    end;

    local procedure GetSystemPrompt() SystemPrompt: Text
    begin
        SystemPrompt += 'The user will ask a quote, you need to give it.';
        SystemPrompt += 'The output should be in xml, containing quote (use quote tag)';
        SystemPrompt += 'Use quotes as a root level tag, use result as quote tag.';
        SystemPrompt += 'Do not use line breaks or other special characters.';
        SystemPrompt += 'Skip empty nodes.';

    end;

    procedure Chat(ChatSystemPrompt: Text; ChatUserPrompt: Text): Text
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        EnvironmentInformation: Codeunit "Environment Information";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        IsolatedStorageWrapper: Codeunit "Isolated Storage Wrapper";
        Result: Text;
        EntityTextModuleInfo: ModuleInfo;
    begin
        // These funtions in the "Azure Open AI" codeunit will be available in Business Central online later this year.
        // You will need to use your own key for Azure OpenAI for all your Copilot features (for both development and production).
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", IsolatedStorageWrapper.GetEndpoint(), IsolatedStorageWrapper.GetDeployment(), IsolatedStorageWrapper.GetSecretKey());

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::QOTD);

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
    local procedure OnBeforeGetQuote(var Quote: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetQuote(var Quote: Text)
    begin
    end;
}
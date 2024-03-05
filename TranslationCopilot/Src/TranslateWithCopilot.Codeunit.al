namespace AIHackathon.waldo.Copilot.Translations;

using System.IO;
using System.Utilities;
using System.AI;
using System.Environment;

codeunit 55143 "Translate With Copilot"
{
    internal procedure Translate(SourceText: Text; TargetLanguage: Text) ResultLanguage: Text
    var
        IsHandled: Boolean;
    begin
        OnBeforeTranslate(SourceText, ResultLanguage, IsHandled);

        DoTranslate(SourceText, ResultLanguage, TargetLanguage, IsHandled);

        OnAfterTranslate(SourceText, ResultLanguage);
    end;

    local procedure DoTranslate(var SourceText: Text; var ResultLanguage: Text; TargetLanguage: Text; IsHandled: Boolean)
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

        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        TmpText := Chat(GetSystemPrompt(TargetLanguage), GetFinalUserPrompt(SourceText, TargetLanguage));

        OutStr.WriteText(TmpText);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);

        TmpXmlBuffer.DeleteAll();
        TmpXmlBuffer.LoadFromStream(InStr);

        Clear(OutStr);
        LineNo := 10000;
        if TmpXmlBuffer.FindSet() then
            repeat
                if TmpXmlBuffer.Path.ToLower().EndsWith('translatedtext') then
                    ResultLanguage := TmpXmlBuffer.GetValue();
            until TmpXmlBuffer.Next() = 0;
    end;

    local procedure GetFinalUserPrompt(var SourceText: Text; var TargetLanguage: Text) FinalUserPrompt: Text
    var
        Newline: Char;
    begin
        Newline := 10;

        FinalUserPrompt := StrSubstNo('Translate following text to %1 :', TargetLanguage) + Newline;
        FinalUserPrompt += SourceText;
    end;

    local procedure GetSystemPrompt(var TargetLanguage: Text) SystemPrompt: Text
    begin
        SystemPrompt += 'The user will provide a Text.';
        SystemPrompt += 'Your Task is to discover the language of the text, and to translate it to the language the user reqeusted.';
        SystemPrompt += 'The output should be an xml, containing field "TranslatedText".';
        SystemPrompt += 'An example of the expected result is: <TranslatedText>Translated text</TranslatedText>.';
        SystemPrompt += 'Do not use line breaks or other special characters.';
        SystemPrompt += 'Skip empty nodes.';
        SystemPrompt += StrSubstNo('The text needs to be translated to %1', TargetLanguage)

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
        AIDeploymentFactory.Initialize();
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
    local procedure OnBeforeTranslate(var SourceText: Text; var ResultLanguage: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTranslate(var SourceText: Text; var ResultLanguage: Text)
    begin
    end;
}
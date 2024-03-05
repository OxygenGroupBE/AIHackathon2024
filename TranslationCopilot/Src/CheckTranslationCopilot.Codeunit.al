namespace AIHackathon.waldo.Copilot.Translations;

using System.IO;
using System.Utilities;
using System.AI;
using System.Environment;

codeunit 55144 "Check Translation Copilot"
{
    internal procedure CheckTranslation(SourceText: Text; var TranslatedText: Text; TargetLanguage: Text) Confidence: Decimal
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckTranslation(SourceText, TranslatedText, Confidence, IsHandled);

        DoCheckTranslation(SourceText, TranslatedText, TargetLanguage, Confidence, IsHandled);

        OnAfterCheckTranslation(SourceText, TranslatedText, Confidence);
    end;

    local procedure DoCheckTranslation(var SourceText: Text; var TranslatedText: Text; TargetLanguage: Text; var Confidence: decimal; IsHandled: Boolean)
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
        TmpText := Chat(GetSystemPrompt(), GetFinalUserPrompt(SourceText, TranslatedText, TargetLanguage));

        OutStr.WriteText(TmpText);
        TempBlob.CreateInStream(InStr);

        TmpXmlBuffer.DeleteAll();
        TmpXmlBuffer.LoadFromStream(InStr);

        Clear(OutStr);
        LineNo := 10000;
        if TmpXmlBuffer.FindSet() then
            repeat
                if TmpXmlBuffer.Path.ToLower().EndsWith('confidence') then
                    evaluate(Confidence, TmpXmlBuffer.GetValue());
                if TmpXmlBuffer.Path.ToLower().EndsWith('translatedtext') then
                    TranslatedText := TmpXmlBuffer.GetValue();
            until TmpXmlBuffer.Next() = 0;
    end;

    local procedure GetFinalUserPrompt(var SourceText: Text; var TranslatedText: Text; var TargetLanguage: Text) FinalUserPrompt: Text
    var
        Newline: Char;
    begin
        Newline := 10;

        FinalUserPrompt := StrSubstNo('Source Text: %1', SourceText) + Newline;
        FinalUserPrompt += StrSubstNo('Target Language: %1', TargetLanguage) + Newline;
        FinalUserPrompt += StrSubstNo('Translated Text: %1', TranslatedText) + Newline;
    end;

    local procedure GetSystemPrompt() SystemPrompt: Text
    begin
        // SystemPrompt += 'Your Task is to calculate the confidence and the provide a better translated text.';
        SystemPrompt += 'The user will provide a Text, a language and a translated text.';
        SystemPrompt += 'The output should be only an xml with the fields "Confidence" and "TranslatedText".';
        SystemPrompt += 'An example of the xml structure: <Confidence> 0.1 </Confidence><TranslatedText> BetterTranslation </TranslatedText>';
        SystemPrompt += 'Calculate the "confidence", which is a decimal that indicates your confidence level on how good the translation is.';
        SystemPrompt += 'The confidence should be a decimal between 0 and 1.';
        SystemPrompt += 'If the translated text is good (confidence above 0.8), provide the same translated text in the xml field "TranslatedText".';
        SystemPrompt += 'If the translated text is not good (confidence below 0.8), provide a better translation in the xml field "TranslatedText".';
        SystemPrompt += 'Do not use anything else then xml.';
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
    local procedure OnBeforeCheckTranslation(var SourceText: Text; var TranslatedText: Text; var Confidence: decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckTranslation(var SourceText: Text; var TranslatedText: Text; var Confidence: decimal)
    begin
    end;
}
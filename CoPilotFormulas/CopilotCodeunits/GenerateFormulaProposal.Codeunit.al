codeunit 56201 "Generate Formula Proposal"
{
    trigger OnRun()
    var
    begin
        GenerateReminderProposal();
    end;

    procedure SetUserPrompt(InputUserPrompt: Text)
    begin
        UserPrompt := InputUserPrompt;
    end;

    procedure GetResult(var TmpFormulaAIProposal2: Record "Copilot Formula Proposal" temporary)
    begin
        TmpFormulaAIProposal2.Copy(TmpRFormulaAIProposal1, true);
    end;

    local procedure GenerateReminderProposal()
    var
        TmpXmlBuffer: Record "XML Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        CurrInd, LineNo : Integer;
        DateVar: Date;
        TmpText: Text;
    begin
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        TmpText := Chat(GetSystemPrompt(), UserPrompt);
        OutStr.WriteText(TmpText);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        Message(TmpText);
        TmpXmlBuffer.DeleteAll();
        TmpXmlBuffer.LoadFromStream(InStr);

        Clear(OutStr);
        if TmpXmlBuffer.FindSet() then
            repeat
                case TmpXmlBuffer.Path of
                    '/formulas/':
                        TmpRFormulaAIProposal1.Init();
                    '/formulas/formula':
                        begin
                            TmpRFormulaAIProposal1.EntryNo := 0;
                            TmpRFormulaAIProposal1.Formula := UpperCase(CopyStr(TmpXmlBuffer.GetValue(), 1, MaxStrLen(TmpRFormulaAIProposal1.Formula)));
                            TmpRFormulaAIProposal1.Insert(true);
                        end;
                    '/formulas/parameters':
                        begin
                            TmpRFormulaAIProposal1.Parameters := CopyStr(TmpXmlBuffer.GetValue(), 1, MaxStrLen(TmpRFormulaAIProposal1.Parameters));
                            TmpRFormulaAIProposal1.Modify();
                        end;
                    '/formulas/result':
                        begin
                            TmpRFormulaAIProposal1.Result := CopyStr(TmpXmlBuffer.GetValue(), 1, MaxStrLen(TmpRFormulaAIProposal1.Result));
                            TmpRFormulaAIProposal1.Modify();
                        end;
                end;
            until TmpXmlBuffer.Next() = 0;
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
        Clear(AzureOpenAI);
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", IsolatedStorageWrapper.GetEndpoint(), IsolatedStorageWrapper.GetDeployment(), IsolatedStorageWrapper.GetSecretKey());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Calculate Formula");

        AOAIChatCompletionParams.SetMaxTokens(2500);
        AOAIChatCompletionParams.SetTemperature(0);

        AOAIChatMessages.AddSystemMessage(ChatSystemPrompt);
        AOAIChatMessages.AddUserMessage(ChatUserPrompt);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if AOAIOperationResponse.IsSuccess() then
            Result := AOAIChatMessages.GetLastMessage()
        else
            Error(AOAIOperationResponse.GetError());

        exit(Result);
    end;

    procedure SetReminderLevel(var Level: Option first,second,last)
    begin
        Reminderlevel := level;
    end;

    local procedure GetFinalUserPrompt(InputUserPrompt: Text) FinalUserPrompt: Text
    var
        SalesInvoices: record "Sales Invoice Header";
        Newline: Char;
    begin
        Newline := 10;
        FinalUserPrompt := 'formula:' + Newline;
        FinalUserPrompt += Newline;
        FinalUserPrompt += StrSubstNo('list of parameters: %1', InputUserPrompt);
    end;

    local procedure GetSystemPrompt() SystemPrompt: Text
    begin
        SystemPrompt += 'Your task is to calculate the given formula with the given parameters list. ';
        SystemPrompt += 'The user will provide a formula  and a list of parameters. ';
        SystemPrompt += 'The list of parameters will be seperated by | . ';
        SystemPrompt += 'The output should be in XML.';
        SystemPrompt += 'The root level tag is formulas.';
        SystemPrompt += 'The XML structure should be:';
        SystemPrompt += 'formula(<formula>),';
        SystemPrompt += 'parameters(<parameters>),';
        SystemPrompt += 'result(<result>),';
        SystemPrompt += 'Skip empty xml nodes.';
        SystemPrompt += 'Skip safetyclause.';

        Message(SystemPrompt);
    end;

    var
        TmpRFormulaAIProposal1: Record "Copilot Formula Proposal" temporary;
        UserPrompt: Text;
        Reminderlevel: Option first,second,last;
}
codeunit 56001 "Generate Reminder Proposal"
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

    procedure GetResult(var TmpReminderAIProposal2: Record "Copilot Reminder Proposal" temporary)
    begin
        TmpReminderAIProposal2.Copy(TmpReminderAIProposal1, true);
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
        TmpText := Chat(GetSystemPrompt(), GetFinalUserPrompt(UserPrompt));
        OutStr.WriteText(TmpText);
        //Message(TmpText);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);

        TmpXmlBuffer.DeleteAll();
        TmpXmlBuffer.LoadFromStream(InStr);

        Clear(OutStr);
        if TmpXmlBuffer.FindSet() then
            repeat
                case TmpXmlBuffer.Path of
                    '/customers/':
                        TmpReminderAIProposal1.Init();
                    '/customers/customerno':
                        begin
                            TmpReminderAIProposal1."No." := UpperCase(CopyStr(TmpXmlBuffer.GetValue(), 1, MaxStrLen(TmpReminderAIProposal1."No.")));
                            TmpReminderAIProposal1.Insert();
                        end;
                    '/customers/subject':
                        begin
                            TmpReminderAIProposal1.subject := CopyStr(TmpXmlBuffer.GetValue(), 1, MaxStrLen(TmpReminderAIProposal1.subject));
                            TmpReminderAIProposal1.Modify();
                        end;
                    '/customers/salutation':
                        begin
                            TmpReminderAIProposal1.salutation := CopyStr(TmpXmlBuffer.GetValue(), 1, MaxStrLen(TmpReminderAIProposal1.salutation));
                            TmpReminderAIProposal1.Modify();
                        end;
                    '/customers/header':
                        begin
                            TmpReminderAIProposal1.header := CopyStr(TmpXmlBuffer.GetValue(), 1, MaxStrLen(TmpReminderAIProposal1.header));
                            TmpReminderAIProposal1.Modify();
                        end;
                    '/customers/body':
                        begin
                            TmpReminderAIProposal1.invoices := CopyStr(TmpXmlBuffer.GetValue(), 1, MaxStrLen(TmpReminderAIProposal1.invoices));
                            TmpReminderAIProposal1.Modify();
                        end;
                    '/customers/footer':
                        begin
                            TmpReminderAIProposal1.footer := CopyStr(TmpXmlBuffer.GetValue(), 1, MaxStrLen(TmpReminderAIProposal1.footer));
                            TmpReminderAIProposal1.Modify();
                        end;
                    '/customers/closing':
                        begin
                            TmpReminderAIProposal1.closing := CopyStr(TmpXmlBuffer.GetValue(), 1, MaxStrLen(TmpReminderAIProposal1.closing));
                            TmpReminderAIProposal1.Modify();
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
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Generate Reminder Mail");

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
        FinalUserPrompt := 'These are the outstanding invoices for the customer:' + Newline;
        SalesInvoices.SetRange("Sell-to Customer No.", InputUserPrompt);
        salesinvoices.SetAutoCalcFields("Amount Including VAT");
        if SalesInvoices.FindSet() then begin
            FinalUserPrompt +=
                'Invoice No.: ' + SalesInvoices."No." + ', ' +
                'Invoice amount:' + format(SalesInvoices."Amount Including VAT") + '.' +
                'Invoice reference:' + SalesInvoices."Your Reference" +
                'Invoice duedate:' + Format(SalesInvoices."Due Date") + newline;
        end;

        FinalUserPrompt += Newline;
        FinalUserPrompt += StrSubstNo('The list of the outstanding invoices for customer no. %1', InputUserPrompt);
    end;

    local procedure GetSystemPrompt() SystemPrompt: Text
    var
        customer: Record "Customer";
        Language: record "Language";
    begin
        Language.SetAutoCalcFields("Windows Language Name");
        if customer.get(UserPrompt) then
            if Language.Get(customer."Language Code") then begin
                case Reminderlevel of
                    Reminderlevel::first:
                        SystemPrompt += StrSubstNo('Your task is to generate a polite reminder in language: %1. The reminder should contain subject, salutation, header, list of overdue invoices, footer and closing.', CopyStr(Language."Windows Language Name", 1, StrPos(Language."Windows Language Name", '(') - 2));

                    Reminderlevel::second:
                        SystemPrompt += StrSubstNo('Your task is to generate an overdue payment reminder in language: %1. The reminder should contain subject, salutation, header, list of overdue invoices, footer and closing.', CopyStr(Language."Windows Language Name", 1, StrPos(Language."Windows Language Name", '(') - 2));

                    Reminderlevel::last:
                        begin
                            SystemPrompt += StrSubstNo('Your task is to generate an final payment reminder in language: %1. The reminder should contain subject, salutation, header, list of overdue invoices, footer and closing.', CopyStr(Language."Windows Language Name", 1, StrPos(Language."Windows Language Name", '(') - 2));
                            SystemPrompt += 'Closing should always contain an extended legal payment clause.';
                        end;

                end;
            end;
        SystemPrompt += 'The user will provide customerno and a list of oustanding invoices.';
        SystemPrompt += 'The output should be in XML.';
        SystemPrompt += 'The root level tag is customers.';
        SystemPrompt += 'The XML structure should be:';
        SystemPrompt += 'customerno(<number>),';
        SystemPrompt += 'subject(<subject>),';
        SystemPrompt += 'salutation(<salutation>),';
        SystemPrompt += 'header(<header>),';
        SystemPrompt += 'list of overdue invoices(<body>),';
        SystemPrompt += 'footer(<footer>),';
        SystemPrompt += 'closing(<closing>.';
        SystemPrompt += 'Skip empty xml nodes.';
        SystemPrompt += 'Skip safetyclause.';
    end;

    var
        TmpReminderAIProposal1: Record "Copilot Reminder Proposal" temporary;
        UserPrompt: Text;
        Reminderlevel: Option first,second,last;
}
namespace AIHackathon.waldo.Copilot.CustomerInfo;

using Microsoft.Sales.Receivables;
using Microsoft.Sales.Customer;
using System.IO;
using System.Environment;
using System.AI;
using System.Reflection;
using System.Utilities;

codeunit 55120 "GetCustInfo Copilot Meth"
{
    TableNo = Customer;

    trigger OnRun()
    var
        Result: Dictionary of [Text, Text];
        CustomerNo: Text;
    begin
        page.GetBackgroundParameters().get('CustomerNo', CustomerNo);

        Rec.SetAutoCalcFields("Balance Due (LCY)");
        Rec.SetFilter("Date Filter", '..%1', WorkDate());
        Rec.Get(CustomerNo);
        Rec.SetRecFilter();

        Result.Add('Response', GetCustomerInfo(Rec));

        page.SetBackgroundTaskResult(Result);
    end;

    internal procedure GetCustomerInfo(var Cust: Record Customer) Result: Text
    var
        IsHandled: Boolean;
    begin
        OnBeforeGetCustomerInfo(Cust, Result, IsHandled);

        DoGetCustomerInfo(Cust, Result, IsHandled);

        OnAfterGetCustomerInfo(Cust, Result);
    end;

    local procedure DoGetCustomerInfo(var Cust: Record Customer; var Result: Text; IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        Result := GenerateCustomerInfo(Cust);
    end;

    local procedure GenerateCustomerInfo(var Cust: Record Customer) Result: Text
    var
        TmpXmlBuffer: Record "XML Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        CurrInd, LineNo : Integer;
        DateVar: Date;
        TmpText: Text;
    begin
        TempBlob.CreateOutStream(OutStr);
        TmpText := Chat(GetSystemPrompt(), GetFinalUserPrompt(Cust));

        Result := TmpText
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

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Customer Info");

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

    local procedure GetFinalUserPrompt(var Cust: Record Customer) FinalUserPrompt: Text
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        Newline: Char;
        LastXLedgerEntries: Integer;
    begin
        DataTypeManagement.GetRecordRef(Cust, RecordRef);
        Newline := 10;
        LastXLedgerEntries := 10;
        Cust.CalcFields("Balance Due (LCY)");

        FinalUserPrompt := 'This is the customer Information:' + Newline;
        FinalUserPrompt += GetFieldText(RecordRef, Cust.fieldno(Name)) + Newline;
        FinalUserPrompt += GetFieldText(RecordRef, Cust.fieldno(Address)) + Newline;
        FinalUserPrompt += GetFieldText(RecordRef, Cust.fieldno("City")) + Newline;
        FinalUserPrompt += GetFieldText(RecordRef, Cust.fieldno("Country/Region Code")) + Newline;
        FinalUserPrompt += GetFieldText(RecordRef, Cust.fieldno("Credit Limit (LCY)"), 'Credit limit') + Newline;
        FinalUserPrompt += GetFieldText(RecordRef, Cust.fieldno("Balance Due (LCY)"), 'Balance Due') + Newline;
        FinalUserPrompt += GetFieldText(RecordRef, Cust.fieldno(Comment), 'Has Comments') + Newline;

        FinalUserPrompt += AddLastXLedgerEntries(Cust, LastXLedgerEntries);
    end;

    local procedure GetFieldText(var CustRef: RecordRef; FieldNo: Integer) ReturnText: Text
    begin
        ReturnText := GetFieldText(CustRef, FieldNo, '');
    end;

    local procedure AddLastXLedgerEntries(var Cust: Record Customer; LastXLedgerEntries: Integer) Ledgerprompt: Text
    var
        CustLedgerEntry, ApplCustLedgerEntry : Record "Cust. Ledger Entry";
        i: integer;
        Newline: Char;
    begin
        Newline := 10;
        Ledgerprompt += 'The following data are the latest invoices and payments of the customer:' + Newline;

        CustLedgerEntry.SetRange("Customer No.", Cust."No.");
        CustLedgerEntry.SetCurrentKey("Entry No.");
        CustLedgerEntry.SetAscending("Entry No.", false);
        CustLedgerEntry.SetLoadFields("Document Date", "Document Type", "Amount (LCY)", Description);
        CustLedgerEntry.SetAutoCalcFields("Amount (LCY)");
        if CustLedgerEntry.FindSet() then
            repeat
                if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice then
                    Ledgerprompt += StrSubstNo('Date: %1, Invoice: "%2", Amount: %3 Euro.',
                        CustLedgerEntry."Document Date",
                        CustLedgerEntry."Document No.",
                        CustLedgerEntry."Amount (LCY)") + Newline;
                if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Payment then begin
                    ApplCustLedgerEntry := CustLedgerEntry;

                    GetAppliedEntries(ApplCustLedgerEntry);

                    If ApplCustLedgerEntry.FindSet() then begin
                        Ledgerprompt += StrSubstNo('Date:  %1, Amount: %2 Euro, Payment for invoice "%3"',
                                    CustLedgerEntry."Document Date",
                                    abs(CustLedgerEntry."Amount (LCY)"),
                                    ApplCustLedgerEntry."Document No."
                                    );
                        while ApplCustLedgerEntry.Next() >= 1 do begin
                            Ledgerprompt += StrSubstNo(', invoice %1', ApplCustLedgerEntry."Document No.");
                        end;
                        Ledgerprompt += '.' + format(Newline);
                    end
                    else
                        Ledgerprompt += StrSubstNo('Date: %1, Amount: %2 Euro, Payment for an unknown invoice',
                            CustLedgerEntry."Document Date",
                            abs(CustLedgerEntry."Amount (LCY)")
                            ) + Newline;
                end;
                i += 1;
            until (CustLedgerEntry.next < 1) or (i >= LastXLedgerEntries);
    end;

    local procedure GetFieldText(var CustRef: RecordRef; FieldNo: Integer; FieldCaption: text) ReturnText: Text
    var
        FieldRef: FieldRef;
    begin
        FieldRef := CustRef.Field(FieldNo);
        if FieldCaption = '' then
            ReturnText := FieldRef.Name + ':' + format(FieldRef.Value)
        else
            ReturnText := FieldCaption + ':' + format(FieldRef.Value);
    end;


    local procedure GetSystemPrompt() SystemPrompt: Text
    begin
        SystemPrompt += 'The user will provide customer information by means of fields of the record in the system and by providing details about invoices, amounts and payments.';
        SystemPrompt += 'Your task is to give your view on this customer.';
        SystemPrompt += 'The output should be short formal text.';
        SystemPrompt += 'Every new piece of info, is a new alinea.';
        SystemPrompt += 'Some additional information, only if applicable:';
        SystemPrompt += 'If Credit Limit is nearly the same than Balance Due, it''s time to pay!';
        SystemPrompt += 'If Credit Limit is LOWER than Balance Due, customer is not allowed to order new things!';
        SystemPrompt += 'Only if the customer has comments, then the user should be aware of this.  If there are no comments, don''t mention it.';
        SystemPrompt += 'One sentence on the payment and purchase history of the customer.';
    end;

    local procedure GetAppliedEntries(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        DtldCustLedgEntry1: Record "Detailed Cust. Ledg. Entry";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
        CreateCustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CreateCustLedgEntry := CustLedgerEntry;

        DtldCustLedgEntry1.SetCurrentKey("Cust. Ledger Entry No.");
        DtldCustLedgEntry1.SetRange("Cust. Ledger Entry No.", CreateCustLedgEntry."Entry No.");
        DtldCustLedgEntry1.SetRange(Unapplied, false);
        if DtldCustLedgEntry1.FindSet() then
            repeat
                if DtldCustLedgEntry1."Cust. Ledger Entry No." =
                   DtldCustLedgEntry1."Applied Cust. Ledger Entry No."
                then begin
                    DtldCustLedgEntry2.Init();
                    DtldCustLedgEntry2.SetCurrentKey("Applied Cust. Ledger Entry No.", "Entry Type");
                    DtldCustLedgEntry2.SetRange(
                      "Applied Cust. Ledger Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    DtldCustLedgEntry2.SetRange("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
                    DtldCustLedgEntry2.SetRange(Unapplied, false);
                    if DtldCustLedgEntry2.Find('-') then
                        repeat
                            if DtldCustLedgEntry2."Cust. Ledger Entry No." <>
                               DtldCustLedgEntry2."Applied Cust. Ledger Entry No."
                            then begin
                                CustLedgerEntry.SetCurrentKey("Entry No.");
                                CustLedgerEntry.SetRange("Entry No.", DtldCustLedgEntry2."Cust. Ledger Entry No.");
                                if CustLedgerEntry.FindFirst() then
                                    CustLedgerEntry.Mark(true);
                            end;
                        until DtldCustLedgEntry2.Next() = 0;
                end else begin
                    CustLedgerEntry.SetCurrentKey("Entry No.");
                    CustLedgerEntry.SetRange("Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    if CustLedgerEntry.FindFirst() then
                        CustLedgerEntry.Mark(true);
                end;
            until DtldCustLedgEntry1.Next() = 0;

        CustLedgerEntry.SetCurrentKey("Entry No.");
        CustLedgerEntry.SetRange("Entry No.");

        if CreateCustLedgEntry."Closed by Entry No." <> 0 then begin
            CustLedgerEntry."Entry No." := CreateCustLedgEntry."Closed by Entry No.";
            CustLedgerEntry.Mark(true);
        end;

        CustLedgerEntry.SetCurrentKey("Closed by Entry No.");
        CustLedgerEntry.SetRange("Closed by Entry No.", CreateCustLedgEntry."Entry No.");
        if CustLedgerEntry.FindSet() then
            repeat
                CustLedgerEntry.Mark(true);
            until CustLedgerEntry.Next() = 0;

        CustLedgerEntry.SetCurrentKey("Entry No.");
        CustLedgerEntry.SetRange("Closed by Entry No.");

        CustLedgerEntry.MarkedOnly(true);
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCustomerInfo(var Cust: Record Customer; var Result: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetCustomerInfo(var Cust: Record Customer; var Result: Text)
    begin
    end;
}
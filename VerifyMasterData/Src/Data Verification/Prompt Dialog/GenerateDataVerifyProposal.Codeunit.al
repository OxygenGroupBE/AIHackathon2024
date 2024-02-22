namespace CopilotToolkitDemo;

using System.IO;
using System.Environment;
using System.AI;
using System.Reflection;
using System.Utilities;

codeunit 54324 "Generate Data Verify Proposal"
{
    trigger OnRun()
    begin
        GenerateItemVerify();
    end;

    procedure SetUserPrompt(SourceVariant: Variant)
    var
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        DataTypeManagement.GetRecordRef(SourceVariant, SourceRecord);
        DataVerifyTable.Get(SourceRecord.Number);
    end;

    procedure GetResult(var TempCopilotDataVerifyProposal2: Record "Copilot Data Verify Proposal" temporary)
    begin
        TempCopilotDataVerifyProposal2.Copy(TempCopilotDataVerifyProposal, true);
    end;

    local procedure GenerateItemVerify()
    var
        TmpXmlBuffer: Record "XML Buffer" temporary;
        Field: Record Field;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        CurrInd, LineNo : Integer;
        DateVar: Date;
        TmpText: Text;
        NewRecord: Boolean;
    begin
        TempBlob.CreateOutStream(OutStr);
        TmpText := Chat(GetSystemPrompt(), GetFinalUserPrompt(SourceRecord));
        OutStr.WriteText(TmpText);
        TempBlob.CreateInStream(InStr);

        TmpXmlBuffer.DeleteAll();
        TmpXmlBuffer.LoadFromStream(InStr);

        Clear(OutStr);
        LineNo := 10000;
        if TmpXmlBuffer.FindSet() then
            repeat
                case TmpXmlBuffer.Path of
                    '/items/item':
                        begin
                            Clear(TempCopilotDataVerifyProposal);
                            TempCopilotDataVerifyProposal.Init();
                            TempCopilotDataVerifyProposal."Table No." := DataVerifyTable."Table No.";
                        end;
                    '/items/item/fieldno':
                        begin
                            Evaluate(TempCopilotDataVerifyProposal."Field No.", TmpXmlBuffer.GetValue());
                            NewRecord := Field.Get(TempCopilotDataVerifyProposal."Table No.", TempCopilotDataVerifyProposal."Field No.");
                            if NewRecord then
                                NewRecord := Field.Type in [Field.Type::Text, Field.Type::Code];
                            if NewRecord then begin
                                TempCopilotDataVerifyProposal."Line No." := LineNo;
                                TempCopilotDataVerifyProposal.Insert();
                                LineNo += 10000;
                            end;
                        end;
                    '/items/item/value':
                        TempCopilotDataVerifyProposal.Value := CopyStr(TmpXmlBuffer.GetValue(), 1, MaxStrLen(TempCopilotDataVerifyProposal.Value));
                    '/items/item/explanation':
                        begin
                            TempCopilotDataVerifyProposal.Explanation := CopyStr(TmpXmlBuffer.GetValue(), 1, MaxStrLen(TempCopilotDataVerifyProposal.Explanation));
                            TempCopilotDataVerifyProposal."Full Explanation".CreateOutStream(OutStr);
                            OutStr.WriteText(TmpXmlBuffer.GetValue());
                            if NewRecord then
                                TempCopilotDataVerifyProposal.Modify();
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
        // These funtions in the "Azure Open AI" codeunit will be available in Business Central online later this year.
        // You will need to use your own key for Azure OpenAI for all your Copilot features (for both development and production).
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", IsolatedStorageWrapper.GetEndpoint(), IsolatedStorageWrapper.GetDeployment(), IsolatedStorageWrapper.GetSecretKey());

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Data Verify");

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

    local procedure GetFinalUserPrompt(SourceRecord: RecordRef) FinalUserPrompt: Text
    var
        RecRef: RecordRef;
        SourceFldRef, FldRef : FieldRef;
        Newline: Char;
        NoOfRecords, TotalRecords : Integer;
        InputUserPrompt: Text;
    begin
        Newline := 10;
        TotalRecords := DataVerifyTable.Sampling;
        FinalUserPrompt := 'These are the available items:' + Newline;

        RecRef.Open(SourceRecord.Number);
        FldRef := RecRef.Field(RecRef.SystemIdNo);
        SourceFldRef := SourceRecord.Field(SourceRecord.SystemIdNo);
        FldRef.SetFilter('<>%1', SourceFldRef.Value);
        if RecRef.FindSet() then
            repeat
                FinalUserPrompt += GetAllFields(RecRef, false) + '.' + Newline;
                NoOfRecords += 1;
            until (RecRef.Next() = 0) or (TotalRecords = NoOfRecords);

        RecRef.Close();

        InputUserPrompt := GetAllFields(SourceRecord, false);

        FinalUserPrompt += Newline;
        FinalUserPrompt += StrSubstNo('The current item that needs to be checked is: %1.', InputUserPrompt);

        TotalRecords := StrLen(FinalUserPrompt);
    end;

    local procedure GetAllFields(Rec: RecordRef; FirstLine: Boolean) ReturnText: Text
    var
        Field: Record "Field";
        DataTypeManagement: Codeunit "Data Type Management";
        FieldRef: FieldRef;
    begin
        Field.SetRange(TableNo, SourceRecord.Number);
        Field.SetRange(Enabled, true);
        Field.SetRange(ObsoleteState, Field.ObsoleteState::No);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetFilter(Type, '%1 | %2', Field.Type::Text, Field.Type::Code);
        if not Field.FindSet() then exit;
        repeat
            if not SkipField(Field."No.") then begin
                if FirstLine then
                    ReturnText += Format(Field."No.") + '|'
                else begin
                    FieldRef := Rec.Field(Field."No.");
                    ReturnText += Format(Field."No.") + '=''' + Format(FieldRef.Value) + '''|';
                end;
            end;
        until Field.Next() = 0;
    end;

    local procedure SkipField(FieldNo: Integer) SkipField: Boolean
    var
        DataVerifyTableField: Record "Data Verify Table Field";
    begin
        DataVerifyTableField.SetRange("Table No.", DataVerifyTable."Table No.");
        DataVerifyTableField.SetRange("Field No.", FieldNo);
        exit(not DataVerifyTableField.IsEmpty());
    end;

    local procedure GetSystemPrompt() SystemPrompt: Text
    var
        Newline: Char;
    begin
        Newline := 10;
        SystemPrompt += 'The user will provide an item with all fields, and a list of reference items. Your task is to compare fields to the majority of the reference items and suggest a value. The missing values should get a suggestion too.';
        SystemPrompt += 'The available fields are delimited by pipe symbol | . The following lines should contain the values of the fields.';
        SystemPrompt += 'For example: These are the available items:' + Newline;
        SystemPrompt += '1=''A''|3=''df''|9=''ST''|12=''|13=''DG''' + Newline;
        SystemPrompt += '1=''B''|3=''gd''|9=''DS''|12=''|13=''DG''' + Newline;
        SystemPrompt += '1=''C''|3=''|9=''DS''|12=''|13=''DG''' + Newline;
        SystemPrompt += 'The current item that needs to be checked is: 1=''D|''|3=''|9=''ST''|12=''uy''|13=''DG''' + Newline;
        SystemPrompt += 'The result will be:' + Newline;
        SystemPrompt += 'fieldno: 3, value: MISSING, explanation: The field is not empty in the majority of the items.' + Newline;
        SystemPrompt += 'fieldno: 4, value: DS , explanation: The field value is different from the majority of the items.' + Newline;
        SystemPrompt += 'The output should be in xml, containing field (use fieldno tag), value (use value tag), and explanation why this field was suggested (use explanation tag).';
        SystemPrompt += 'Use items as a root level tag, use item as item tag.';
        SystemPrompt += 'Do not use line breaks or other special characters in explanation.';
        SystemPrompt += 'Skip empty nodes.';
    end;

    var
        TempCopilotDataVerifyProposal: Record "Copilot Data Verify Proposal" temporary;
        DataVerifyTable: Record "Data Verify Table";
        SourceRecord: RecordRef;
}
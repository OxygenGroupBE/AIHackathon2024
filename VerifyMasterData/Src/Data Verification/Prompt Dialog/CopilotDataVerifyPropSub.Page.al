namespace CopilotToolkitDemo;
using Microsoft.Inventory.Item.Substitution;
using Microsoft.Inventory.Item;
using System.Reflection;

page 54339 "Copilot Data Verify Prop Sub"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "Copilot Data Verify Proposal";

    layout
    {
        area(Content)
        {
            repeater(ItemSubstDetails)
            {
                Caption = ' ';
                ShowCaption = false;

                field(Action; Rec.Action)
                {
                    ApplicationArea = All;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                }
                field(Explanation; Rec.Explanation)
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    var
                        InStr: InStream;
                        FullExplanation: Text;
                    begin
                        Rec.CalcFields("Full Explanation");
                        Rec."Full Explanation".CreateInStream(InStr);
                        InStr.ReadText(FullExplanation);
                        Message(FullExplanation);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }


    procedure Load(var TempCopilotItemVerifyProposal: Record "Copilot Data Verify Proposal" temporary)
    begin
        Rec.Reset();
        Rec.DeleteAll();

        TempCopilotItemVerifyProposal.Reset();
        if TempCopilotItemVerifyProposal.FindSet() then
            repeat
                TempCopilotItemVerifyProposal.CalcFields("Full Explanation");
                Rec.Copy(TempCopilotItemVerifyProposal, false);
                Rec."Full Explanation" := TempCopilotItemVerifyProposal."Full Explanation";
                Rec.Insert();
            until TempCopilotItemVerifyProposal.Next() = 0;

        CurrPage.Update(false);
    end;

    procedure SaveVerify(SourceRecord: Variant)
    var
        TempCopilotDataVerifyProposal2: Record "Copilot Data Verify Proposal" temporary;
        DataVerifyTableField: Record "Data Verify Table Field";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        TempCopilotDataVerifyProposal2.Copy(Rec, true);
        TempCopilotDataVerifyProposal2.SetRange(Action, enum::"Copilot Data Verify Action"::"Delete and Skip");
        if TempCopilotDataVerifyProposal2.FindSet() then
            repeat
                if not DataVerifyTableField.Get(TempCopilotDataVerifyProposal2."Table No.", TempCopilotDataVerifyProposal2."Field No.") then begin
                    DataVerifyTableField.Init();
                    DataVerifyTableField."Table No." := TempCopilotDataVerifyProposal2."Table No.";
                    DataVerifyTableField."Field No." := TempCopilotDataVerifyProposal2."Field No.";
                    DataVerifyTableField.Insert();
                end;
            until TempCopilotDataVerifyProposal2.Next() = 0;

        DataTypeManagement.GetRecordRef(SourceRecord, RecRef);

        TempCopilotDataVerifyProposal2.SetRange(Action, enum::"Copilot Data Verify Action"::Update);
        TempCopilotDataVerifyProposal2.SetFilter(Value, '<>%1', '');
        if not TempCopilotDataVerifyProposal2.FindSet() then exit;
        repeat
            FldRef := RecRef.Field(TempCopilotDataVerifyProposal2."Field No.");
            FldRef.Validate(TempCopilotDataVerifyProposal2.Value);
        until TempCopilotDataVerifyProposal2.Next() = 0;

        RecRef.Modify(true);
    end;
}
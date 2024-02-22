page 56202 "Copilot Formula Proposal Sub"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Copilot Formula Proposal";

    layout
    {
        area(Content)
        {
            field(EntryNo; Rec.EntryNo)
            {
                ApplicationArea = All;
            }
            field(Formula; Rec.Formula)
            {
                ApplicationArea = All;
                MultiLine = true;
            }
            field(Parameters; Rec.Parameters)
            {
                ApplicationArea = All;
                MultiLine = true;
            }
            field(Result; Rec.Result)
            {
                ApplicationArea = All;
                MultiLine = true;
            }
        }
    }

    procedure Load(var TmpReminderAIProposal: Record "Copilot Formula Proposal" temporary)
    begin
        Rec.Reset();
        Rec.DeleteAll();

        TmpReminderAIProposal.Reset();
        if TmpReminderAIProposal.FindSet() then
            repeat
                Rec.Copy(TmpReminderAIProposal, false);
                Rec.Insert();
            until TmpReminderAIProposal.Next() = 0;

        CurrPage.Update(false);
    end;

    procedure SetReminderEmailProprosal(var FormulaProp: Record "Copilot Formula Proposal")
    begin
        GFormulaProp := FormulaProp;
    end;

    var
        GFormulaProp: Record "Copilot Formula Proposal";
}
page 56001 "Copilot Reminder Proposal Sub"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Copilot Reminder Proposal";

    layout
    {
        area(Content)
        {
            field("No."; Rec."No.")
            {
                ApplicationArea = All;
            }
            field(subject; Rec.subject)
            {
                ApplicationArea = All;
                MultiLine = true;
            }
            field(salutation; Rec.salutation)
            {
                ApplicationArea = All;
                MultiLine = true;
            }
            field(header; Rec.header)
            {
                ApplicationArea = All;
                MultiLine = true;
            }
            field(footer; Rec.footer)
            {
                ApplicationArea = All;
                MultiLine = true;
            }
            field(closing; Rec.closing)
            {
                ApplicationArea = All;
                MultiLine = true;
            }
        }
    }

    procedure Load(var TmpReminderAIProposal: Record "Copilot Reminder Proposal" temporary)
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

    procedure SetReminderEmailProprosal(var CRP: Record "Copilot Reminder Proposal")
    begin
        GCRP := CRP;
    end;

    procedure SendReminderEmail()
    var
        TheMail: Codeunit "Email Message";
        Email: Codeunit Email;
        MailBody: text;
        Newline: Char;
    begin
        Newline := 10;
        MailBody := GCRP.salutation + Newline;
        MailBody += GCRP.header + Newline;
        MailBody += GCRP.invoices + Newline;
        MailBody += GCRP.footer + Newline;
        MailBody += GCRP.closing + Newline;
        TheMail.create('stv@astena.be', GCRP.subject, MailBody);
        email.OpenInEditor(TheMail);
    end;

    var
        GCRP: Record "Copilot Reminder Proposal";
}
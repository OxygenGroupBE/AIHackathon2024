pageextension 56000 "Customer List Ext" extends "Customer List"
{
    actions
    {
        addfirst(navigation)
        {
            action(GenerateCopilot)
            {
                Caption = 'Suggest with Copilot';
                Image = Sparkle;
                ApplicationArea = All;
                ToolTip = 'Lets Copilot generate a draft reminder mail.';

                trigger OnAction()
                var
                    CustomerReminderPage: page "Copilot Reminder Proposal";
                begin
                    CustomerReminderPage.SetSourceItem(Rec);
                    CustomerReminderPage.Run();
                end;
            }
        }
    }
}
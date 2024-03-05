namespace CopilotToolkitDemo;

using Microsoft.Sales.Customer;

pageextension 54344 "CustomerCard Ext" extends "Customer Card"
{
    actions
    {
        addlast(Creation)
        {
            action(VerifyByCopilot)
            {
                ApplicationArea = All;
                Image = Sparkle;
                Caption = 'Verify by Copilot';
                ToolTip = 'Verify by Copilot';
                trigger OnAction()
                begin                    
                    VerifyWithAI();
                end;
            }
        }

        addfirst(Category_Process)
        {
            actionref(VerifyByCopilot_Promoted; VerifyByCopilot) { }
        }
    }


    local procedure VerifyWithAI();
    var
        CopilotItemVerifyProposal: Page "Copilot Data Verify Proposal";
    begin
        CopilotItemVerifyProposal.SetSourceRecord(Rec);
        CopilotItemVerifyProposal.RunModal();
        CurrPage.Update(false);
    end;
}
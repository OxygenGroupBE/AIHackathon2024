namespace CopilotToolkitDemo;

using Microsoft.Purchases.Vendor;

pageextension 54345 "VendorCard Ext" extends "Vendor Card"
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
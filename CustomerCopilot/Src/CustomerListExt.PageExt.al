pageextension 55120 CustomerListExt extends "Customer List"
{
    layout
    {
        addfirst(factboxes)
        {
            part(CustCopilotInfo; "Cust. Copilot Info Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
        }
    }
    actions
    {
        addfirst("&Customer")
        {
            action(CustomerCopilot)
            {
                ApplicationArea = All;
                Image = Sparkle;
                Caption = 'Show Info from Copilot';
                ToolTip = 'Show Info from Copilot';


                trigger OnAction()
                var
                    GetCustInfoCopilotMeth: Codeunit "GetCustInfo Copilot Meth";
                begin
                    message(GetCustInfoCopilotMeth.GetCustomerInfo(Rec))
                end;
            }
        }

        addfirst(Promoted)
        {
            actionref(CustomerCopilotRef; CustomerCopilot) { }
        }
    }
}
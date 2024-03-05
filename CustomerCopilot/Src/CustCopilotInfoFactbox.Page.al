namespace AIHackathon.waldo.Copilot.CustomerInfo;

using Microsoft.Sales.Customer;

page 55120 "Cust. Copilot Info Factbox"
{
    PageType = CardPart;
    SourceTable = Customer;

    layout
    {
        area(Content)
        {
            field(RichText; CustInfo)
            {
                ApplicationArea = All;
                // Caption = 'Customer Copilot Info';
                ShowCaption = false;
                MultiLine = true;
                ExtendedDatatype = RichContent;

                trigger OnAssistEdit()
                begin
                    Message(CustInfo);
                end;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Image = Refresh;

                trigger OnAction()
                begin
                    RefreshCustInfo
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RefreshCustInfo;
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        if TaskId <> CurrTaskId then exit;

        CustInfo := Results.Get('Response');
    end;

    local procedure RefreshCustInfo()
    var
        GetCustInfoCopilotMeth: Codeunit "GetCustInfo Copilot Meth";
        Parameters: Dictionary of [text, text];
    begin
        Parameters.Add('CustomerNo', Rec."No.");

        CurrPage.EnqueueBackgroundTask(CurrTaskId, codeunit::"GetCustInfo Copilot Meth", Parameters);
    end;


    var
        CustInfo: Text;
        CurrTaskId: Integer;
        mInitialized: Boolean;
        mHtmlText: Text;
}
namespace AIHackathon.waldo.Copilot.QOTD;

using AIHackathon.waldo.Copilot.QOTD;
using System.Visualization;

pageextension 55160 "HeadlineRCBusinessManager Ext" extends "Headline RC Business Manager"
{
    layout
    {
        addfirst(content)
        {
            group(QOTDControl)
            {
                ShowCaption = false;
                Visible = QOTDVisible;
                field(QOTDText; QOTD)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Greeting headline';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Message(QOTD);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        QOTDVisible := true;

        GetQOTD();
    end;

    local procedure GetQOTD()
    var
        GetQOTDfromCopilot: Codeunit "Get QOTD from Copilot";
    begin
        QOTD := GetQOTDfromCopilot.GetQuote();
    end;

    var
        QOTDVisible: Boolean;
        QOTD: TExt;
}
page 54301 "Data Verify Table Subpage"
{
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "Data Verify Table Field";
    Caption = 'Mandatory Fields';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;

                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
            }
        }


    }
}
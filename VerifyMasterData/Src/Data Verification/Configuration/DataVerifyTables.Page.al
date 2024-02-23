
page 54300 "Data Verify Tables"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Data Verify Table";
    Caption = 'Data Verify Configurations';
    DelayedInsert = true;


    layout
    {
        area(Content)
        {

            repeater(Group)
            {

                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tabel No. field';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field(Sampling; Rec.Sampling)
                {
                    ToolTip = 'Specifies the value of the Sampling field. How many records needs to be used as base for verification';
                }
                field("Filter Field No."; Rec."Filter Field No.")
                {
                    ToolTip = 'Specifies the value of the Filter Field No. field.';
                }
                field("Filter Field Name"; Rec."Filter Field Name")
                {
                    ToolTip = 'Specifies the value of the Filter Field Name field.';
                }
                field("No. Of Skipped Fields"; Rec."No. Of Skipped Fields")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Of Skipped Fields field';
                }


            }


            part("Subpage"; "Data Verify Table Subpage")
            {

                Caption = 'Skip Fields';
                SubPageLink = "Table No." = field("Table No.");
                UpdatePropagation = Both;
                ApplicationArea = All;

            }

        }
    }
}
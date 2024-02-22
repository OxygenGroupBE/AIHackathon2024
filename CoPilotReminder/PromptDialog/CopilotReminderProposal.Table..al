table 56000 "Copilot Reminder Proposal"
{
    TableType = Temporary;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(2; subject; Text[2048])
        {
            Caption = 'subject';
        }
        field(3; salutation; Text[2048])
        {
            Caption = 'salutation';
        }
        field(4; header; Text[2048])
        {
            Caption = 'header';
        }
        field(5; footer; Text[2048])
        {
            Caption = 'footer';
        }
        field(6; closing; Text[2048])
        {
            Caption = 'closing';
        }
        field(7; invoices; Text[2048])
        {
            Caption = 'invoices';
        }

    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}